// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui_web' as ui; // for platformViewRegistry on web
import 'dart:js_interop'; // for JSPromise.toDart
import 'package:web/web.dart' as html; // web-only

class LoopVideo extends StatelessWidget {
  final String assetName;
  const LoopVideo({super.key, required this.assetName});

  static final Set<String> _registered = <String>{};

  void _ensureRegistered(String viewType, String srcUrl) {
    if (_registered.contains(viewType)) return;
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final el = html.HTMLVideoElement()
        ..src = srcUrl
        ..autoplay = true
        ..muted = true
        ..loop = true
        ..controls = false
        ..preload = 'metadata'
        ..setAttribute('playsinline', 'true')
        ..setAttribute('muted', '')
        ..setAttribute('autoplay', '')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.objectPosition = 'center';
      // Try to start playback when ready (in case autoplay policy requires a programmatic call)
      el.onCanPlay.first.then((_) {
        el.play().toDart.catchError((_) => null);
      });
      return el;
    });
    _registered.add(viewType);
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    if (!kIsWeb) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          height: 200,
          decoration: BoxDecoration(color: Colors.black12, borderRadius: borderRadius),
        ),
      );
    }

    final srcUrl = '${Uri.base.origin}/assets/$assetName';
    final viewType = 'loop_video_${assetName.hashCode}';
    _ensureRegistered(viewType, srcUrl);

    return HtmlElementView(viewType: viewType);
  }
}
