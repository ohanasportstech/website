import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Reveal extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const Reveal({super.key, required this.child, this.delayMs = 0});

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  final _visKey = UniqueKey();
  bool _shown = false;
  bool _scheduled = false;

  void _trigger() {
    if (_scheduled || _shown) return;
    _scheduled = true;
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1) {
          _trigger();
        }
      },
      child: AnimatedSlide(
        offset: _shown ? Offset.zero : Offset(0, 0.06),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _shown ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
