import 'package:flutter/material.dart';
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
        // Set inline/muted before src for iOS policies
        ..muted = true
        ..defaultMuted = true
        ..setAttribute('muted', '')
        ..setAttribute('playsinline', '')
        ..setAttribute('webkit-playsinline', '')
        ..setAttribute('x5-playsinline', '')
        ..autoplay = true
        ..setAttribute('autoplay', '')
        ..loop = true
        ..controls = false
        ..preload = 'metadata'
        ..src = srcUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.objectPosition = 'center'
        ..setAttribute('disablepictureinpicture', '')
        ..setAttribute('controlsList', 'nodownload noplaybackrate noremoteplayback');
      // Try to start playback when ready and add a quick retry
      void tryPlay() {
        el.play().toDart.catchError((_) => null);
      }
      el.onLoadedData.first.then((_) => tryPlay());
      el.onCanPlay.first.then((_) => tryPlay());
      // One-shot delayed retry for Safari quirks
      Future.delayed(const Duration(milliseconds: 300), tryPlay);
      return el;
    });
    _registered.add(viewType);
  }

  @override
  Widget build(BuildContext context) {
    final srcUrl = '${Uri.base.origin}/assets/$assetName';
    final viewType = 'loop_video_${assetName.hashCode}';
    _ensureRegistered(viewType, srcUrl);

    return HtmlElementView(viewType: viewType);
  }
}
