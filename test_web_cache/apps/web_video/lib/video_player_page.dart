import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:universal_io/io.dart';
import 'package:video_player/video_player.dart';
import 'dart:html' as html;

class AssessmentVideoPlayer extends StatefulWidget {
  const AssessmentVideoPlayer(
    this.videoResource, {
    this.cursorStreamController,
    super.key,
  });

  final String videoResource;
  final StreamController<double?>? cursorStreamController;

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
    debugPrint('the Video Resourse is : ${widget.videoResource}');


    controller = widget.videoResource.startsWith('https') ||
            widget.videoResource.startsWith('blob')
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoResource))
        : VideoPlayerController.file(File(widget.videoResource));


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
      widget.cursorStreamController?.add(
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
      return const Center(child: CircularProgressIndicator());
    }
    if (chewieController == null) {
      return const SizedBox();
    }
    return Chewie(
      controller: chewieController!,
    );
  }
}

