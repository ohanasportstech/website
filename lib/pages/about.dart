import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:website/widgets/cart.dart' show CartModel, CartDrawer;
import 'package:website/widgets/contact_section.dart';
import 'package:website/widgets/header.dart';
import 'package:website/widgets/page_footer.dart';

EdgeInsets _sectionPadding(bool isMobile) =>
    EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: isMobile ? 24 : 60);

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _cartOpen = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: isMobile ? MobileAppBar(onGetKaiPressed: () => Navigator.of(context).pushNamed('/kai-module')) : null,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SelectionArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const _HeroSection(),
                  const _StorySection(),
                  const _MissionSection(),
                  const _ValuesSection(),
                  const _TeamSection(),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: ContactSection(isMobile: isMobile),
                    ),
                  ),
                  const QuickLinksSection(),
                  const GetTheAppSection(),
                  const Footer(),
                ],
              ),
            ),
          ),
          if (!isMobile)
            GlassHeader(
              onLogoPressed: () => Navigator.of(context).pushNamed('/'),
              onGetKaiPressed: () => Navigator.of(context).pushNamed('/kai-module'),
              onHowItWorksPressed: () => Navigator.of(context).pushNamed('/?section=how-it-works'),
              onClubsPressed: () => Navigator.of(context).pushNamed('/?section=clubs'),
              onPlayersPressed: () => Navigator.of(context).pushNamed('/?section=players'),
              onCartPressed: () => setState(() => _cartOpen = true),
              cartCount: context.watch<CartModel>().quantity,
            ),
          if (_cartOpen) CartDrawer(onClose: () => setState(() => _cartOpen = false)),
        ],
      ),
    );
  }
}

// MARK: Hero
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return SizedBox(
      height: isMobile ? 380 : 480,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero background image.
          Image.asset('assets/images/about.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Our Story',
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Built for players, by players. We strive to make every practice count.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 64),
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

// MARK: Story
class _StorySection extends StatelessWidget {
  const _StorySection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: _sectionPadding(isMobile),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How It All Started',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Practice should feel alive. We started Ohana Sports because we saw too many players hitting against static feeds, unsure what to work on next. We set out to build a training companion that adapts to you: your level, your goals, and your love of the game.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: Mission
class _MissionSection extends StatelessWidget {
  const _MissionSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: _sectionPadding(isMobile),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Text(
                    'Our mission is to transform the way people learn and grow through the joy of tennis.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
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

// MARK: Values
class _ValuesSection extends StatelessWidget {
  const _ValuesSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final items = [
      (
        icon: Icons.sports_tennis_outlined,
        title: 'Build From Experience',
        desc:
            "The best ideas don't come from a conference room. They come from playing, watching, listening, and learning alongside players and coaches.",
      ),
      (
        icon: Icons.touch_app_outlined,
        title: 'Make It Feel Simple',
        desc:
            'Great technology should make tennis easier. We sweat the details so powerful training tools feel natural, intuitive, and almost invisible once the session begins.',
      ),
      (
        icon: Icons.trending_up_outlined,
        title: 'Always Be Improving',
        desc:
            'Tennis is a game of constant adjustment, and we think building should work the same way. We test, learn, listen, and keep making Kai better, one session at a time.',
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: _sectionPadding(isMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Values',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 32),
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final item in items) ...[
                            _ValueItem(icon: item.icon, title: item.title, desc: item.desc),
                            if (item != items.last) const SizedBox(height: 40),
                          ],
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final item in items) ...[
                            Expanded(
                              child: _ValueItem(icon: item.icon, title: item.title, desc: item.desc),
                            ),
                            if (item != items.last) const SizedBox(width: 32),
                          ],
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _ValueItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colors.primary, size: 36),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        /*
        Center(child: Icon(icon, color: colors.primary, size: 36)),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        */
        const SizedBox(height: 10),
        Text(
          desc,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant, height: 1.55),
        ),
      ],
    );
  }
}

// MARK: Team
class _TeamSection extends StatelessWidget {
  const _TeamSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final colors = Theme.of(context).colorScheme;

    final title = Text(
      'The Team',
      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
    );

    final teamBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kai is built by a small team with a big love for tennis.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant, height: 1.6),
        ),
        const SizedBox(height: 16),
        Text(
          "We're Joe and Victor, the two founders behind Ohana Sports. We design, build, test, and improve Kai ourselves, often with a racquet in one hand and a laptop in the other.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant, height: 1.6),
        ),
        const SizedBox(height: 16),
        Text(
          "Along the way, we've been lucky to have talented friends, players, coaches, and collaborators lend their expertise and help bring Kai to life. But we're still happiest where this all started: on the court, figuring out how to make the next practice better than the last.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant, height: 1.6),
        ),
      ],
    );

    final placeholderBlock = Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(24)),
      child: Center(child: Icon(Icons.groups_outlined, size: 196, color: colors.primary.withValues(alpha: 0.5))),
    );

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: _sectionPadding(isMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 20),
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [teamBody, const SizedBox(height: 32), placeholderBlock],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: teamBody),
                            const SizedBox(width: 64),
                            Expanded(flex: 5, child: placeholderBlock),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
