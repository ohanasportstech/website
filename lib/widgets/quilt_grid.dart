import 'package:flutter/material.dart';

class QuiltGridItem {
  final String title;
  final String description;
  final String image;
  final VoidCallback? onTap;

  const QuiltGridItem({
    required this.title,
    required this.description,
    required this.image,
    this.onTap,
  });
}

class QuiltGrid extends StatelessWidget {
  final List<QuiltGridItem> items;
  final double spacing;
  final bool isMobile;

  const QuiltGrid({
    super.key,
    required this.items,
    required this.isMobile,
    this.spacing = 16.0,
    int? crossAxisCount,
    double? aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isMobile) {
          return _buildMobileLayout(context);
        }
        return _buildQuiltLayout(context, constraints);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: _buildCard(context, entry.value, true),
        );
      }).toList(),
    );
  }

  Widget _buildQuiltLayout(BuildContext context, BoxConstraints constraints) {
    // Create a staggered/masonry layout matching the reference design
    
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTextImageCard(context, items[0]),
        _buildImageTextCard(context, items[1]),
        _buildTextImageCard(context, items[2]),
      ],
    );
  }

  Widget _buildTextImageCard(BuildContext context, QuiltGridItem item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tile = (constraints.maxWidth - spacing) / 2 * 0.8;
        return GestureDetector(
          onTap: item.onTap,
          child: Row(
            spacing: spacing,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextCard(size: tile, title: item.title, description: item.description),
              _SquareImage(size: tile, image: item.image),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageTextCard(BuildContext context, QuiltGridItem item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tile = (constraints.maxWidth - spacing) / 2 * 0.8;
        return GestureDetector(
          onTap: item.onTap,
          child: Row(
            spacing: spacing,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SquareImage(size: tile, image: item.image),
              TextCard(size: tile, title: item.title, description: item.description),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, QuiltGridItem item, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 4/3,
              child: Image.asset(
                item.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TextCard extends StatelessWidget {
  final String title;
  final String description;
  final double size;
  const TextCard({
    required this.size,
    required this.title,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _SquareImage extends StatelessWidget {
  final double size;
  final String image;
  const _SquareImage({required this.size, required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Example usage:
/*
QuiltGrid(
  items: [
    QuiltGridItem(
      title: 'Title 1',
      description: 'Description for the first item in the quilt grid.',
      image: 'assets/image1.jpg',
    ),
    QuiltGridItem(
      title: 'Title 2',
      description: 'Description for the second item in the quilt grid.',
      image: 'assets/image2.jpg',
    ),
    // Add more items as needed
  ],
  crossAxisCount: 2, // Number of columns in the grid
  aspectRatio: 1.5, // Aspect ratio of each grid item
  spacing: 16.0, // Spacing between grid items
)
*/
