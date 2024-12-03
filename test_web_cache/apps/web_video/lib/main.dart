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
        'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4';
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
