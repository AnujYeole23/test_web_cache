import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:storage_manager/controllers/storage_file_controller.dart';
import 'package:storage_manager/enums/storage_file_status.dart';
import 'package:storage_manager/models/storage_file_snapshot.dart';
import 'package:http/http.dart' as http; // For fetching files on the web

/// A widget for downloading and managing storage files across platforms.
class StorageFileBuilder extends StatefulWidget {
  const StorageFileBuilder({
    required this.storagePath,
    required this.builder,
    this.updateDate,
    this.cacheDirectory,
    super.key,
  });

  /// URL of any type of media (Audio, Video, Image, etc.)
  final String storagePath;

  final Directory? cacheDirectory;

  final DateTime? updateDate;

  /// Provides the current file download status and snapshot to build the UI.
  final Widget? Function(BuildContext context, StorageFileSnapshot snapshot)
      builder;

  @override
  State<StorageFileBuilder> createState() => _StorageFileBuilderState();
}

class _StorageFileBuilderState extends State<StorageFileBuilder> {
  late StorageFileController _storageFileController;
  late StorageFileSnapshot snapshot;

  @override
  void initState() {
    snapshot = const StorageFileSnapshot(
      status: StorageFileStatus.loading,
      filePath: null,
      progress: null,
    );

    /// Initializing Widget Logic Controller
    _storageFileController = StorageFileController(
      snapshot: snapshot,
      onSnapshotChanged: (snapshot) {
        if (mounted) {
          setState(() => this.snapshot = snapshot);
        } else {
          this.snapshot = snapshot;
        }
      },
    );

    _initFileDownload();
    super.initState();
  }

  Future<void> _initFileDownload() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      _storageFileController.getFile(
        widget.storagePath,
        cacheDir: widget.cacheDirectory,
        updateDate: widget.updateDate,
      );
    } else {
      // Web implementation
      await _downloadFileForWeb(widget.storagePath);
    }
  }

  Future<void> _downloadFileForWeb(String url) async {
    try {
      // Fetch the file data
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final fileUrl = html.Url.createObjectUrlFromBlob(blob);

        // Simulating a "downloaded" file path for the web
        final simulatedPath = fileUrl;

        // Update the snapshot
        setState(() {
          snapshot = StorageFileSnapshot(
            status: StorageFileStatus.success,
            filePath: simulatedPath,
            progress: null,
          );
        });
      } else {
        setState(() {
          snapshot = StorageFileSnapshot(
            status: StorageFileStatus.error,
            filePath: null,
            progress: null,
          );
        });
      }
    } catch (e) {
      setState(() {
        snapshot = StorageFileSnapshot(
          status: StorageFileStatus.error,
          filePath: null,
          progress: null,
        );
      });
    }
  }

  @override
  void dispose() {
    _storageFileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
          context,
          snapshot,
        ) ??
        const SizedBox();
  }
}
