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
  bool _enqueued = false;
  bool _visible = false;
  static final List<_RevealState> _queue = <_RevealState>[];
  static bool _processing = false;
  static int _nextId = 0;
  final int _id = _nextId++;
  double _lastY = double.infinity;
  static bool _pumpScheduled = false;
  static final Set<_RevealState> _all = <_RevealState>{};
  static const double _visibleOn = 0.01;  // 1% visible marks as visible
  static const double _visibleOff = 0.001; // <0.1% marks as not visible

  @override
  void initState() {
    super.initState();
    _all.add(this);
    // If already on-screen at first frame, make sure we run a pump
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VisibilityDetectorController.instance.notifyNow();
      _schedulePump();
    });
  }

  @override
  void dispose() {
    _all.remove(this);
    super.dispose();
  }

  void _updateY() {
    try {
      final render = context.findRenderObject();
      if (render is RenderBox && render.attached) {
        final dy = render.localToGlobal(Offset.zero).dy;
        _lastY = dy;
      }
    } catch (_) {
      _lastY = double.infinity;
    }
  }

  static void _schedulePump() {
    if (_processing || _pumpScheduled) return;
    _pumpScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Small delay to allow other VisibilityDetector callbacks in the same frame
      await Future<void>.delayed(const Duration(milliseconds: 16));
      _pumpScheduled = false;
      _rebuildQueueFromVisible();
      _pumpQueue();
    });
  }

  static void _pumpQueue() async {
    if (_processing) return;
    if (_queue.isEmpty) {
      _rebuildQueueFromVisible();
      if (_queue.isEmpty) return;
    }
    _processing = true;
    while (_queue.isNotEmpty) {
      // Pull in any newly visible items and re-sort before selecting next
      _rebuildQueueFromVisible();
      // Refresh positions and clean queue
      _queue.removeWhere((e) => !e.mounted || e._shown);
      for (final e in _queue) {
        e._updateY();
      }
      _queue.sort((a, b) {
        final cmp = a._lastY.compareTo(b._lastY);
        if (cmp != 0) return cmp;
        return a._id.compareTo(b._id);
      });
      if (_queue.isEmpty) break;
      final item = _queue.removeAt(0);
      await item._startReveal();
      await Future.delayed(const Duration(milliseconds: 500));
    }
    _processing = false;
  }

  static void _rebuildQueueFromVisible() {
    // Add all currently visible, not-shown, not-enqueued items sorted by Y
    final candidates = _all.where((e) => e.mounted && !e._shown && e._visible && !e._enqueued).toList();
    for (final e in candidates) {
      e._updateY();
    }
    candidates.sort((a, b) {
      final cmp = a._lastY.compareTo(b._lastY);
      if (cmp != 0) return cmp;
      return a._id.compareTo(b._id);
    });
    for (final e in candidates) {
      e._enqueued = true;
      _queue.add(e);
    }
  }

  Future<void> _startReveal() async {
    if (_shown) return;
    await Future.delayed(Duration(milliseconds: widget.delayMs));
    if (!mounted || _shown) return;
    setState(() => _shown = true);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: (info) {
        final f = info.visibleFraction;
        // Hysteresis to avoid flicker near the threshold
        if (!_visible && f > _visibleOn) _visible = true;
        if (_visible && f < _visibleOff) _visible = false;
        if (_visible && !_shown) _schedulePump();
      },
      child: AnimatedSlide(
        offset: _shown ? Offset.zero : Offset(0, 0.06),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _shown ? 1 : 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
