import 'package:flutter/material.dart';

class ImageCard extends StatefulWidget {
  final String title;
  final String body;
  final String image;
  const ImageCard({required this.title, required this.body, required this.image, super.key});
  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 180),
        curve: Curves.easeOut,
        transform: _hovering ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        width: 340,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest.withValues(alpha: _hovering ? 0.92 : 1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.outlineVariant),
          boxShadow: _hovering
              ? [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, spreadRadius: 0, offset: const Offset(0, 12)),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(widget.image, width: 32, height: 32),
            const SizedBox(height: 12),
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(widget.body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
