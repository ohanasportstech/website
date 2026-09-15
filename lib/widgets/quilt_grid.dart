import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class QuiltGridItem {
  final String title;
  final String description;
  final String image;
  final VoidCallback? onTap;

  const QuiltGridItem({required this.title, required this.description, required this.image, this.onTap});
}

class QuiltGrid extends StatelessWidget {
  final String header;
  final String subHeader;
  final List<QuiltGridItem> items;
  final double spacing;
  final bool isMobile;

  const QuiltGrid({
    super.key,
    required this.items,
    required this.header,
    required this.subHeader,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header and subheader
        Text(header, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(
          subHeader,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: _buildCard(context, item, true),
          ),
        ),
      ],
    );
  }

  Widget _buildQuiltLayout(BuildContext context, BoxConstraints constraints) {
    if (items.isEmpty) return const SizedBox.shrink();

    final n = items.length;
    final columnWidths = <int, TableColumnWidth>{};
    for (var i = 0; i < n; i++) {
      columnWidths[i * 2] = const FlexColumnWidth();
      if (i < n - 1) columnWidths[i * 2 + 1] = FixedColumnWidth(spacing);
    }
    final descGroup = AutoSizeGroup();

    List<Widget> rowCells(List<Widget> cells) {
      final children = <Widget>[];
      for (var i = 0; i < cells.length; i++) {
        children.add(cells[i]);
        if (i < cells.length - 1) children.add(SizedBox(width: spacing));
      }
      return children;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header and subheader
        Text(header, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(
          subHeader,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 40),
        Table(
          columnWidths: columnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            TableRow(children: rowCells(items.map((item) => _titleCell(context, item)).toList())),
            TableRow(children: rowCells(items.map((item) => _imageCell(context, item)).toList())),
            TableRow(children: rowCells(items.map((item) => _descCell(context, item, descGroup)).toList())),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, QuiltGridItem item, bool isMobile) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 18 : 20),
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          AspectRatio(aspectRatio: 1, child: Image.asset(item.image, fit: BoxFit.cover)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 20 : 24),
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleCell(BuildContext context, QuiltGridItem item) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          left: BorderSide(color: colors.outlineVariant),
          top: BorderSide(color: colors.outlineVariant),
          right: BorderSide(color: colors.outlineVariant),
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0, child: Text(' \n ', maxLines: 2, style: style)),
          Text(item.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: style),
        ],
      ),
    );
  }

  Widget _imageCell(BuildContext context, QuiltGridItem item) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          left: BorderSide(color: colors.outlineVariant),
          right: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: AspectRatio(aspectRatio: 1, child: Image.asset(item.image, fit: BoxFit.cover)),
    );
  }

  Widget _descCell(BuildContext context, QuiltGridItem item, AutoSizeGroup group) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant, height: 1.55);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          left: BorderSide(color: colors.outlineVariant),
          bottom: BorderSide(color: colors.outlineVariant),
          right: BorderSide(color: colors.outlineVariant),
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Opacity(opacity: 0, child: Text(' \n \n ', maxLines: 3, style: style)),
          AutoSizeText(
            item.description,
            textAlign: TextAlign.center,
            maxLines: 3,
            group: group,
            minFontSize: 12,
            style: style,
          ),
        ],
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
