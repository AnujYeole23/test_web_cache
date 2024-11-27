import 'dart:async';
import 'dart:html' as html;
import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:storage_manager/core/local_file.dart';
import 'package:universal_io/io.dart';


class WebLocalFile implements LocalFile {

  @override
  Future<bool> fileExists(String localPath) async {
    try {
      final directoryHandle = await html.window.showDirectoryPicker();
      final fileHandle = await directoryHandle.getFileHandle(localPath);
      return fileHandle != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DateTime?> lastModified(String localPath) async {
    try {
      final directoryHandle = await html.window.showDirectoryPicker();
      final fileHandle = await directoryHandle.getFileHandle(localPath);
      final file = await fileHandle.getFile();
      return file.lastModifiedDate;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> getPath({
    required String storagePath,
    Directory? cacheDir,
  }) async {
    try {
      // If a cache directory is provided, use it to resolve the full path
      if (cacheDir != null) {
        final cacheDirHandle = await html.window.showDirectoryPicker();
        final cachePath = '${cacheDirHandle.name}/$storagePath';
        return cachePath;
      }

      // Otherwise, use the root directory to resolve the full path
      final rootDirHandle = await html.window.showDirectoryPicker();
      final fullPath = '${rootDirHandle.name}/$storagePath';
      return fullPath;
    } catch (e) {
      print('Error resolving path: $e');
      return '';
    }
  }

  @override
  Future<Directory> getDownloadDirectory(Directory cacheDir)async {
    try {
      // Use the provided cache directory as the base for downloads
      final downloadDirHandle = await html.window.showDirectoryPicker();
      final downloadDir = Directory(downloadDirHandle.name);
      return downloadDir;
    } catch (e) {
      print('Error accessing download directory: $e');
      rethrow;
    }
  }
}
