import 'dart:async';
import 'dart:collection';


import 'dart:js_interop';
import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:universal_io/io.dart';
import 'package:collection/collection.dart';
import 'dart:html' as html;
import 'dart:typed_data'; // For working with Uint8List, if needed

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class DownloadManager {
  final Map<String, DownloadTask> _cache = <String, DownloadTask>{};
  final Queue<DownloadRequest> _queue = Queue();
  var dio = Dio();
  static const partialExtension = ".partial";
  static const tempExtension = ".temp";

  // var tasks = StreamController<DownloadTask>();

  int maxConcurrentTasks = 2;
  int runningTasks = 0;

  static final DownloadManager _dm = new DownloadManager._internal();

  DownloadManager._internal();

  factory DownloadManager({
    int? maxConcurrentTasks,
    Dio? dio,
  }) {
    if (maxConcurrentTasks != null) {
      _dm.maxConcurrentTasks = maxConcurrentTasks;
    }

    _dm.dio = dio ?? Dio();

    return _dm;
  }

  void Function(int, int) createCallback(url, int partialFileLength) =>
      (int received, int total) {
        getDownload(url)?.progress.value =
            (received + partialFileLength) / (total + partialFileLength);

        if (total == -1) {}
      };

  String extractFileName(String url) {
    final uri = Uri.parse(url);
    return uri.pathSegments.last;
  }

  Future<void> download(String url, String savePath, CancelToken cancelToken,
      {bool forceDownload = false}) async {
    try {
      print('Download started for URL: $url');

      var task = getDownload(url);
      if (task == null) {
        print('No download task found for URL: $url');
        return;
      }

      if (task.status.value == DownloadStatus.canceled) {
        print('Download canceled for URL: $url');
        return;
      }

      setStatus(task, DownloadStatus.downloading);
      print('Download status set to downloading for URL: $url');

      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
        cancelToken: cancelToken,
      );

      if (response.statusCode == HttpStatus.ok) {
        print('Received response data length: ${response.data.length}');
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
      }

      if (response.statusCode == HttpStatus.ok) {
        final filename = extractFileName(url);

        if (kIsWeb) {
          await _downloadFileWeb(response.data, filename);
        } else {
          await _downloadFileNative(response.data, savePath);
        }

        setStatus(task, DownloadStatus.completed);
        print('Download completed for URL: $url');
      } else {
        print(
            'HTTP request failed with status: ${response.statusCode} for URL: $url');
        setStatus(task, DownloadStatus.failed);
      }
    } catch (e) {
      print('An error occurred during download for URL: $url');
      print('Error details: $e');

      var task = getDownload(url)!;
      if (task.status.value != DownloadStatus.canceled &&
          task.status.value != DownloadStatus.paused) {
        setStatus(task, DownloadStatus.failed);
      }
      rethrow;
    } finally {
      runningTasks--;
      print('Running tasks decremented. Current running tasks: $runningTasks');

      if (_queue.isNotEmpty) {
        _startExecution();
      }
    }
  }

  Future<void> _downloadFileWeb(Uint8List data, String filename) async {
    try {
      print('Starting web download for $filename');

      final fileSystem = await html.window.navigator.storage?.getDirectory();
      if (fileSystem != null) {
        print('OPFS directory retrieved successfully');

        final fileHandle =
            await fileSystem.getFileHandle(filename, create: true);
        print('File handle created for $filename');

        final writable =
            await fileHandle.createWritable() as FileSystemWritableFileStream;
        print('Writable stream created');

        await writable.write(data.toJS).toDart;
        await writable.close().toDart;

        print('File saved to OPFS as $filename');
      } else {
        print('OPFS is not supported or unavailable.');
      }
    } catch (e) {
      print('Failed to download file using OPFS: $e');
    }
  }

  _downloadFileNative(data, String savePath) {}

  void disposeNotifiers(DownloadTask task) {
    // task.status.dispose();
    // task.progress.dispose();
  }

  void setStatus(DownloadTask? task, DownloadStatus status) {
    if (task != null) {
      task.status.value = status;

      // tasks.add(task);
      if (status.isCompleted) {
        disposeNotifiers(task);
      }
    }
  }

  Future<DownloadTask?> addDownload(String url, String savedDir) async {
    if (url.isEmpty) {
      return null;
    }

    if (kIsWeb) {
      try {
        FileSystemDirectoryHandle? root =
            await html.window.navigator.storage?.getDirectory();
        if (root == null) {
          print("OPFS is not supported by this browser.");
          return null;
        }

        String fileName = getFileNameFromUrl(url);


        return _addDownloadRequest(DownloadRequest(url, fileName));
      } catch (e) {
        print("Error using OPFS: $e");
        return null;
      }
    } else {
      if (savedDir.isEmpty) {
        savedDir = ".";
      }

      var isDirectory = await Directory(savedDir).exists();
      var downloadFilename = isDirectory
          ? savedDir + Platform.pathSeparator + getFileNameFromUrl(url)
          : savedDir;

      return _addDownloadRequest(DownloadRequest(url, downloadFilename));
    }
  }

  Future<DownloadTask> _addDownloadRequest(
      DownloadRequest downloadRequest) async {
    if (_cache[downloadRequest.url] != null) {
      if (!_cache[downloadRequest.url]!.status.value.isCompleted &&
          _cache[downloadRequest.url]!.request == downloadRequest) {
        return _cache[downloadRequest.url]!;
      } else {
        _queue.remove(_cache[downloadRequest.url]);
      }
    }

    _queue.add(DownloadRequest(downloadRequest.url, downloadRequest.path));

    var task = DownloadTask(_queue.last);

    _cache[downloadRequest.url] = task;

    _startExecution();

    return task;
  }

  Future<void> pauseDownload(String url) async {
    if (kDebugMode) {
      print("Pause Download");
    }
    var task = getDownload(url)!;
    setStatus(task, DownloadStatus.paused);
    task.request.cancelToken.cancel();

    _queue.remove(task.request);
  }

  Future<void> cancelDownload(String url) async {
    if (kDebugMode) {
      print("Cancel Download");
    }
    var task = getDownload(url)!;
    setStatus(task, DownloadStatus.canceled);
    _queue.remove(task.request);
    task.request.cancelToken.cancel();
  }

  Future<void> resumeDownload(String url) async {
    if (kDebugMode) {
      print("Resume Download");
    }
    var task = getDownload(url)!;
    setStatus(task, DownloadStatus.downloading);
    task.request.cancelToken = CancelToken();
    _queue.add(task.request);

    _startExecution();
  }

  Future<void> removeDownload(String url) async {
    cancelDownload(url);
    _cache.remove(url);
  }

  // Do not immediately call getDownload After addDownload, rather use the returned DownloadTask from addDownload
  DownloadTask? getDownload(String url) {
    return _cache[url];
  }

  Future<DownloadStatus> whenDownloadComplete(String url,
      {Duration timeout = const Duration(hours: 2)}) async {
    DownloadTask? task = getDownload(url);

    if (task != null) {
      return task.whenDownloadComplete(timeout: timeout);
    } else {
      return Future.error("Not found");
    }
  }

  List<DownloadTask> getAllDownloads() {
    return _cache.values.toList();
  }

  // Batch Download Mechanism
  Future<void> addBatchDownloads(List<String> urls, String savedDir) async {
    urls.forEach((url) {
      addDownload(url, savedDir);
    });
  }

  List<DownloadTask?> getBatchDownloads(List<String> urls) {
    return urls.map((e) => _cache[e]).toList();
  }

  Future<void> pauseBatchDownloads(List<String> urls) async {
    urls.forEach((element) {
      pauseDownload(element);
    });
  }

  Future<void> cancelBatchDownloads(List<String> urls) async {
    urls.forEach((element) {
      cancelDownload(element);
    });
  }

  Future<void> resumeBatchDownloads(List<String> urls) async {
    urls.forEach((element) {
      resumeDownload(element);
    });
  }

  ValueNotifier<double> getBatchDownloadProgress(List<String> urls) {
    ValueNotifier<double> progress = ValueNotifier(0);
    var total = urls.length;

    if (total == 0) {
      return progress;
    }

    if (total == 1) {
      return getDownload(urls.first)?.progress ?? progress;
    }

    var progressMap = Map<String, double>();

    urls.forEach((url) {
      DownloadTask? task = getDownload(url);

      if (task != null) {
        progressMap[url] = 0.0;

        if (task.status.value.isCompleted) {
          progressMap[url] = 1.0;
          progress.value = progressMap.values.sum / total;
        }

        var progressListener;
        progressListener = () {
          progressMap[url] = task.progress.value;
          progress.value = progressMap.values.sum / total;
        };

        task.progress.addListener(progressListener);

        var listener;
        listener = () {
          if (task.status.value.isCompleted) {
            progressMap[url] = 1.0;
            progress.value = progressMap.values.sum / total;
            task.status.removeListener(listener);
            task.progress.removeListener(progressListener);
          }
        };

        task.status.addListener(listener);
      } else {
        total--;
      }
    });

    return progress;
  }

  Future<List<DownloadTask?>?> whenBatchDownloadsComplete(List<String> urls,
      {Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<List<DownloadTask?>?>();

    var completed = 0;
    var total = urls.length;

    urls.forEach((url) {
      DownloadTask? task = getDownload(url);

      if (task != null) {
        if (task.status.value.isCompleted) {
          completed++;

          if (completed == total) {
            completer.complete(getBatchDownloads(urls));
          }
        }

        var listener;
        listener = () {
          if (task.status.value.isCompleted) {
            completed++;

            if (completed == total) {
              completer.complete(getBatchDownloads(urls));
              task.status.removeListener(listener);
            }
          }
        };

        task.status.addListener(listener);
      } else {
        total--;

        if (total == 0) {
          completer.complete(null);
        }
      }
    });

    return completer.future.timeout(timeout);
  }

  void _startExecution() async {
    if (runningTasks == maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    while (_queue.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      if (kDebugMode) {
        print('Concurrent workers: $runningTasks');
      }
      var currentRequest = _queue.removeFirst();

      download(
          currentRequest.url, currentRequest.path, currentRequest.cancelToken);

      await Future.delayed(Duration(milliseconds: 500), null);
    }
  }

  /// This function is used for get file name with extension from url
  String getFileNameFromUrl(String url) {
    return url.split('/').last;
  }
}

/// This is a bridge to interact with the web's OPFS writable stream via JavaScript interop.
///
@JS()
@staticInterop
class FileSystemWritableFileStream {}

extension FileSystemWritableFileStreamExtension
    on FileSystemWritableFileStream {
  external JSPromise write(JSAny data);
  external JSPromise close();
}