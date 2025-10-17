import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  final bool isMobile;

  const TripleCap({
    super.key,
    required this.items,
    required this.isMobile,
  })  : assert(items.length == 3, 'Must provide exactly 3 items');

  @override
  State<TripleCap> createState() => _TripleCapState();
}

class _TripleCapState extends State<TripleCap> {
  int _selectedIndex = 0;
  final ScrollController _swimController = ScrollController();
  final List<GlobalKey> _itemKeys = List.generate(3, (_) => GlobalKey());

  void _scrollItemIntoView(int index) {
    final ctx = _itemKeys[index].currentContext;
    if (ctx == null) return;
    final target = ctx.findRenderObject();
    if (target == null) return;
    final viewport = RenderAbstractViewport.of(target);

    final leading = viewport.getOffsetToReveal(target, 0.0).offset;
    final trailing = viewport.getOffsetToReveal(target, 1.0).offset;
    final viewSize = _swimController.position.viewportDimension;
    // getOffsetToReveal(target, 1.0) returns the scroll offset where the item's trailing aligns
    // with the viewport's trailing, thus itemExtent = trailing - leading + viewSize.
    final itemExtent = (trailing - leading + viewSize).abs();

    // Prefer centering the item when it fits; otherwise align its leading edge
    double desired;
    if (itemExtent >= viewSize) {
      desired = leading;
    } else {
      // Center: midway between the offsets that align leading and trailing
      desired = (leading + trailing) / 2.0;
    }

    desired = desired.clamp(
      _swimController.position.minScrollExtent,
      _swimController.position.maxScrollExtent,
    );

    _swimController.animateTo(
      desired,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _swimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Full-width hero image at top
        LayoutBuilder(
          builder: (context, constraints) {
            // Define the target aspect ratio (16:9)
            const targetAspectRatio = 16 / 9;
            
            return AspectRatio(
              aspectRatio: targetAspectRatio,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                child: Container(
                  key: ValueKey<int>(_selectedIndex),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.items[_selectedIndex].heroImage),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // Caption section: three columns on desktop, swimlane on mobile using single source isMobile
        if (widget.isMobile)
          SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _swimController,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  for (int index = 0; index < widget.items.length; index++) ...[
                    Container(
                      key: _itemKeys[index],
                      child: _buildColumn(context, index, widget.items[index], mobile: true),
                    ),
                    if (index != widget.items.length - 1) const SizedBox(width: 12),
                  ],
                  const SizedBox(width: 8),
                ],
              ),
            ),
          )
        else
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
    {bool mobile = false}
  ) {
    final bool isSelected = _selectedIndex == index;

    final content = InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        item.onTap?.call();
        if (mobile) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollItemIntoView(index));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isSelected ? 1.0 : 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isMobile ? 18 : null,
                    ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: widget.isMobile ? 13 : null,
                      height: widget.isMobile ? 1.35 : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );

    if (mobile) {
      final double halfScreen = MediaQuery.of(context).size.width * 0.5;
      return SizedBox(
        width: halfScreen,
        child: content,
      );
    }

    return Expanded(child: content);
  }
}
