import 'package:flutter/material.dart';
import 'package:web_video/video_player_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Video Player'),
        ),
        body: const VideoPlayerScreen(
            videoUrl:
                'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4'),
      ),
    );
  }
}
