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

    // Check if File System Access API is supported
    if (html.window.navigator.storage == null) {
      print('File System Access API is not supported in this browser.');
      return false;
    }

    // Get the directory handle
    final directoryHandle = await html.window.navigator.storage?.getDirectory();
    if (directoryHandle == null) {
      print(
          'Directory handle is null. File System Access API might not be supported.');
      return false;
    }
    print('Directory handle successfully retrieved.');

    // Sanitize and escape the file name before using it
    final sanitizedFileName = Uri.encodeComponent(localPath.trim());
    print('Sanitized file name: $sanitizedFileName');

    // Attempt to get the file handle
    await directoryHandle.getFileHandle(sanitizedFileName);
    print('File exists: $localPath');
    return true;

  } on NotFoundError {
    print("File not found: $localPath");
    return false;
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

    // Extract the file name from the URL
    final fileName = storagePath.split('/').last;
    print('Extracted file name: $fileName');

    // Request directory access from the user
    final directoryHandle =
        await html.window.navigator.storage?.getDirectory();

    if (directoryHandle == null) {
      throw UnsupportedError('File System Access API is not supported.');
    }

    // Try to get the file handle, creating the file if it doesn't exist
    final fileHandle = await directoryHandle.getFileHandle(
      fileName,
      create: true, // Create the file if it doesn't exist
    );
    print('File handle retrieved or created: ${fileHandle.name}');

    // Return the file name or construct a full path if needed
    return fileName;
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
