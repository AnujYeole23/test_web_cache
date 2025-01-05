import 'dart:async';

import 'package:flutter/material.dart';
import 'package:storage_manager/storage_manager.dart';
import 'package:web_video/video_player_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const storagePath =
    'https://videos.pexels.com/video-files/29713297/12776318_2560_1440_30fps.mp4';
    final StreamController<double?> cursorStreamController =
        StreamController<double?>();
    return MaterialApp(
      home: Center(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Video Player Demo'),
          ),
          body: StorageFileBuilder(
                storagePath: storagePath,
                builder: (context, snapshot) {
                  if (snapshot.status == StorageFileStatus.loading) {
                    return const  CircularProgressIndicator();
                  }
                  if (snapshot.status == StorageFileStatus.success) {
                    return AssessmentVideoPlayer(
                      snapshot.filePath!,
                      cursorStreamController: cursorStreamController,
                    );
                  }
                  return const Text('Error!');
                },updateDate: DateTime(2024, 1, 1),
              ),
        ),
      ),
    );
  }
}