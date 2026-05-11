import 'package:flutter/material.dart';

class KaiModulePage extends StatefulWidget {
  const KaiModulePage({super.key});

  @override
  State<KaiModulePage> createState() => _KaiModulePageState();
}

class _KaiModulePageState extends State<KaiModulePage> {
  int _currentImageIndex = 0;
  final int _imageCount = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KAI Module'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image carousel
                  AspectRatio(
                    aspectRatio: 16 / 9,
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
                            child: IconButton(
                              onPressed: _currentImageIndex > 0
                                  ? () => setState(() => _currentImageIndex--)
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            top: 0,
                            bottom: 0,
                            child: IconButton(
                              onPressed: _currentImageIndex < _imageCount - 1
                                  ? () => setState(() => _currentImageIndex++)
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          // Dots indicator
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _imageCount,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == _currentImageIndex
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

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
                      onPressed: () => Navigator.of(context).pushNamed('/order'),
                      child: const Text(
                        'Order Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
