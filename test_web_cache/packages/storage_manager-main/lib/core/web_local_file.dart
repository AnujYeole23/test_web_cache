import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:storage_manager/core/local_file.dart';
import 'package:universal_io/io.dart';

class WebLocalFile implements LocalFile {
  @override
  Future<bool> fileExists(String localPath) async {
    try {
      final parts = localPath.split('/');
      final fileName = parts.last;
      final directoryName = parts.length > 1 ? parts.first : null;

      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();
      if (directoryHandle == null) {
        return false;
      }

      FileSystemDirectoryHandle? subDirectoryHandle = directoryHandle;
      if (directoryName != null) {
        subDirectoryHandle = await directoryHandle.getDirectoryHandle(
          directoryName,
        );
      }

      await subDirectoryHandle.getFileHandle(fileName);

      return true;
    } on NotFoundError {
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<DateTime?> lastModified(String localPath) async {
    try {

     
      final parts = localPath.split('/');
      final directoryName = parts.length > 1 ? parts.first : null;

 
      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();
      if (directoryHandle == null) {
        throw UnsupportedError('File System Access API is not supported.');
      }


      if (directoryName != null) {}
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<String> getPath({
    required String storagePath,
    Directory? cacheDir,
  }) async {
    try {

      final fileName = storagePath.split('/').last;

   
      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();

      if (directoryHandle == null) {
        throw UnsupportedError('File System Access API is not supported.');
      }
      return fileName;
    } catch (e) {
      return '';
    }
  }

  @override
  Future<Directory> getDownloadDirectory(Directory cacheDir) async {
    try {
      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();

      if (directoryHandle == null) {
        throw UnsupportedError('File System Access API is not supported.');
      }

      final downloadDirHandle = await directoryHandle.getDirectoryHandle(
        'downloads',
        create: true,
      );

      return Directory(downloadDirHandle.name);
    } catch (e) {
      rethrow;
    }
  }
}
