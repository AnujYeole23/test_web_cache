import 'dart:async';
import 'dart:html' as html;
import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:storage_manager/core/local_file.dart';
import 'package:universal_io/io.dart';

class WebLocalFile implements LocalFile {
  @override
  Future<bool> fileExists(String localPath) async {
    try {
      print('Checking if file exists at path: $localPath');
      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();

      if (directoryHandle == null) {
        print(
            'Directory handle is null. File System Access API might not be supported.');
        return false;
      }

      final fileHandle = await directoryHandle.getFileHandle(localPath);
      print(fileHandle != null
          ? 'File exists: $localPath'
          : 'File does not exist: $localPath');
      return fileHandle != null;
    } catch (e) {
      print('Error while checking file existence: $e');
      return false;
    }
  }

  @override
  Future<DateTime?> lastModified(String localPath) async {
    try {
      print('Getting last modified date for file: $localPath');
      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();

      if (directoryHandle == null) {
        throw UnsupportedError('File System Access API is not supported.');
      }

      final fileHandle = await directoryHandle.getFileHandle(localPath);
      final file = await fileHandle.getFile();
      final lastModified = file.lastModifiedDate;
      print('Last modified date for $localPath: $lastModified');
      return lastModified;
    } catch (e) {
      print('Error while getting last modified date: $e');
      return null;
    }
  }

  @override
  Future<String> getPath({
    required String storagePath,
    Directory? cacheDir,
  }) async {
    try {
      print('Resolving path for storagePath: $storagePath');
      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();

      if (directoryHandle == null) {
        throw UnsupportedError('File System Access API is not supported.');
      }

      print('Resolved path: $storagePath');
      return storagePath;
    } catch (e) {
      print('Error resolving path for storagePath: $e');
      return '';
    }
  }

  @override
  Future<Directory> getDownloadDirectory(Directory cacheDir) async {
    try {
      print('Fetching download directory...');
      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();

      if (directoryHandle == null) {
        throw UnsupportedError('File System Access API is not supported.');
      }

      print('Attempting to get/create the "downloads" directory...');
      final downloadDirHandle = await directoryHandle.getDirectoryHandle(
        'downloads',
        create: true,
      );

      print(
          'Successfully retrieved "downloads" directory: ${downloadDirHandle.name}');
      return Directory(downloadDirHandle.name);
    } catch (e) {
      print('Error accessing download directory: $e');
      rethrow;
    }
  }
}
