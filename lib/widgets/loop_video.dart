import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoopVideo extends StatefulWidget {
  final String assetName;
  const LoopVideo({super.key, required this.assetName});
  @override
  State<LoopVideo> createState() => _LoopVideoState();
}

class _LoopVideoState extends State<LoopVideo> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetName)
      ..setLooping(true)
      ..setVolume(0.0);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _initialized = true);
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    Widget child;
    if (_initialized) {
      child = AspectRatio(
        aspectRatio: _controller.value.aspectRatio == 0 ? 16 / 9 : _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      );
    } else {
      child = Container(
        height: 200,
        decoration: BoxDecoration(color: Colors.black12, borderRadius: borderRadius),
      );
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }
}
