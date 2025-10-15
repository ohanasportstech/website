import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/reveal.dart';
import '../widgets/separator.dart';
import '../widgets/card.dart';
import '../strings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController _scrollController;
  double _scroll = 0;

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

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: color.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _HeroSection(isMobile: isMobile, scroll: _scroll)),
                  const SliverToBoxAdapter(child: Separator()),
                  SliverToBoxAdapter(child: Reveal(child: _MeetKaiSection(isMobile: isMobile))),
                  //SliverToBoxAdapter(child: Reveal(delayMs: 60, child: _FeaturesSection(isMobile: isMobile))),
                  //SliverToBoxAdapter(child: Reveal(delayMs: 60, child: _ClubsCollegesSection(isMobile: isMobile))),
                  const SliverToBoxAdapter(child: Separator()),
                  //SliverToBoxAdapter(child: Reveal(delayMs: 90, child: _HowItWorksSection(isMobile: isMobile))),
                  //SliverToBoxAdapter(child: Reveal(delayMs: 120, child: _PricingSection(isMobile: isMobile))),
                  const SliverToBoxAdapter(child: Separator()),
                  SliverToBoxAdapter(child: Reveal(delayMs: 150, child: _TestimonialsSection(isMobile: isMobile))),
                  SliverToBoxAdapter(child: Reveal(delayMs: 180, child: _FaqSection(isMobile: isMobile))),
                  SliverToBoxAdapter(child: Reveal(delayMs: 210, child: _ContactSection(isMobile: isMobile))),
                  SliverToBoxAdapter(child: Reveal(delayMs: 240, child: _CtaSection(isMobile: isMobile))),
                  SliverToBoxAdapter(child: const Separator()),
                ],
              ),
              const _GlassHeader(),
            ],
          );
        },
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget {
  const _GlassHeader();
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: color.surface.withValues(alpha: 0.6),
                  border: Border.all(color: color.outlineVariant),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(Strings.navMain, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      TextButton(onPressed: () {}, child: const Text(Strings.nav1)),
                      TextButton(onPressed: () {}, child: const Text(Strings.nav2)),
                      TextButton(onPressed: () {}, child: const Text(Strings.nav3)),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/about'),
                        child: const Text(Strings.nav4),
                      ),
                      FilledButton(onPressed: () {}, child: const Text(Strings.navCTA)),
                    ],
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
    EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: isMobile ? 32 : 56);

// MARK: Hero
class _HeroSection extends StatelessWidget {
  final bool isMobile;
  final double scroll;
  const _HeroSection({required this.isMobile, required this.scroll});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isMobile ? 420 : 560,
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, -scroll * 0.12),
              child: Image.asset(
                'assets/hero.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: isMobile ? 24 : 48,
            child: Padding(
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
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Strings.heroDesc,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: _sectionPadding(isMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(Strings.meetHeader, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Text(Strings.meetDesc, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color.onSurfaceVariant)),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              spacing: 24,
              runSpacing: 24,
              children: [
                ImageCard(
                  title: Strings.meetCardTitle1,
                  body: Strings.meetCardBody1,
                  image: 'assets/meet_kai1.png',
                ),
                ImageCard(
                  title: Strings.meetCardTitle2,
                  body: Strings.meetCardBody2,
                  image: 'assets/meet_kai2.png',
                ),
                ImageCard(
                  title: Strings.meetCardTitle3,
                  body: Strings.meetCardBody3,
                  image: 'assets/meet_kai3.png',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// MARK: Skill triple

// MARK: Carousel

/*
// MARK: Clubs / Colleges
class _ClubsCollegesSection extends StatelessWidget {
  final bool isMobile;
  const _ClubsCollegesSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    // 
  }
}

class _HowItWorksSection extends StatelessWidget {
  final bool isMobile;
  const _HowItWorksSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _sectionPadding(isMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: const [
            Text(Strings.howTitle, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            SizedBox(height: 16),
            _Step(number: '1', title: Strings.how1Title, desc: Strings.how1Desc),
            _Step(number: '2', title: Strings.how2Title, desc: Strings.how2Desc),
            _Step(number: '3', title: Strings.how3Title, desc: Strings.how3Desc),
          ],
        ),
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
          CircleAvatar(backgroundColor: color.primary, child: Text(number, style: TextStyle(color: color.onPrimary))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(desc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
        border: Border(top: BorderSide(color: color.outlineVariant)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: const [
            Text(Strings.testimonialsHeader, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            SizedBox(height: 16),
            _Quote(text: Strings.quote1, author: Strings.quote1Author),
            _Quote(text: Strings.quote2, author: Strings.quote2Author),
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
        children: [
          Icon(Icons.format_quote, color: color.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: Theme.of(context).textTheme.bodyLarge),
                Text(author, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
            Text(Strings.faqHeader, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final f in faqs)
              ExpansionTile(
                title: Text(f[0]),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(f[1]),
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

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      color: color.surfaceContainerHigh,
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
            ],
          ),
        ),
      ),
    );
  }
}

