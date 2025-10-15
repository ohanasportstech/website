import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: color.surface,
        title: const Text('About Us'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            children: [
              Text(
                'Our Mission',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'At Ohana Sports, we build friendly technology that helps tennis players practice smarter and enjoy the game more. '
                'Kai Tennis combines a thoughtful app with a smart module to bring pro-level control to your practice, without losing your flow.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              Text(
                'Our Values',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _ValueBullet(title: 'Warm coaching', desc: 'Encouraging guidance that meets you where you are.'),
              _ValueBullet(title: 'Sporty energy', desc: 'A product that feels alive, clear, and motivating.'),
              _ValueBullet(title: 'Trustworthy tech', desc: 'Reliable hardware and software that stay out of your way.'),
              const SizedBox(height: 32),
              Text(
                'The Team',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'We are designers, engineers, and tennis lovers. We listen closely to players to build what truly helps on court.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get in touch',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Have feedback or want to collaborate? Email info@ohanasports.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Back'),
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

class _ValueBullet extends StatelessWidget {
  final String title;
  final String desc;
  const _ValueBullet({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: color.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(desc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
