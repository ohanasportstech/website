import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:website/widgets/header.dart';
import 'package:website/widgets/cart.dart';

class KaiModulePage extends StatefulWidget {
  const KaiModulePage({super.key});

  @override
  State<KaiModulePage> createState() => _KaiModulePageState();
}

class _KaiModulePageState extends State<KaiModulePage> {
  int _currentImageIndex = 0;
  final int _imageCount = 4;
  bool _cartOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 136, 24, 48),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: image carousel + thumbnail swimlane
                  Expanded(
                    child: Column(
                      children: [
                        // Hero carousel — 4:3
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                // Placeholder for product images
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.sports_tennis,
                                        size: 100,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Product Image ${_currentImageIndex + 1} of $_imageCount',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Navigation arrows
                                Positioned(
                                  left: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      onPressed: _currentImageIndex > 0
                                          ? () => setState(() => _currentImageIndex--)
                                          : null,
                                      icon: const Icon(Icons.chevron_left),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      onPressed: _currentImageIndex < _imageCount - 1
                                          ? () => setState(() => _currentImageIndex++)
                                          : null,
                                      icon: const Icon(Icons.chevron_right),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Thumbnail swimlane
                        SizedBox(
                          height: 72,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imageCount,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final selected = index == _currentImageIndex;
                              return GestureDetector(
                                onTap: () => setState(() => _currentImageIndex = index),
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: selected
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.sports_tennis,
                                        size: 28,
                                        color: selected
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 56),

                  // Right column: details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                  // Product name
                  Text(
                    'KAI Module',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Lorum ipsum dolor sit amet consectetur adipiscing elit ut et massa mi. Nullam id dolor id nibh ultricies vehicula ut id elit. Donec ullamcorper nulla non metus auctor fringilla.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // What's included
                  Text(
                    "What's included",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletItem('KAI Module unit'),
                  _buildBulletItem('Mounting bracket'),
                  _buildBulletItem('Connection cable'),
                  _buildBulletItem('Quick start guide'),
                  const SizedBox(height: 32),

                  // Pricing section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pricing',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hardware',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '\$399 per module',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Subscription',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    'From \$199/mo',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '60-day free trial',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.green[700],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Tiered pricing: 1st module \$199/mo, 2nd \$149/mo, 3rd+ \$99/mo each',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        context.read<CartModel>().addOne();
                        setState(() => _cartOpen = true);
                      },
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),  // end right column Expanded
                ],
              ),  // end Row
            ),
          ),
        ),
      ),
          GlassHeader(
            onLogoPressed: () => Navigator.of(context).pushNamed('/'),
            onGetKaiPressed: () => Navigator.of(context).pushNamed('/kai-module'),
            onHowItWorksPressed: () => Navigator.of(context).pushNamed('/?section=how-it-works'),
            onClubsPressed: () => Navigator.of(context).pushNamed('/?section=clubs'),
            onPlayersPressed: () => Navigator.of(context).pushNamed('/?section=players'),
            onCartPressed: () => setState(() => _cartOpen = true),
            cartCount: context.watch<CartModel>().quantity,
          ),
          if (_cartOpen)
            CartDrawer(onClose: () => setState(() => _cartOpen = false)),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: Colors.green[600]),
          const SizedBox(width: 12),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
