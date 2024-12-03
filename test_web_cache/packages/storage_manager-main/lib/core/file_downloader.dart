import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:storage_manager/core/local_file.dart';
import 'package:universal_io/io.dart';

/// Abstract class to download files and manage paths
abstract class FileDownloader {
  /// Downloads a file from the given `storagePath` and saves it locally.
  /// 
  /// [storagePath]: The path in remote storage.
  /// [cacheDir]: Optional cache directory to store the downloaded file.
  /// 
  /// Returns a [DownloadTask] or `null` if an error occurs.
  static Future<DownloadTask?> downloadFile(
    String storagePath, {
    Directory? cacheDir,
  }) async {
    try {
      print('Starting download for storagePath: $storagePath');

      // Generate local file path
      final localFilePath = await LocalFile.instance.getPath(
        storagePath: storagePath,
        cacheDir: cacheDir,
      );

      print('Resolved local file path: $localFilePath');

      // Obtain the download URL
      // Uncomment this when integrating with Firebase Storage
      // final storageRef = FirebaseStorage.instance.ref(storagePath);
      // final url = await storageRef.getDownloadURL();

      // Test URL
      const url = 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4';

      print('Download URL: $url');

      // Initialize download manager with a maximum of 4 concurrent tasks
      final dl = DownloadManager(maxConcurrentTasks: 4);
      // Add the download task
      final downloadTask = dl.addDownload(url, localFilePath);
      if (downloadTask == null) {
        print('Failed to add download task.');
        return null;
      }

      print('Download task added successfully: ${await downloadTask} ');
      return downloadTask;

    } catch (e) {
      print('Error while downloading file: $e');
      return null;
    }
  }
}
