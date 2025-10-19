import 'package:flutter/material.dart';

class CarouselItem {
  final String title;
  final String description;
  final String image;

  const CarouselItem({
    required this.title,
    required this.description,
    required this.image,
  });
}

class Carousel extends StatefulWidget {
  final List<CarouselItem> items;
  final bool isMobile;

  const Carousel({
    super.key,
    required this.items,
    required this.isMobile,
  }) : assert(items.length > 0, 'Must provide at least one carousel item');

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _direction = 1; // 1 = next (right to left), -1 = previous (left to right)
  int? _previousIndex;
  bool _hadPrevBefore = false;
  bool _hadNextBefore = false;
  final double _peekOpacity = 0.3;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _outFadeAnimation;
  late Animation<double> _outScaleAnimation;
  late Animation<AlignmentGeometry> _outgoingAlignAnimation; // center -> side peek
  late Animation<double> _peekFadeAnimation; // fades in to 0.4
  late Animation<Offset> _peekSlideAnimation; // slides from offscreen to peek spot
  late Animation<AlignmentGeometry> _incomingAlignAnimation; // from side peek to center
  late Animation<EdgeInsets> _incomingPadding; // side peek padding -> zero
  late Animation<EdgeInsets> _outgoingPadding; // zero -> side peek padding
  late Animation<double> _peekOutFadeAnimation; // fades out from 0.4 -> 0
  late Animation<Offset> _peekOutSlideAnimation; // slides from peek spot to offscreen

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _configureAnimations();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted && _previousIndex != null) {
          setState(() {
            _previousIndex = null;
          });
        }
      }
    });
    _animationController.forward();
  }

  void _configureAnimations() {
    // Incoming current image fades from peek opacity to full
    _fadeAnimation = Tween<double>(begin: _peekOpacity, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Incoming current image aligns from the side peek to center
    _incomingAlignAnimation = AlignmentTween(
      begin: _direction == 1 ? Alignment.centerRight : Alignment.centerLeft,
      end: Alignment.center,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Animate padding along with alignment so start/end match peek layout exactly
    final incomingStartPadding = _direction == 1
        ? const EdgeInsets.only(left: 20.0)   // starting from right peek (uses left padding)
        : const EdgeInsets.only(right: 20.0); // starting from left peek (uses right padding)
    _incomingPadding = EdgeInsetsTween(
      begin: incomingStartPadding,
      end: EdgeInsets.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Incoming current image scales from peek size to full
    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Outgoing image animations (demote to side peek)
    _outFadeAnimation = Tween<double>(begin: 1.0, end: _peekOpacity).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    // Keep outgoing size constant; we'll render it at the peek width to avoid rounding mismatch
    _outScaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _outgoingAlignAnimation = AlignmentTween(
      begin: Alignment.center,
      end: _direction == 1 ? Alignment.centerLeft : Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Outgoing padding animates to the destination peek padding
    final outgoingEndPadding = _direction == 1
        ? const EdgeInsets.only(right: 20.0)  // demoting to left peek (uses right padding)
        : const EdgeInsets.only(left: 20.0);  // demoting to right peek (uses left padding)
    _outgoingPadding = EdgeInsetsTween(
      begin: EdgeInsets.zero,
      end: outgoingEndPadding,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Incoming side peek animation (element 2 when moving forward, element 0 when moving back)
    _peekFadeAnimation = Tween<double>(begin: 0.0, end: _peekOpacity).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _peekSlideAnimation = Tween<Offset>(
      begin: Offset(0.6 * _direction, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    // Outgoing side peek animation (opposite side): slide out and fade out
    _peekOutFadeAnimation = Tween<double>(begin: _peekOpacity, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _peekOutSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-0.6 * _direction, 0.0), // move opposite to incoming
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentIndex < widget.items.length - 1) {
      _direction = 1;
      _configureAnimations();
      _animationController.reset();
      setState(() {
        _hadPrevBefore = _currentIndex > 0;
        _hadNextBefore = _currentIndex < widget.items.length - 1;
        _previousIndex = _currentIndex;
        _currentIndex++;
      });
      _animationController.forward();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _direction = -1;
      _configureAnimations();
      _animationController.reset();
      setState(() {
        _hadPrevBefore = _currentIndex > 0;
        _hadNextBefore = _currentIndex < widget.items.length - 1;
        _previousIndex = _currentIndex;
        _currentIndex--;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final currentItem = widget.items[_currentIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: widget.isMobile ? _buildMobileLayout(currentItem, color) : _buildDesktopLayout(currentItem, color),
        );
      },
    );
  }

  Widget _buildDesktopLayout(CarouselItem currentItem, ColorScheme color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side - Text content
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextContent(currentItem, fixedHeight: 220),
              const SizedBox(height: 32),
              _buildControls(color),
            ],
          ),
        ),
        // Right side - Phone image
        Expanded(
          flex: 3,
          child: _buildPhoneImage(currentItem),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(CarouselItem currentItem, ColorScheme color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildPhoneImage(currentItem),
        const SizedBox(height: 32),
        _buildTextContent(currentItem, fixedHeight: 140),
        const SizedBox(height: 24),
        _buildControls(color, center: true),
      ],
    );
  }

  Widget _buildTextContent(CarouselItem currentItem, {required double fixedHeight}) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SizedBox(
            height: fixedHeight,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentItem.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentItem.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneImage(CarouselItem currentItem) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final hasNext = _currentIndex < widget.items.length - 1;
            final hasPrev = _currentIndex > 0;
            final nextItem = hasNext ? widget.items[_currentIndex + 1] : null;
            final prevItem = hasPrev ? widget.items[_currentIndex - 1] : null;

            // Determine the FORMER peek (the one that should animate OUT) based on previous index and direction
            int? outgoingPeekIndex;
            if (_previousIndex != null) {
              if (_direction == 1) {
                // Moving forward: old LEFT peek was at previousIndex - 1
                final idx = _previousIndex! - 1;
                outgoingPeekIndex = idx >= 0 ? idx : null;
              } else {
                // Moving backward: old RIGHT peek was at previousIndex + 1
                final idx = _previousIndex! + 1;
                outgoingPeekIndex = idx < widget.items.length ? idx : null;
              }
            }
            final String? outgoingPeekImage =
                outgoingPeekIndex != null ? widget.items[outgoingPeekIndex].image : null;

            // Responsive sizing: scale with available width but keep reasonable bounds
            final maxW = constraints.maxWidth;
            final baseCurrentWidth = (maxW * 0.6);
            final baseNextWidth = (baseCurrentWidth * 0.75);
            final double? currentMaxHeight = widget.isMobile ? 460.0 : null;
            final double? peekMaxHeight = widget.isMobile ? 300.0 : null;

            // Fix container height on mobile so content below doesn't shift during animations
            final containerHeight = widget.isMobile
                ? (currentMaxHeight ?? 460.0)
                : null; // desktop can be intrinsic

            return SizedBox(
              height: containerHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                if (hasPrev)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: _animationController.isAnimating && _direction == 1 && _hadPrevBefore && outgoingPeekImage != null
                          // Forward: left peek is outgoing -> animate out
                          ? Transform.translate(
                              offset: Offset(_peekOutSlideAnimation.value.dx * constraints.maxWidth, 0),
                              child: Opacity(
                                opacity: _peekOutFadeAnimation.value,
                                child: Image.asset(
                                  outgoingPeekImage,
                                  width: baseNextWidth,
                                  height: peekMaxHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : (_animationController.isAnimating && _direction == -1)
                              // Backward: left peek is incoming -> animate in
                              ? Transform.translate(
                                  offset: Offset(_peekSlideAnimation.value.dx * constraints.maxWidth, 0),
                                  child: Opacity(
                                    opacity: _peekFadeAnimation.value,
                                    child: Image.asset(
                                      prevItem!.image,
                                      width: baseNextWidth,
                                      height: peekMaxHeight,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                              // Idle/static
                              : (_animationController.isAnimating && _direction == 1 && !_hadPrevBefore)
                                  // No old left peek existed; show nothing while central demotes into place
                                  ? const SizedBox.shrink()
                                  : Opacity(
                                      opacity: _peekOpacity,
                                      child: Image.asset(
                                        prevItem!.image,
                                        width: baseNextWidth,
                                        height: peekMaxHeight,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                    ),
                  ),
                if (hasNext)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: _animationController.isAnimating && _direction == -1 && _hadNextBefore && outgoingPeekImage != null
                          // Backward: right peek is outgoing -> animate out
                          ? Transform.translate(
                              offset: Offset(_peekOutSlideAnimation.value.dx * constraints.maxWidth, 0),
                              child: Opacity(
                                opacity: _peekOutFadeAnimation.value,
                                child: Image.asset(
                                  outgoingPeekImage,
                                  width: baseNextWidth,
                                  height: peekMaxHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : (_animationController.isAnimating && _direction == 1)
                              // Forward: right peek is incoming -> animate in
                              ? Transform.translate(
                                  offset: Offset(_peekSlideAnimation.value.dx * constraints.maxWidth, 0),
                                  child: Opacity(
                                    opacity: _peekFadeAnimation.value,
                                    child: Image.asset(
                                      nextItem!.image,
                                      width: baseNextWidth,
                                      height: peekMaxHeight,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                              // Idle/static
                              : (_animationController.isAnimating && _direction == -1 && !_hadNextBefore)
                                  // No old right peek existed; show nothing while central demotes into place
                                  ? const SizedBox.shrink()
                                  : Opacity(
                                      opacity: _peekOpacity,
                                      child: Image.asset(
                                        nextItem!.image,
                                        width: baseNextWidth,
                                        height: peekMaxHeight,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                    ),
                  ),
                if (_previousIndex != null)
                  AlignTransition(
                    alignment: _outgoingAlignAnimation,
                    child: AnimatedBuilder(
                      animation: _outgoingPadding,
                      builder: (context, child) {
                        return Padding(
                          padding: _outgoingPadding.value,
                          child: child,
                        );
                      },
                      child: Transform.scale(
                        scale: _outScaleAnimation.value,
                        child: Opacity(
                          opacity: _outFadeAnimation.value,
                          child: Image.asset(
                            widget.items[_previousIndex!].image,
                            width: baseNextWidth,
                            height: peekMaxHeight,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                AlignTransition(
                  alignment: _incomingAlignAnimation,
                  child: AnimatedBuilder(
                    animation: _incomingPadding,
                    builder: (context, child) {
                      return Padding(
                        padding: _incomingPadding.value,
                        child: child,
                      );
                    },
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Image.asset(
                          currentItem.image,
                          width: baseCurrentWidth,
                          height: currentMaxHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControls(ColorScheme color, {bool center = false}) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Dots indicator
        Row(
          mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: List.generate(
            widget.items.length,
            (index) => Container(
              margin: const EdgeInsets.only(right: 24, bottom: 12),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? color.onSurface
                    : color.onSurface.withValues(alpha: _peekOpacity),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Navigation arrows beneath the dots
        Row(
          mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            _buildArrowButton(
              icon: Icons.arrow_back,
              onPressed: _currentIndex > 0 ? _goToPrevious : null,
              color: color,
            ),
            const SizedBox(width: 24),
            _buildArrowButton(
              icon: Icons.arrow_forward,
              onPressed: _currentIndex < widget.items.length - 1 ? _goToNext : null,
              color: color,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required ColorScheme color,
  }) {
    final isEnabled = onPressed != null;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled
                ? color.onSurface
                : color.onSurface.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? color.onSurface
              : color.onSurface.withValues(alpha: _peekOpacity),
        ),
      ),
    );
  }
}
