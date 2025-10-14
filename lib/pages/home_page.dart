import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
                  const SliverToBoxAdapter(child: _Separator()),
                  SliverToBoxAdapter(child: _Reveal(child: _ProductSection(isMobile: isMobile))),
                  SliverToBoxAdapter(child: _Reveal(delayMs: 60, child: _FeaturesSection(isMobile: isMobile))),
                  const SliverToBoxAdapter(child: _Separator()),
                  SliverToBoxAdapter(child: _Reveal(delayMs: 90, child: _HowItWorksSection(isMobile: isMobile))),
                  SliverToBoxAdapter(child: _Reveal(delayMs: 120, child: _PricingSection(isMobile: isMobile))),
                  const SliverToBoxAdapter(child: _Separator()),
                  SliverToBoxAdapter(child: _Reveal(delayMs: 150, child: _TestimonialsSection(isMobile: isMobile))),
                  SliverToBoxAdapter(child: _Reveal(delayMs: 180, child: _FaqSection(isMobile: isMobile))),
                  SliverToBoxAdapter(child: _Reveal(delayMs: 210, child: _ContactSection(isMobile: isMobile))),
                  SliverToBoxAdapter(child: _Reveal(delayMs: 240, child: _CtaSection(isMobile: isMobile))),
                  SliverToBoxAdapter(child: const _Footer()),
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

class _Separator extends StatelessWidget {
  const _Separator();
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  color.outlineVariant,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}

class _Reveal extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const _Reveal({required this.child, this.delayMs = 0});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> {
  final _visKey = UniqueKey();
  bool _shown = false;
  bool _scheduled = false;

  void _trigger() {
    if (_scheduled || _shown) return;
    _scheduled = true;
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1) {
          _trigger();
        }
      },
      child: AnimatedSlide(
        offset: _shown ? Offset.zero : Offset(0, 0.06),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _shown ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

EdgeInsets _sectionPadding(bool isMobile) =>
    EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: isMobile ? 32 : 56);

class _HeroSection extends StatelessWidget {
  final bool isMobile;
  final double scroll;
  const _HeroSection({required this.isMobile, required this.scroll});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
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
                        'Smarter tennis practice, together',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'App + SmartModule to control your ball machine with ease. Warm coaching, sporty energy, and data that helps you grow.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 22, vertical: 14),
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ).copyWith(
                              overlayColor: WidgetStatePropertyAll(color.primary.withValues(alpha: 0.08)),
                            ),
                            child: const Text('Get the App'),
                          ),
                          FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 22, vertical: 14),
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ).copyWith(
                              overlayColor: WidgetStatePropertyAll(color.primary.withValues(alpha: 0.08)),
                            ),
                            child: const Text('Meet the SmartModule'),
                          ),
                        ],
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

class _ProductSection extends StatelessWidget {
  final bool isMobile;
  const _ProductSection({required this.isMobile});
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
            Text('Two pieces. One smooth experience.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 16),
            Text(
              'The Kai Tennis app pairs with our SmartModule to bring pro-level controls to your existing ball machine. Set drills, tweak speed and spin, and track progress—without breaking rhythm.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              spacing: 24,
              runSpacing: 24,
              children: const [
                _Card(
                  title: 'Kai Tennis app',
                  body:
                      'Friendly controls, session tracking, and coaching tips to keep your practice flowing.',
                  icon: Icons.phone_iphone,
                ),
                _Card(
                  title: 'SmartModule',
                  body:
                      'A compact add-on that connects to your ball machine for precise, wireless control.',
                  icon: Icons.memory,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  final String title;
  final String body;
  final IconData icon;
  const _Card({required this.title, required this.body, required this.icon});
  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 180),
        curve: Curves.easeOut,
        transform: _hovering ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        width: 340,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest.withValues(alpha: _hovering ? 0.92 : 1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.outlineVariant),
          boxShadow: _hovering
              ? [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, spreadRadius: 0, offset: const Offset(0, 12)),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, size: 32, color: color.primary),
            const SizedBox(height: 12),
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(widget.body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  final bool isMobile;
  const _FeaturesSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    final features = const [
      ['Drills made easy', 'Build patterns with pace, spin, and placement. Save favorites.'],
      ['Real-time control', 'Adjust settings on the fly. No more walking to the machine.'],
      ['Progress insights', 'Track sessions to see growth over weeks and months.'],
      ['Friendly by design', 'Warm prompts and simple flows keep you in the zone.'],
    ];
    return Container(
      padding: _sectionPadding(isMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text('Features that fuel your practice',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                for (final f in features)
                  _Card(title: f[0], body: f[1], icon: Icons.check_circle_outline),
              ],
            ),
          ],
        ),
      ),
    );
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
            Text('How it works', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            SizedBox(height: 16),
            _Step(number: '1', title: 'Connect', desc: 'Attach the SmartModule to your ball machine and pair via Bluetooth.'),
            _Step(number: '2', title: 'Set your drill', desc: 'Choose pace, spin, and placement in the app. Save it for next time.'),
            _Step(number: '3', title: 'Hit with flow', desc: 'Control from the baseline. Adjust on the fly and keep your rhythm.'),
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
            Text('Simple pricing', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                      Text('Ohana App', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text('Free to try • Premium coaching insights optional'),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: () {}, child: const Text('Get the App')),
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
                      Text('SmartModule', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text('Preorder pricing • Limited early units'),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: () {}, child: const Text('Join waitlist')),
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
            Text('Players love Kai Tennis', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            SizedBox(height: 16),
            _Quote(text: 'Finally, I can tweak drills without stopping my groove.', author: 'Alex, 4.0 USTA'),
            _Quote(text: 'The app feels like a friendly coach in my pocket.', author: 'Priya, weekend player'),
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
      ['Will it work with my ball machine?', 'We aim to support popular models. Compatibility list coming soon.'],
      ['Is there a subscription?', 'Core app is free to try. Premium insights are optional.'],
      ['When can I get the module?', 'Join the waitlist to get notified about early units.'],
    ];
    return Container(
      padding: _sectionPadding(isMobile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text('FAQ', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
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
              Text('Contact', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Have a question about the app or SmartModule? We’d love to hear from you.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color.onSurfaceVariant)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isMobile ? double.infinity : 360,
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Your name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : 360,
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: isMobile ? double.infinity : 744,
                child: TextField(
                  maxLines: 4,
                  decoration: InputDecoration(labelText: 'Message', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: () {}, child: const Text('Send message')),
              const SizedBox(height: 8),
              Text('Prefer email? info@ohanasports.com', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant)),
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
            Text('Ready to rally with Kai Tennis?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(onPressed: () {}, child: const Text('Get the App')),
                FilledButton(onPressed: () {}, child: const Text('Join the Waitlist')),
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
              Text('© Ohana Sports'),
              SizedBox(height: 8),
              Text('Made for players, with heart.'),
            ],
          ),
        ),
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
      top: 0,
      left: 0,
      right: 0,
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
                      Text('Kai Tennis', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      TextButton(onPressed: () {}, child: const Text('App')),
                      TextButton(onPressed: () {}, child: const Text('SmartModule')),
                      TextButton(onPressed: () {}, child: const Text('Contact')),
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
