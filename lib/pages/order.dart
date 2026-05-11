import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;
import 'package:website/widgets/login_modal.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameFieldKey = GlobalKey<FormFieldState>();
  final _emailFieldKey = GlobalKey<FormFieldState>();
  final _orgNameController = TextEditingController();
  final _emailController = TextEditingController();
  int _quantity = 1;
  bool _loading = false;
  bool _showReturningAdminBanner = true;
  bool _showVolumePricingMessage = false;
  bool _orgNameHasError = false;
  bool _emailHasError = false;
  late final FocusNode _orgNameFocus;
  late final FocusNode _emailFocus;

  // Check if user is logged in
  bool get _isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  int get _hardwareTotal => 399 * _quantity;

  int get _monthlySubscription {
    // Tiered pricing: 1st $199, 2nd $149, 3rd+ $99 each
    if (_quantity == 1) return 199;
    if (_quantity == 2) return 199 + 149;
    return 199 + 149 + ((_quantity - 2) * 99);
  }

  @override
  void initState() {
    super.initState();
    final storage = web.window.sessionStorage;
    _orgNameController.text = storage.getItem('order_org_name') ?? '';
    _emailController.text = storage.getItem('order_email') ?? '';
    _quantity = int.tryParse(storage.getItem('order_quantity') ?? '') ?? 1;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order KAI Module'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
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
                          onPressed: () {
                            setState(() => _showReturningAdminBanner = false);
                          },
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
                          decoration: const InputDecoration(
                            labelText: 'Club/Organization Name',
                            hintText: 'Enter your club name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) {
                            if (_orgNameHasError) {
                              final invalid = _orgNameFieldKey.currentState?.validate() == false;
                              if (!invalid) setState(() => _orgNameHasError = false);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your club name';
                            }
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
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Module quantity selector
                        Text(
                          'Module Quantity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () => setState(() { _quantity--; _showVolumePricingMessage = false; })
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_quantity',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_quantity < 5) {
                                  setState(() {
                                    _quantity++;
                                    _showVolumePricingMessage = false;
                                  });
                                } else {
                                  setState(() => _showVolumePricingMessage = true);
                                }
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        if (_showVolumePricingMessage) ...[
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                        ],
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
                                '\$399 × $_quantity',
                                '\$$_hardwareTotal',
                              ),
                              const SizedBox(height: 8),
                              _buildPriceRow(
                                'Monthly Subscription',
                                _quantity == 1
                                    ? '\$199/mo'
                                    : _quantity == 2
                                        ? '\$199 + \$149/mo'
                                        : '\$199 + \$149 + ${_quantity - 2}×\$99/mo',
                                '\$$_monthlySubscription/mo',
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
                                '\$$_hardwareTotal',
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
                ],
              ),
            ),
          ),
        ),
      ),
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
      final origin = Uri.base.origin;
      final response = await Supabase.instance.client.functions.invoke(
        'create-guest-checkout-session',
        body: {
          'org_name': _orgNameController.text,
          'email': _emailController.text,
          'module_qty': _quantity,
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
        storage.setItem('order_quantity', '$_quantity');
        // Replace the current history entry with /order so that Stripe's
        // "back" button returns here rather than wherever the user came from.
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
