import 'dart:async';
import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:storage_manager/core/local_file.dart';
import 'package:flutter_download_manager/src/opfs_helper.dart';
import 'package:universal_io/io.dart';

class WebLocalFile implements LocalFile {
  final opfsHelper=OpfsHelper();
  @override
  Future<bool> fileExists(String localPath) async {
    try {
      final fileHandle = await opfsHelper.getFileHandle(localPath);
      return fileHandle != null;
    } on NotFoundError {
      return false;
    } catch (e) {
      print('Error in fileExists: $e');
      return false;
    }
  }

  @override
Future<DateTime?> lastModified(String localPath) async {
  try {
    final fileHandle = await opfsHelper.getFileHandle(localPath);
    if (fileHandle == null) {
      return null;
    }
    final file = await fileHandle.getFile();
    final lastModifiedTimestamp = file.lastModified;
    if (lastModifiedTimestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(lastModifiedTimestamp);
    }
    return null;
  } catch (e) {
    print('Error in lastModified: $e');
    return null;
  }
}


  @override
  Future<String> getPath({
    required String storagePath,
    Directory? cacheDir,
  }) async {
    try {
      final fileName = storagePath.split('/').last;
      return fileName;
    } catch (e) {
      print('Error in getPath: $e');
      return '';
    }
  }

  @override
  Future<Directory> getDownloadDirectory(Directory cacheDir) async {
    try {
      final directoryHandle = await opfsHelper.getDirectoryHandle();
      if (directoryHandle == null) {
        throw UnsupportedError('File System Access API is not supported.');
      }

      final downloadDirHandle = await directoryHandle.getDirectoryHandle(
        'downloads',
        create: true,
      );


      return Directory(downloadDirHandle.name);
    } catch (e) {
      print('Error in getDownloadDirectory: $e');
      rethrow;
    }
  }
}
