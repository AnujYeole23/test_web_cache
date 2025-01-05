import 'package:flutter_test/flutter_test.dart';
import 'package:file_system_access_api/file_system_access_api.dart';
import 'dart:html' as html;

import 'package:storage_manager/core/opfs_helper.dart';

/// Mock implementation of FileSystemDirectoryHandle
class MockFileSystemDirectoryHandle implements FileSystemDirectoryHandle {
  final Map<String, FileSystemHandle> _entries = {};

  Future<FileSystemDirectoryHandle> getDirectoryHandle(String name,
      {bool create = false}) async {
    if (create && !_entries.containsKey(name)) {
      _entries[name] = MockFileSystemDirectoryHandle();
    }
    return _entries[name] as FileSystemDirectoryHandle;
  }

  Future<FileSystemFileHandle> getFileHandle(String name,
      {bool create = false}) async {
    if (create && !_entries.containsKey(name)) {
      _entries[name] = MockFileSystemFileHandle();
    }
    return _entries[name]! as FileSystemFileHandle;
  }

  Future<void> removeEntry(String name, {bool recursive = false}) async {
    _entries.remove(name);
  }
}

/// Mock implementation of FileSystemFileHandle
class MockFileSystemFileHandle implements FileSystemFileHandle {
  Future<html.File> getFile() async {
    return html.File(['mock content'], 'mock_file.txt');
  }
}

void main() {
  group('OpfsHelper Tests', () {

    setUp(() {
    });

    test('getDirectoryHandle returns root directory', () async {
      final directoryHandle = await OpfsHelper.getDirectoryHandle();
      expect(directoryHandle, isNotNull);
      expect(directoryHandle, isA<FileSystemDirectoryHandle>());
    });

    test('getDirectoryHandle returns subdirectory', () async {
      const subdirectoryName = 'testSubDir';
      final directoryHandle =
          await OpfsHelper.getDirectoryHandle(directoryName: subdirectoryName);
      expect(directoryHandle, isNotNull);
      expect(directoryHandle, isA<FileSystemDirectoryHandle>());
    });

    test('getFileHandle retrieves file from root', () async {
      const fileName = 'testFile.txt';
      final fileHandle = await OpfsHelper.getFileHandle(fileName);
      expect(fileHandle, isNotNull);
      expect(fileHandle, isA<FileSystemFileHandle>());
    });

    test('getFileHandle retrieves file from subdirectory', () async {
      const localPath = 'testDir/testFile.txt';
      final fileHandle = await OpfsHelper.getFileHandle(localPath);
      expect(fileHandle, isNotNull);
      expect(fileHandle, isA<FileSystemFileHandle>());
    });

    test('readFileFromOPFS retrieves file URL', () async {
      const fileName = 'mock_file.txt';
      final fileUrl = await OpfsHelper.readFileFromOPFS(fileName);
      expect(fileUrl, isNotNull);
      expect(fileUrl, contains('blob:'));
    });
  });
}
