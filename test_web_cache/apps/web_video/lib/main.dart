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
        'https://videos.pexels.com/video-files/6554025/6554025-uhd_2560_1440_24fps.mp4';
    final opfsFileName = storagePath.split('/').last;
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
              if(snapshot.status==StorageFileStatus.error){
               debugPrint("Network error ! Displaying from opfs : $opfsFileName");
              }
              return snapshot.status == StorageFileStatus.loading
                  ? const CircularProgressIndicator()
                  : AssessmentVideoPlayer(opfsFileName,
                      cursorStreamController: cursorStreamController);
            },
            updateDate: (DateTime.now()),
          ),
        ),
      ),
    );
  }
}
