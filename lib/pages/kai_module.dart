import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:website/widgets/header.dart';
import 'package:website/widgets/cart.dart' show CartModel, AdminOrg, CartDrawer;
import 'package:website/utils/beta_access.dart';

class KaiModulePage extends StatefulWidget {
  const KaiModulePage({super.key});

  @override
  State<KaiModulePage> createState() => _KaiModulePageState();
}

class _KaiModulePageState extends State<KaiModulePage> {
  int _currentImageIndex = 0;
  final List<String> _productImages = [
    'assets/images/product_1.jpg',
    'assets/images/product_2.jpg',
    'assets/images/product_3.jpg',
    'assets/images/product_4.jpg',
    'assets/images/product_5.jpg',
  ];

  String _thumbPath(String productPath) {
    final dotIndex = productPath.lastIndexOf('.');
    if (dotIndex == -1) return '${productPath}_thumb';
    return '${productPath.substring(0, dotIndex)}_thumb${productPath.substring(dotIndex)}';
  }

  bool _cartOpen = false;
  bool _processingTransfer = false;

  @override
  void initState() {
    super.initState();
    BetaAccess.init();
    _handleTransferToken();
  }

  Future<void> _handleTransferToken() async {
    final uri = Uri.base;
    final token = uri.queryParameters['transfer_token'];
    if (token == null || token.isEmpty) return;

    setState(() => _processingTransfer = true);

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'exchange-transfer-token',
        body: {'transfer_token': token},
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>?;
        final orgs = data['admin_orgs'] as List<dynamic>?;

        if (user != null && mounted) {
          // Transfer token validated; enable ordering mode.
          BetaAccess.instance.enable();

          final cart = context.read<CartModel>();
          final isOrgAdmin = data['is_org_admin'] as bool? ?? false;

          // Populate cart with admin orgs from transfer (may be empty for non-admins)
          final adminOrgs = orgs != null
              ? orgs.map((o) => AdminOrg.fromJson(o as Map<String, dynamic>)).toList()
              : <AdminOrg>[];
          cart.setAdminOrgs(adminOrgs);

          // Store the transferred user context in the cart
          final email = user['email'] as String?;
          // Keep the transfer_token for checkout authorization
          final transferToken = token; // the original token from URL
          if (email != null) {
            cart.setTransferredUser(email, isOrgAdmin: isOrgAdmin, transferToken: transferToken);
          }
        }
      }
    } catch (e) {
      // Token invalid or expired - user will see standard cart UI
      debugPrint('Session transfer failed: $e');
    } finally {
      if (mounted) setState(() => _processingTransfer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 96,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
                    child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 800;

                      final imageSection = _buildImageSection();
                      final detailsSection = _buildDetailsSection();

                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageSection,
                            const SizedBox(height: 32),
                            detailsSection,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: imageSection),
                          const SizedBox(width: 56),
                          Expanded(child: detailsSection),
                        ],
                      );
                    },
                  ),
                ),
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
          if (_processingTransfer)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.black87),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        // Hero carousel — 4:3
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Product image carousel
                Positioned.fill(
                  child: Image.asset(
                    _productImages[_currentImageIndex],
                    fit: BoxFit.cover,
                  ),
                ),
                // Navigation arrows
                Positioned(
                  left: 12,
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
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: _currentImageIndex < _productImages.length - 1
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
            itemCount: _productImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected = index == _currentImageIndex;
              return GestureDetector(
                onTap: () => setState(() => _currentImageIndex = index),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        _thumbPath(_productImages[index]),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
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

        // Price
        Text(
          '\$399',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          'Kai turns your tennis ball machine into a powerful training partner. Compatible with PLAYMATE iSMASH and iGENIE.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),

        // What's included
        Text(
          'How it works',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildBulletItem('Install the KAI Module on your ball machine'),
        _buildBulletItem('Download the app and connect via Bluetooth'),
        _buildBulletItem('Train with over 60 drills and exercises'),
        _buildBulletItem('Track your progress and improve your game'),
        const SizedBox(height: 32),

        // Pricing and ordering UI (beta-only)
        if (context.watch<BetaAccess>().isEnabled) ...[
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
        ] else ...[
          // Public-facing message until ordering is ready
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
                  'Coming Soon',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Kai Module will be available for purchase in Summer 2026. Join the waitlist to be the first to know when ordering opens.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
