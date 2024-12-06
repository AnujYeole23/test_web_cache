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
        'https://videos.pexels.com/video-files/6223250/6223250-hd_1920_1080_30fps.mp4';
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Video Player Demo'),
          ),
          body: StorageFileBuilder(storagePath: storagePath,builder: (context, snapshot) {
            return const  VideoPlayerScreen(videoUrl: storagePath);
          },updateDate:(DateTime.now()),),),
    );
  }
}
