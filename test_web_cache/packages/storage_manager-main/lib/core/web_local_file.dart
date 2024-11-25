import 'dart:html';
import 'package:storage_manager/core/local_file.dart';
import 'package:universal_io/io.dart';

class WebLocalFile implements LocalFile {
  static final CacheStorage? _cacheStorage = window.caches;

  @override
  Future<bool> fileExists(String localPath) async {
    try {
      if (_cacheStorage == null) {
        return false; // CacheStorage is not supported
      }

      final cache =
          await _cacheStorage!.open('web-local-cache'); // Cast to Cache
      final response = await cache
          .match(localPath); // Use match to find the resource

      return response != null; // Check if resource exists
    } catch (e) {
      print('Error in fileExists: $e');
      return false; // Handle errors gracefully
    }
  }

  @override
  Future<DateTime?> lastModified(String localPath) async {
    try {
      final metadataStorage = window.localStorage;
      final metadata = metadataStorage['$localPath:lastModified'];

      if (metadata != null) {
        return DateTime.parse(metadata);
      }
    } catch (e) {
      print('Error in lastModified: $e');
    }
    return null;
  }

  @override
  Future<String> getPath(
      {required String storagePath, Directory? cacheDir}) async {
    try {
      return Uri.parse(storagePath).toString();
    } catch (e) {
      print('Error in getPath: $e');
      return '';
    }
  }

  @override
  Future<Directory> getDownloadDirectory(Directory cacheDir) {
    throw UnimplementedError('getDownloadDirectory is not applicable for web.');
  }
}
