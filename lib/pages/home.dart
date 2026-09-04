import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:website/widgets/contact_section.dart';
import 'package:website/widgets/header.dart';
import 'package:website/widgets/page_footer.dart';
import 'package:website/widgets/cart.dart';
import '../widgets/card.dart';
import '../widgets/triple_cap.dart';
import '../widgets/carousel.dart';
import '../widgets/quilt_grid.dart';
import '../widgets/feature_section.dart';
import '../widgets/loop_video.dart';
import '../strings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController _scrollController;
  bool _cartOpen = false;
  final GlobalKey _contactKey = GlobalKey();
  final GlobalKey _getAppKey = GlobalKey();
  final GlobalKey _clubsKey = GlobalKey();
  final GlobalKey _playersKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Scroll to a section if a ?section= query param was passed on navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSectionFromUri());
  }

  // Height of the glass header + comfortable breathing room below it.
  static const double _headerClearance = 100.0;

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero).dy + _scrollController.offset - _headerClearance;
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _scrollToSectionFromUri() {
    final section = Uri.base.queryParameters['section'];
    if (section == null) return;
    final key = switch (section) {
      'how-it-works' => _howItWorksKey,
      'clubs' => _clubsKey,
      'players' => _playersKey,
      _ => null,
    };
    if (key != null) _scrollToKey(key);
  }

  void _handleGetKaiPressed(BuildContext context) {
    Navigator.of(context).pushNamed('/kai-module');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // MARK: Section layout
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: isMobile ? MobileAppBar(onGetKaiPressed: () => _handleGetKaiPressed(context)) : null,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SelectionArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    if (isMobile) SliverToBoxAdapter(child: SizedBox(height: 56)),
                    SliverToBoxAdapter(
                      child: _MaxWidth(child: _HeroSection(isMobile: isMobile)),
                    ),
                    SliverToBoxAdapter(
                      child: _MaxWidth(child: _MeetKaiSection(isMobile: isMobile)),
                    ),
                    SliverToBoxAdapter(
                      child: _MaxWidth(
                        child: _ClubsCollegesSection(key: _clubsKey, isMobile: isMobile),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _MaxWidth(child: _CarouselSection(isMobile: isMobile)),
                    ),
                    SliverToBoxAdapter(
                      child: _MaxWidth(child: _AdvancedTechnologySection(isMobile: isMobile)),
                    ),
                    SliverToBoxAdapter(
                      child: _MaxWidth(
                        child: _SkillLevelsSection(key: _playersKey, isMobile: isMobile),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _MaxWidth(
                        child: _HowItWorksSection(key: _howItWorksKey, isMobile: isMobile),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _MaxWidth(child: _TestimonialsSection(isMobile: isMobile)),
                    ),
                    SliverToBoxAdapter(
                      child: _MaxWidth(child: _FaqSection(isMobile: isMobile)),
                    ),
                    SliverToBoxAdapter(
                      child: _MaxWidth(
                        child: ContactSection(key: _contactKey, isMobile: isMobile),
                      ),
                    ),
                    SliverToBoxAdapter(child: _MaxWidth(child: const QuickLinksSection())),
                    SliverToBoxAdapter(
                      child: _MaxWidth(child: GetTheAppSection(key: _getAppKey)),
                    ),
                    SliverToBoxAdapter(child: _MaxWidth(child: const Footer())),
                  ],
                ),
                if (!isMobile)
                  GlassHeader(
                    onLogoPressed: () => _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                    ),
                    onGetKaiPressed: () => _handleGetKaiPressed(context),
                    onHowItWorksPressed: () => _scrollToKey(_howItWorksKey),
                    onClubsPressed: () => _scrollToKey(_clubsKey),
                    onPlayersPressed: () => _scrollToKey(_playersKey),
                    onCartPressed: () => setState(() => _cartOpen = true),
                    cartCount: context.watch<CartModel>().quantity,
                  ),
                if (_cartOpen) CartDrawer(onClose: () => setState(() => _cartOpen = false)),
              ],
            );
          },
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
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1440), child: child),
    );
  }
}

// MARK: Hero
class _HeroSection extends StatelessWidget {
  final bool isMobile;
  const _HeroSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRect(
        child: Stack(
          children: [
            const LoopVideo(assetName: 'assets/images/hero.mp4'),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: isMobile ? 80 : 180,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: isMobile ? 12 : 24,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: _sectionPadding(isMobile).left),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Strings.heroHeader,
                              textAlign: TextAlign.start,
                              style: isMobile
                                  ? Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
                                  : Theme.of(context).textTheme.displayMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                            ),
                            SizedBox(height: isMobile ? 4 : 16),
                            Text(
                              Strings.heroDesc,
                              textAlign: TextAlign.start,
                              style: isMobile
                                  ? Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)
                                  : Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                            ),
                            if (!isMobile) const SizedBox(height: 45),
                          ],
                        ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.meetHeader,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 22),
            Text(
              Strings.meetDesc,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
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
                            image: 'assets/images/upgrade1.jpg',
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
                            image: 'assets/images/upgrade2.jpg',
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
                            image: 'assets/images/upgrade3.jpg',
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
                      image: 'assets/images/upgrade1.jpg',
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: ImageCard(
                      title: Strings.meetCardTitle2,
                      body: Strings.meetCardBody2,
                      image: 'assets/images/upgrade2.jpg',
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: ImageCard(
                      title: Strings.meetCardTitle3,
                      body: Strings.meetCardBody3,
                      image: 'assets/images/upgrade3.jpg',
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

// MARK: Advanced Technology
class _AdvancedTechnologySection extends StatelessWidget {
  final bool isMobile;
  const _AdvancedTechnologySection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _sectionPadding(isMobile),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: FeatureSection(
          header: Strings.advancedTechnologyHeader,
          subHeader: Strings.advancedTechnologySubHeader,
          bullets: Strings.advancedTechnologyBullets,
          image: 'assets/images/module1.jpg',
          isMobile: isMobile,
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
    return Container(
      padding: _sectionPadding(isMobile),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 30,
        children: [
          Text(
            Strings.howHeader,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 12),
          Container(
            width: 40, // Fixed size for the circle
            height: 40, // Fixed size for the circle
            decoration: BoxDecoration(color: color.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              number,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: color.onPrimary, fontWeight: FontWeight.bold),
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
          header: Strings.carouselHeader,
          subHeader: Strings.carouselSubHeader,
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
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer),
      child: QuiltGrid(
        isMobile: isMobile,
        header: Strings.cncHeader,
        subHeader: Strings.cncSubHeader,
        items: [
          QuiltGridItem(title: Strings.cncTitle1, description: Strings.cncDesc1, image: 'assets/images/nextgen1.jpg'),
          QuiltGridItem(title: Strings.cncTitle2, description: Strings.cncDesc2, image: 'assets/images/nextgen2.jpg'),
          QuiltGridItem(title: Strings.cncTitle3, description: Strings.cncDesc3, image: 'assets/images/nextgen3.jpg'),
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
    return Container(
      padding: _sectionPadding(isMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Text(
              Strings.testimonialsHeader,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
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
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.faqHeader,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
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
      ),
    );
  }
}

/*
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

