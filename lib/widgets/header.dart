// MARK: Mobile AppBar
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:website/strings.dart';

class MobileAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onCtaPressed;
  final double height;

  const MobileAppBar({
    super.key,
    this.onCtaPressed,
    this.height = 56.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);
  
  @override
  State<MobileAppBar> createState() => _MobileAppBarState();
}

class _MobileAppBarState extends State<MobileAppBar> {
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey[300],
          height: 1.0,
        ),
      ),
      flexibleSpace: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        child: ClipRect(
          child: Container(
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        Strings.navMain,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: FilledButton(
            onPressed: widget.onCtaPressed,
            child: Text(
              Strings.navCTA,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: Glass Header
class GlassHeader extends StatelessWidget {
  final VoidCallback? onCtaPressed;
  final VoidCallback? onClubsPressed;
  final VoidCallback? onPlayersPressed;
  final VoidCallback? onHowItWorksPressed;
  final VoidCallback? onLogoPressed;
  const GlassHeader({super.key, this.onCtaPressed, this.onClubsPressed, this.onPlayersPressed, this.onHowItWorksPressed, this.onLogoPressed});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8, left: 0, right: 0,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1220),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate required width for navigation items
                        final textPainter = TextPainter(
                          text: TextSpan(
                            text: '${Strings.nav1}  ${Strings.nav2}  ${Strings.nav3}  ${Strings.nav4}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                          ),
                          textDirection: TextDirection.ltr,
                        );
                        textPainter.layout();
                        
                        // Add some padding (16px per item for padding and margins)
                        final totalWidth = textPainter.width + (4 * 16);
                        final hasEnoughSpace = constraints.maxWidth * 0.50 > totalWidth;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              // Logo
                              GestureDetector(
                                onTap: onLogoPressed,
                                child: Text(
                                  Strings.navMain, 
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Spacer(),
                              
                              // Navigation items
                              if (hasEnoughSpace) ...[
                                SizedBox(
                                  width: constraints.maxWidth * 0.50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                    TextButton(
                                      onPressed: onHowItWorksPressed,
                                      child: Text(Strings.nav1, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: onClubsPressed,
                                      child: Text(Strings.nav2, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: onPlayersPressed,
                                      child: Text(Strings.nav3, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pushNamed('/about'),
                                      child: Text(Strings.nav4, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                                    ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // CTA button
                              FilledButton(
                                onPressed: onCtaPressed, 
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6.0),
                                  child: Text(Strings.navCTA, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
