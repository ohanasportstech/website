import 'package:flutter/material.dart';

class TripleCapItem {
  final String title;
  final String description;
  final String heroImage;
  final VoidCallback? onTap;

  const TripleCapItem({
    required this.title,
    required this.description,
    required this.heroImage,
    this.onTap,
  });
}

class TripleCap extends StatefulWidget {
  final List<TripleCapItem> items;

  const TripleCap({
    super.key,
    required this.items,
  })  : assert(items.length == 3, 'Must provide exactly 3 items');

  @override
  State<TripleCap> createState() => _TripleCapState();
}

class _TripleCapState extends State<TripleCap> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Full-width hero image at top
        AspectRatio(
          aspectRatio: 16 / 9,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: ClipRect(
              child: Image.asset(
                widget.items[_selectedIndex].heroImage,
                key: ValueKey<int>(_selectedIndex),
                fit: BoxFit.cover, // maintain aspect while filling 16:9, cropping as needed
                alignment: Alignment.center,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 64,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Three column caption section at bottom
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            widget.items.length,
            (index) => _buildColumn(
              context,
              index,
              widget.items[index],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(
    BuildContext context,
    int index,
    TripleCapItem item,
  ) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          item.onTap?.call();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isSelected ? 1.0 : 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
