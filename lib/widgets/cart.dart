import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;
import 'package:website/widgets/login_modal.dart';

// ---------------------------------------------------------------------------
// CartModel — single source of truth for cart state
// ---------------------------------------------------------------------------

class CartModel extends ChangeNotifier {
  int _quantity = 0;
  bool _showVolumeMessage = false;

  int get quantity => _quantity;
  bool get isEmpty => _quantity == 0;
  bool get atMaxQuantity => _quantity >= maxQuantity;
  bool get showVolumeMessage => _showVolumeMessage;

  static const int maxQuantity = 5;

  /// Increments quantity by 1 if below [maxQuantity].
  /// Returns true if the item was added, false if the cap was already reached.
  bool addOne() {
    if (_quantity >= maxQuantity) {
      _showVolumeMessage = true;
      notifyListeners();
      return false;
    }
    _quantity++;
    _showVolumeMessage = false;
    notifyListeners();
    return true;
  }

  void setQuantity(int value) {
    assert(value >= 0);
    _quantity = value;
    if (_quantity < maxQuantity) _showVolumeMessage = false;
    notifyListeners();
  }

  void clear() {
    _quantity = 0;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// OrderDrawerContent — the stateful form, driven by CartModel
// ---------------------------------------------------------------------------

class OrderDrawerContent extends StatefulWidget {
  const OrderDrawerContent({super.key});

  @override
  State<OrderDrawerContent> createState() => _OrderDrawerContentState();
}

class _OrderDrawerContentState extends State<OrderDrawerContent> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameFieldKey = GlobalKey<FormFieldState>();
  final _emailFieldKey = GlobalKey<FormFieldState>();
  final _orgNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _showReturningAdminBanner = true;
  bool _showVolumePricingMessage = false; // derived from CartModel in build
  bool _orgNameHasError = false;
  bool _emailHasError = false;
  late final FocusNode _orgNameFocus;
  late final FocusNode _emailFocus;

  bool get _isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  int _hardwareTotal(int qty) => 399 * qty;

  int _monthlySubscription(int qty) {
    if (qty == 1) return 199;
    if (qty == 2) return 199 + 149;
    return 199 + 149 + ((qty - 2) * 99);
  }

  @override
  void initState() {
    super.initState();
    final storage = web.window.sessionStorage;
    _orgNameController.text = storage.getItem('order_org_name') ?? '';
    _emailController.text = storage.getItem('order_email') ?? '';
    _orgNameFocus = FocusNode();
    _emailFocus = FocusNode();
    _orgNameFocus.addListener(() {
      if (!_orgNameFocus.hasFocus) {
        final invalid = _orgNameFieldKey.currentState?.validate() == false;
        setState(() => _orgNameHasError = invalid);
      }
    });
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        final invalid = _emailFieldKey.currentState?.validate() == false;
        setState(() => _emailHasError = invalid);
      }
    });
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _emailController.dispose();
    _orgNameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final qty = cart.quantity;
    _showVolumePricingMessage = cart.showVolumeMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Returning admin banner (only for non-logged-in users)
        if (!_isLoggedIn && _showReturningAdminBanner)
          MaterialBanner(
            content: const Text(
              'Already using Kai? Sign in to add modules to your existing club.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  showLoginModal(context, onSuccess: () {
                    Navigator.of(context).pushReplacementNamed('/account');
                  });
                },
                child: const Text('SIGN IN'),
              ),
              IconButton(
                onPressed: () => setState(() => _showReturningAdminBanner = false),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

        const SizedBox(height: 24),

        // Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Club/Organization name
              TextFormField(
                key: _orgNameFieldKey,
                focusNode: _orgNameFocus,
                controller: _orgNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Club/Organization Name',
                  hintText: 'Enter your club name',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                onChanged: (_) {
                  if (_orgNameHasError) {
                    final invalid = _orgNameFieldKey.currentState?.validate() == false;
                    if (!invalid) setState(() => _orgNameHasError = false);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your club name';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contact email
              TextFormField(
                key: _emailFieldKey,
                focusNode: _emailFocus,
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  hintText: 'Enter your email address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_emailHasError) {
                    final invalid = _emailFieldKey.currentState?.validate() == false;
                    if (!invalid) setState(() => _emailHasError = false);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  if (!value.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Module quantity selector
              Text('Module Quantity', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: qty > 1
                        ? () => cart.setQuantity(qty - 1)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('$qty', style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  IconButton(
                    onPressed: () => cart.addOne(),
                    icon: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Visibility(
                      visible: _showVolumePricingMessage,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            children: const [
                              TextSpan(text: 'For more than 5 modules, please contact us at '),
                              TextSpan(
                                text: 'sales@ohanasports.net',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' for volume pricing.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Live pricing display
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
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildPriceRow(
                      'Hardware',
                      '\$399 × $qty',
                      '\$${_hardwareTotal(qty)}',
                    ),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Monthly Subscription',
                      qty == 1
                          ? '\$199/mo'
                          : qty == 2
                              ? '\$199 + \$149/mo'
                              : '\$199 + \$149 + ${qty - 2}×\$99/mo',
                      '\$${_monthlySubscription(qty)}/mo',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '60-day free trial, then monthly billing',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[700],
                          ),
                    ),
                    const Divider(height: 24),
                    _buildPriceRow(
                      'Subtotal Due Today',
                      '',
                      '\$${_hardwareTotal(qty)}',
                      isBold: true,
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
                  onPressed: _loading ? null : _continueToCheckout,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Continue to Checkout',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String detail, String value, {bool isBold = false}) {
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: style),
              if (detail.isNotEmpty)
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        Text(value, style: style),
      ],
    );
  }

  Future<void> _continueToCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final cart = context.read<CartModel>();
      final qty = cart.quantity;
      final origin = Uri.base.origin;
      final response = await Supabase.instance.client.functions.invoke(
        'create-guest-checkout-session',
        body: {
          'org_name': _orgNameController.text,
          'email': _emailController.text,
          'module_qty': qty,
          'success_url': '$origin/order/success?session_id={CHECKOUT_SESSION_ID}',
          'cancel_url': '$origin/order',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final checkoutUrl = data['checkout_url'] as String?;

      if (checkoutUrl != null) {
        final storage = web.window.sessionStorage;
        storage.setItem('order_org_name', _orgNameController.text);
        storage.setItem('order_email', _emailController.text);
        storage.setItem('order_quantity', '$qty');
        web.window.history.replaceState(null, '', '${Uri.base.origin}/order');
        await launchUrl(Uri.parse(checkoutUrl), webOnlyWindowName: '_self');
      } else {
        throw Exception('No checkout URL returned');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// CartDrawer — slide-in overlay from the right edge
// ---------------------------------------------------------------------------

class CartDrawer extends StatefulWidget {
  final VoidCallback onClose;

  const CartDrawer({super.key, required this.onClose});

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Stack(
      children: [
        // Dimmed background — tap to close
        FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _close,
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        // Drawer panel
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _slideAnimation,
            child: FocusScope(
              child: Container(
              width: 480,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 32,
                    offset: const Offset(-4, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drawer header with close button
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
                      child: Row(
                        children: [
                          Text(
                            'Your Cart',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _close,
                            icon: const Icon(Icons.close),
                            tooltip: 'Close cart',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  // Body: empty state or order form
                  Expanded(
                    child: cart.isEmpty
                        ? _EmptyCartState(onClose: _close)
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                            child: OrderDrawerContent(),
                          ),
                  ),
                ],
              ),
            ),
            ),  // FocusScope
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _EmptyCartState — shown when cart has no items
// ---------------------------------------------------------------------------

class _EmptyCartState extends StatelessWidget {
  final Future<void> Function() onClose;

  const _EmptyCartState({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a KAI Module to get started.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await onClose();
                if (context.mounted) Navigator.of(context).pushNamed('/kai-module');
              },
              child: const Text('Shop KAI Module'),
            ),
          ],
        ),
      ),
    );
  }
}
