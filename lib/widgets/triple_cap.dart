import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'loop_video.dart';

class TripleCapItem {
  final String title;
  final String description;
  final String? heroImage;
  final String? videoPath;
  final VoidCallback? onTap;

  const TripleCapItem({
    required this.title,
    required this.description,
    this.heroImage,
    this.videoPath,
    this.onTap,
  }) : assert(heroImage != null || videoPath != null, 
          'Either heroImage or videoPath must be provided');
}

class TripleCap extends StatefulWidget {
  final String header;
  final String subHeader;
  final List<TripleCapItem> items;
  final bool isMobile;

  const TripleCap({
    super.key,
    required this.header,
    required this.subHeader,
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

  @override void dispose() {
    _swimController.dispose();
    super.dispose();
  }

  Widget _buildContent(TripleCapItem item) {
    if (item.videoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LoopVideo(assetName: item.videoPath!),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        item.heroImage!,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(widget.header, style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 16),
        Text(widget.subHeader, style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 40),

        // Full-width hero content at top
        LayoutBuilder(
          builder: (context, constraints) {
            const targetAspectRatio = 2.2;
            
            return AspectRatio(
              aspectRatio: targetAspectRatio,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                child: _buildContent(widget.items[_selectedIndex]),
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
        padding: const EdgeInsets.all(8.0),
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isMobile ? 18 : null,
                    ),
              ),
              const SizedBox(height: 8),
              // Description with bullet points
              ...item.description.split('\n').map((line) {
                if (line.trim().isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•  ', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: widget.isMobile ? 13 : null,
                        height: widget.isMobile ? 1.35 : null,
                      )),
                      Expanded(
                        child: Text(
                          line,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                            fontSize: widget.isMobile ? 13 : null,
                            height: widget.isMobile ? 1.35 : 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
