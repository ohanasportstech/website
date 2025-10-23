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
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 180, maxWidth: 520),
        curve: Curves.easeOut,
        transform: _hovering ? (Matrix4.identity()..scaleByDouble(1.02, 1.02, 1.02, 1.0)) : Matrix4.identity(),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(widget.image, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Text(widget.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Text(widget.body, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
