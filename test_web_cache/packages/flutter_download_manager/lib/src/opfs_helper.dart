import 'dart:html' as html;
import 'dart:js_interop';
import 'package:file_system_access_api/file_system_access_api.dart';
import 'package:flutter/foundation.dart';

class OpfsHelper {
  Future<FileSystemDirectoryHandle?> getDirectoryHandle(
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

  Future<FileSystemFileHandle?> getFileHandle(String localPath) async {
    final parts = localPath.split('/');
    final fileName = parts.last;
    final directoryName = parts.length > 1 ? parts.first : null;

    final directoryHandle =
        await getDirectoryHandle(directoryName: directoryName);
    if (directoryHandle == null) {
      return null;
    }
    return directoryHandle.getFileHandle(fileName, create: true);
  }

  Future<String?> readFileFromOPFS(String filename) async {
  try {
    final fileSystem = await html.window.navigator.storage?.getDirectory();
    if (fileSystem != null) {
      final fileHandle = await fileSystem.getFileHandle(filename);
      final file = await fileHandle.getFile();
      final fileUrl = html.Url.createObjectUrlFromBlob(file);
      print("File URL: $fileUrl");
      return fileUrl;
    }
  } catch (e) {
    print('Error reading file from OPFS: $e');
    return null;
  }
  return null;
}

  Future<void> writeFile(Uint8List data, String filename) async {
    try {
      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();
      if (directoryHandle != null) {
        final fileHandle =
            await directoryHandle.getFileHandle(filename, create: true);
        final writable =
            await fileHandle.createWritable() as FileSystemWritableFileStream;

        // Write the data to the file
        await writable.write(data.toJS).toDart;
        await writable.close().toDart;
      } else {
        throw UnsupportedError('File System Access API is not supported.');
      }
    } catch (e) {
      print('Error in writeFile: $e');
      rethrow;
    }
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
