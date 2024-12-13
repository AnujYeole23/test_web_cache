import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:universal_io/io.dart';
import 'package:video_player/video_player.dart';

class AssessmentVideoPlayer extends StatefulWidget {
  const AssessmentVideoPlayer(
    this.videoResource, {
    required this.cursorStreamController,
    super.key,
  });

  final String videoResource;
  final StreamController<double?> cursorStreamController;

  @override
  State<StatefulWidget> createState() => _AssessmentVideoState();
}

class _AssessmentVideoState extends State<AssessmentVideoPlayer> {
  VideoPlayerController? controller;
  ChewieController? chewieController;

  Timer? positionUpdateTimer;

  bool isInitialising = false;
  bool isInitialised = false;

  Duration? _lastPosition;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    if (isInitialising) {
      return;
    }

    if (isInitialised) {
      setState(() {
        isInitialised = false;
      });
      deintVideo();
    }

    isInitialising = true;

    if (kIsWeb) {
      final opfsHelper = OpfsHelper();
      final videoUrl = await opfsHelper.readFileFromOPFS(widget.videoResource);
      if (videoUrl != null) {
        controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      }
    } else {
      controller = VideoPlayerController.file(File(widget.videoResource));
    }

    if (controller == null) {
      return;
    }

    await controller?.setLooping(true);
    await controller?.initialize();

    chewieController = ChewieController(
      videoPlayerController: controller!,
      aspectRatio: 1 / 1,
      allowPlaybackSpeedChanging: false,
      looping: true,
      showOptions: false,
    );

    positionUpdateTimer =
        Timer.periodic(const Duration(milliseconds: 33), (_) async {
      final position = await controller?.position;
      if (position == null) {
        return;
      }
      if (position == _lastPosition) {
        return;
      }
      _lastPosition = position;
      widget.cursorStreamController.add(
        position.inMilliseconds.toDouble() / 1000,
      );
    });

    setState(() {
      isInitialised = true;
    });

    isInitialising = false;
  }

  void deintVideo() {
    positionUpdateTimer?.cancel();
    positionUpdateTimer = null;
    chewieController?.dispose();
    chewieController = null;
    controller?.dispose();
    controller = null;
  }

  @override
  void dispose() {
    deintVideo();
    super.dispose();
  }

  Widget videoChild() {
    if (!isInitialised) {
      return const SizedBox();
    }

    if (chewieController == null) {
      return const SizedBox();
    }
    return Chewie(
      controller: chewieController!,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialised) {
      return const Text('Loading Screen ***********');
    }
    if (chewieController == null) {
      return const SizedBox();
    }
    return Chewie(
      controller: chewieController!,
    );
  }
}
