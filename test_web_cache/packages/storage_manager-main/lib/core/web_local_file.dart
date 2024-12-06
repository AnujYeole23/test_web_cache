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

      // Ensure the localPath does not have unexpected slashes
      final parts = localPath.split('/');
      final fileName = parts.last;
      final directoryName = parts.length > 1 ? parts.first : null;

      // Get the directory handle
      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();
      if (directoryHandle == null) {
        print(
            'Directory handle is null. File System Access API might not be supported.');
        return false;
      }
      print('Directory handle successfully retrieved.');

      // If directory is specified, navigate to it
      FileSystemDirectoryHandle? subDirectoryHandle = directoryHandle;
      if (directoryName != null) {
        subDirectoryHandle = await directoryHandle.getDirectoryHandle(
          directoryName,
        );
        if (subDirectoryHandle == null) {
          print('Subdirectory does not exist: $directoryName');
          return false;
        }
        print('Subdirectory handle successfully retrieved: $directoryName');
      }

      // Attempt to get the file handle
      await subDirectoryHandle.getFileHandle(fileName);
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

      // Split the path into directory and file name
      final parts = localPath.split('/');
      final fileName = parts.last;
      final directoryName = parts.length > 1 ? parts.first : null;

      // Get the directory handle
      final directoryHandle =
          await html.window.navigator.storage?.getDirectory();
      if (directoryHandle == null) {
        throw UnsupportedError('File System Access API is not supported.');
      }

      // Navigate to the specified subdirectory, if it exists
      FileSystemDirectoryHandle? subDirectoryHandle = directoryHandle;
      if (directoryName != null) {
        subDirectoryHandle = await directoryHandle.getDirectoryHandle(
          directoryName,
        );
      }

      // Get the file handle
      final fileHandle = await subDirectoryHandle!.getFileHandle(fileName);
      final file = await fileHandle.getFile();

      // Extract the last modified date
      print('Last modified date for $localPath: $lastModified');
      // return lastModified;
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

      final fileHandle = await directoryHandle.getFileHandle(
        fileName,
        create: true,
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