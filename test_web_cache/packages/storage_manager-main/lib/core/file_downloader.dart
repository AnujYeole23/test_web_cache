import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:storage_manager/core/local_file.dart';
import 'package:universal_io/io.dart';

abstract class FileDownloader {
  static Future<DownloadTask?> downloadFile(
    String storagePath, {
    Directory? cacheDir,
  }) async {
    final localFilePath = await LocalFile.instance.getPath(
      storagePath: storagePath,
      cacheDir: cacheDir,
    );

    // Unescape the storage path to use it as the URL
    final url = Uri.decodeFull(storagePath);

    final dl = DownloadManager(maxConcurrentTasks: 4);

    return dl.addDownload(url, localFilePath);
  }
}