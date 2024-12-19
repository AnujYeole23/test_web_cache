import 'package:file_system_access_api/file_system_access_api.dart';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

abstract class OpfsHelper {
  static Future<FileSystemDirectoryHandle?> getDirectoryHandle(
      {String? directoryName}) async {
    final directoryHandle = await html.window.navigator.storage?.getDirectory();
    if (directoryHandle == null) {
      throw UnsupportedError('File System Access API is not supported.');
    }
    if (directoryName != null) {
      return directoryHandle.getDirectoryHandle(directoryName);
    }
    return directoryHandle;
  }

  static Future<FileSystemFileHandle?> getFileHandle(String localPath) async {
    final parts = localPath.split('/');
    final fileName = parts.last;
    final directoryName = parts.length > 1 ? parts.first : null;

    final directoryHandle =
        await getDirectoryHandle(directoryName: directoryName);
    if (directoryHandle == null) {
      return null;
    }
    return directoryHandle.getFileHandle(fileName);
  }

  static Future<String>? readFileFromOPFS(String filename) async {
    try {
      final fileSystem = await html.window.navigator.storage?.getDirectory();
      if (fileSystem != null) {
        final fileHandle = await fileSystem.getFileHandle(filename);

        final file = await fileHandle.getFile();

        final fileUrl = html.Url.createObjectUrlFromBlob(file);
        print("File Url $fileUrl");
        return fileUrl;
      } else {
       debugPrint("File Not Found");
      }
    } catch (e) {
      debugPrint("Error in Read file from OPfs $e");
    }
    return filename;
  }
}
