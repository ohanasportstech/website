import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/reveal.dart';
import '../widgets/card.dart';
import '../widgets/triple_cap.dart';
import '../widgets/carousel.dart';
import '../widgets/quilt_grid.dart';
import '../widgets/loop_video.dart';
import '../strings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController _scrollController;
  double _scroll = 0;
  final GlobalKey _getAppKey = GlobalKey();
  final GlobalKey _clubsKey = GlobalKey();
  final GlobalKey _playersKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() => _scroll = _scrollController.position.pixels);
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // MARK: Section layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _MaxWidth(child: _HeroSection(isMobile: isMobile, scroll: _scroll))),
                  SliverToBoxAdapter(child: _MaxWidth(child: Reveal(child: _MeetKaiSection(isMobile: isMobile)))),
                  SliverToBoxAdapter(child: _MaxWidth(child: Reveal(child: _CarouselSection(isMobile: isMobile)))),
                  SliverToBoxAdapter(child: _MaxWidth(child: Reveal(child: _SkillLevelsSection(key: _playersKey, isMobile: isMobile)))),
                  SliverToBoxAdapter(child: _MaxWidth(child: Reveal(child: _ClubsCollegesSection(key: _clubsKey, isMobile: isMobile)))),
                  SliverToBoxAdapter(child: _MaxWidth(child: Reveal(child: _HowItWorksSection(key: _howItWorksKey, isMobile: isMobile)))),
                  SliverToBoxAdapter(child: _MaxWidth(child: Reveal(child: _TestimonialsSection(isMobile: isMobile)))),
                  SliverToBoxAdapter(child: _MaxWidth(child: Reveal(child: _FaqSection(isMobile: isMobile)))),
                  SliverToBoxAdapter(child: _MaxWidth(child: Reveal(child: _GetTheAppSection(key: _getAppKey)))) ,
                  SliverToBoxAdapter(child: _MaxWidth(child: _Footer())),
                ],
              ),
              _GlassHeader(
                isMobile: isMobile,
                scroll: _scroll,
                onLogoPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                  );
                },
                onCtaPressed: () {
                  final ctx = _getAppKey.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(
                      ctx,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                    );
                  }
                },
                onHowItWorksPressed: () {
                  final ctx = _howItWorksKey.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(
                      ctx,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                      alignment: 0.2,
                    );
                  }
                },
                onClubsPressed: () {
                  final ctx = _clubsKey.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(
                      ctx,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                      alignment: -0.4,
                    );
                  }
                },
                onPlayersPressed: () {
                  final ctx = _playersKey.currentContext;
                  if (ctx != null) {
                    Scrollable.ensureVisible(
                      ctx,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                      alignment: 0.4,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// MARK: Glass Header
class _GlassHeader extends StatelessWidget {
  final bool isMobile;
  final double scroll;
  final VoidCallback? onCtaPressed;
  final VoidCallback? onClubsPressed;
  final VoidCallback? onPlayersPressed;
  final VoidCallback? onHowItWorksPressed;
  final VoidCallback? onLogoPressed;
  const _GlassHeader({required this.isMobile, required this.scroll, this.onCtaPressed, this.onClubsPressed, this.onPlayersPressed, this.onHowItWorksPressed, this.onLogoPressed});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8, left: 0, right: 0,
      child: SafeArea(
        child: Opacity(
          opacity: isMobile ? (1.0 - (scroll / 300.0)).clamp(0.0, 1.0) : 1.0,
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
      ),
    );
  }
}


EdgeInsets _sectionPadding(bool isMobile) =>
    EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: isMobile ? 24 : 60);

class _MaxWidth extends StatelessWidget {
  final Widget child;
  const _MaxWidth({required this.child});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: child,
      ),
    );
  }
}

// MARK: Hero
class _HeroSection extends StatelessWidget {
  final bool isMobile;
  final double scroll;
  const _HeroSection({required this.isMobile, required this.scroll});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16/9,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              // translate video to center the court in the overhead scene
              child: FractionalTranslation(
                translation: const Offset(-0.04, 0),
                child: Transform.scale(
                  scale: 1.08,
                  child: const LoopVideo(assetName: 'assets/images/hero.mp4'),
                ),
              ),
            ),
            if (!isMobile) ...[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 180,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _sectionPadding(isMobile).left,
                    ),
                    child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              Strings.heroHeader,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              Strings.heroDesc,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 45),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ],
        ),
      ),
    );
  }
}

// MARK: Meet Kai
class _MeetKaiSection extends StatelessWidget {
  final bool isMobile;
  const _MeetKaiSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _sectionPadding(isMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(Strings.meetHeader, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 22),
            Text(Strings.meetDesc, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 66),
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth.clamp(0.0, 520.0);
                        return SizedBox(
                          width: w,
                          child: const ImageCard(
                            title: Strings.meetCardTitle1,
                            body: Strings.meetCardBody1,
                            image: 'assets/images/meet_kai1.jpg',
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth.clamp(0.0, 520.0);
                        return SizedBox(
                          width: w,
                          child: const ImageCard(
                            title: Strings.meetCardTitle2,
                            body: Strings.meetCardBody2,
                            image: 'assets/images/meet_kai2.jpg',
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth.clamp(0.0, 520.0);
                        return SizedBox(
                          width: w,
                          child: const ImageCard(
                            title: Strings.meetCardTitle3,
                            body: Strings.meetCardBody3,
                            image: 'assets/images/meet_kai3.jpg',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: ImageCard(
                      title: Strings.meetCardTitle1,
                      body: Strings.meetCardBody1,
                      image: 'assets/images/meet_kai1.jpg',
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: ImageCard(
                      title: Strings.meetCardTitle2,
                      body: Strings.meetCardBody2,
                      image: 'assets/images/meet_kai2.jpg',
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: ImageCard(
                      title: Strings.meetCardTitle3,
                      body: Strings.meetCardBody3,
                      image: 'assets/images/meet_kai3.jpg',
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

// MARK: How it Works
class _HowItWorksSection extends StatelessWidget {
  final bool isMobile;
  const _HowItWorksSection({super.key, required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container
      (
      padding: _sectionPadding(isMobile),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 20,
              children: [
                Text(Strings.howHeader, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                const _Step(number: '1', title: Strings.how1Title, desc: Strings.how1Desc),
                const _Step(number: '2', title: Strings.how2Title, desc: Strings.how2Desc),
                const _Step(number: '3', title: Strings.how3Title, desc: Strings.how3Desc),
              ],
            )
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 30,
            children: [
              Text(Strings.howHeader, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              const _Step(number: '1', title: Strings.how1Title, desc: Strings.how1Desc),
              const _Step(number: '2', title: Strings.how2Title, desc: Strings.how2Desc),
              const _Step(number: '3', title: Strings.how3Title, desc: Strings.how3Desc),
            ],
          ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number, title, desc;
  const _Step({required this.number, required this.title, required this.desc});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60, // Fixed size for the circle
            height: 60, // Fixed size for the circle
            decoration: BoxDecoration(
              color: color.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: color.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(desc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: Carousel
class _CarouselSection extends StatelessWidget {
  final bool isMobile;
  const _CarouselSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _sectionPadding(isMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Carousel(
          isMobile: isMobile,
          items: const [
            CarouselItem(
              title: Strings.carouselTitle1,
              description: Strings.carouselDesc1,
              image: 'assets/images/app1.png',
            ),
            CarouselItem(
              title: Strings.carouselTitle2,
              description: Strings.carouselDesc2,
              image: 'assets/images/app2.png',
            ),
            CarouselItem(
              title: Strings.carouselTitle3,
              description: Strings.carouselDesc3,
              image: 'assets/images/app3.png',
            ),
            CarouselItem(
              title: Strings.carouselTitle4,
              description: Strings.carouselDesc4,
              image: 'assets/images/app4.png',
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: Skill triple
class _SkillLevelsSection extends StatelessWidget {
  final bool isMobile;
  const _SkillLevelsSection({super.key, required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _sectionPadding(isMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: TripleCap(
          isMobile: isMobile,
          header: Strings.skillHeader,
          subHeader: Strings.skillSubHeader,
          initialIndex: 1,
          items: const [
            TripleCapItem(
              title: Strings.skillTitle1,
              description: Strings.skillDesc1,
              videoPath: 'assets/images/skill_beg.mp4',
            ),
            TripleCapItem(
              title: Strings.skillTitle2,
              description: Strings.skillDesc2,
              videoPath: 'assets/images/skill_int.mp4',
            ),
            TripleCapItem(
              title: Strings.skillTitle3,
              description: Strings.skillDesc3,
              videoPath: 'assets/images/skill_adv.mp4',
            ),
          ],
        ),
      ),
    );
  }
}


// MARK: Clubs / Colleges

class _ClubsCollegesSection extends StatelessWidget {
  final bool isMobile;

  const _ClubsCollegesSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _sectionPadding(isMobile),
      child: QuiltGrid(
        isMobile: isMobile,
        header: Strings.cncHeader,
        subHeader: Strings.cncSubHeader,
        items: [
          QuiltGridItem(
                title: Strings.cncTitle1,
                description: Strings.cncDesc1,
                image: 'assets/images/cnc1.jpg',
              ),
              QuiltGridItem(
                title: Strings.cncTitle2,
                description: Strings.cncDesc2,
                image: 'assets/images/cnc2.jpg',
              ),
              QuiltGridItem(
                title: Strings.cncTitle3,
                description: Strings.cncDesc3,
                image: 'assets/images/cnc3.jpg',
              ),
            ],
          ),
    );
  }
}

/*
class _PricingSection extends StatelessWidget {
  final bool isMobile;
  const _PricingSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: _sectionPadding(isMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(Strings.pricingTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                Container(
                  width: 320,
                  constraints: const BoxConstraints(minHeight: 180),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Text(Strings.pricingAppTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text(Strings.pricingAppNote),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: () {}, child: const Text(Strings.pricingAppCta)),
                    ],
                  ),
                ),
                Container(
                  width: 320,
                  constraints: const BoxConstraints(minHeight: 180),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Text(Strings.pricingModuleTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text(Strings.pricingModuleNote),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: () {}, child: const Text(Strings.pricingModuleCta)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/

// MARK: Testimonials
class _TestimonialsSection extends StatelessWidget {
  final bool isMobile;
  const _TestimonialsSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: _sectionPadding(isMobile),
      decoration: BoxDecoration(
        color: color.surfaceContainer,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Text(Strings.testimonialsHeader, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
            _Quote(text: Strings.quote1, author: Strings.quote1Author),
            _Quote(text: Strings.quote2, author: Strings.quote2Author),
            _Quote(text: Strings.quote3, author: Strings.quote3Author),
          ],
        ),
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  final String text, author;
  const _Quote({required this.text, required this.author});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote, color: color.primary, size: 48),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(text, style: Theme.of(context).textTheme.titleLarge),
                Text(author, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: FAQ
class _FaqSection extends StatelessWidget {
  final bool isMobile;
  const _FaqSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    final faqs = const [
      [Strings.faq1Q, Strings.faq1A],
      [Strings.faq2Q, Strings.faq2A],
      [Strings.faq3Q, Strings.faq3A],
    ];
    return Container(
      padding: _sectionPadding(isMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(Strings.faqHeader, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final f in faqs)
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(f[0], style: Theme.of(context).textTheme.titleLarge),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(f[1], style: Theme.of(context).textTheme.titleMedium),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/*
// MARK: Contact
class _ContactSection extends StatelessWidget {
  final bool isMobile;
  const _ContactSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: _sectionPadding(isMobile),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(Strings.contactHeader, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(Strings.contactLead,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color.onSurfaceVariant)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isMobile ? double.infinity : 360,
                    child: TextField(
                      decoration: InputDecoration(labelText: Strings.contactName, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : 360,
                    child: TextField(
                      decoration: InputDecoration(labelText: Strings.contactEmail, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: isMobile ? double.infinity : 744,
                child: TextField(
                  maxLines: 4,
                  decoration: InputDecoration(labelText: Strings.contactMessage, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: () {}, child: const Text(Strings.contactSend)),
              const SizedBox(height: 8),
              Text(Strings.contactAlt, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}


// MARK: CTA
class _CtaSection extends StatelessWidget {
  final bool isMobile;
  const _CtaSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: _sectionPadding(isMobile),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.primary.withValues(alpha: .1), color.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Strings.ctaHeader, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(onPressed: () {}, child: const Text(Strings.ctaGetApp)),
                FilledButton(onPressed: () {}, child: const Text(Strings.ctaJoinWaitlist)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/

// MARK: Get the app section
class _GetTheAppSection extends StatelessWidget {
  const _GetTheAppSection({super.key});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final appleUrl = Uri.parse('https://apps.apple.com/us/app/kai-tennis/id6748925788');
    final playUrl = Uri.parse('https://play.google.com/store/apps/details?id=net.OhanaSports.Kai');
    return Container(
      padding: _sectionPadding(MediaQuery.of(context).size.width < 700),
      decoration: BoxDecoration(
        color: color.surfaceContainer,
        border: Border(top: BorderSide(color: color.outlineVariant)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(Strings.ctaGetApp, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: [
                  InkWell(
                    onTap: () => launchUrl(appleUrl, mode: LaunchMode.externalApplication),
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(
                      'assets/icons/AppStore.svg',
                      height: 44,
                      semanticsLabel: 'Download on the App Store',
                    ),
                  ),
                  InkWell(
                    onTap: () => launchUrl(playUrl, mode: LaunchMode.externalApplication),
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(
                      'assets/icons/GooglePlay.svg',
                      height: 44,
                      semanticsLabel: 'Get it on Google Play',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MARK: Footer
class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(Strings.footerCopyright),
              SizedBox(height: 8),
              Text(Strings.footerTagline),
              SizedBox(height: 400),
            ],
          ),
        ),
      ),
    );
  }
}

