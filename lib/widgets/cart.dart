import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;

// ---------------------------------------------------------------------------
// AdminOrg — represents an organization the user is admin of
// ---------------------------------------------------------------------------

class AdminOrg {
  final String orgId;
  final String orgName;
  final String? stripeCustomerId;
  final String? billingStatus;
  final DateTime? subEnd;
  final bool cancelAtPeriodEnd;
  final int stripeSubscriptionQty;
  final int moduleCount;

  AdminOrg({
    required this.orgId,
    required this.orgName,
    this.stripeCustomerId,
    this.billingStatus,
    this.subEnd,
    this.cancelAtPeriodEnd = false,
    this.stripeSubscriptionQty = 0,
    this.moduleCount = 0,
  });

  factory AdminOrg.fromJson(Map<String, dynamic> json) {
    final subEndStr = json['sub_end'] as String?;
    return AdminOrg(
      orgId: json['org_id'] as String,
      orgName: json['org_name'] as String,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      billingStatus: json['billing_status'] as String?,
      subEnd: subEndStr != null ? DateTime.tryParse(subEndStr) : null,
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      stripeSubscriptionQty: json['stripe_subscription_qty'] as int? ?? 0,
      moduleCount: json['module_count'] as int? ?? 0,
    );
  }

  bool get isExistingCustomer =>
      stripeCustomerId != null && stripeCustomerId!.isNotEmpty;
}

// ---------------------------------------------------------------------------
// PricingConfig — holds pricing tiers
// ---------------------------------------------------------------------------

class PricingConfig {
  final int hardwarePriceCents;
  final int subTier1PriceCents;
  final int subTier2PriceCents;
  final int subTier3PriceCents;

  const PricingConfig({
    required this.hardwarePriceCents,
    required this.subTier1PriceCents,
    required this.subTier2PriceCents,
    required this.subTier3PriceCents,
  });

  static const PricingConfig defaults = PricingConfig(
    hardwarePriceCents: 39900,
    subTier1PriceCents: 19900,
    subTier2PriceCents: 14900,
    subTier3PriceCents: 9900,
  );

  factory PricingConfig.fromJson(Map<String, dynamic> json) {
    return PricingConfig(
      hardwarePriceCents: json['hardware_price_cents'] as int? ?? 39900,
      subTier1PriceCents: json['sub_tier1_price_cents'] as int? ?? 19900,
      subTier2PriceCents: json['sub_tier2_price_cents'] as int? ?? 14900,
      subTier3PriceCents: json['sub_tier3_price_cents'] as int? ?? 9900,
    );
  }

  int calculateMonthlyCents(int qty) {
    if (qty <= 0) return 0;
    if (qty == 1) return subTier1PriceCents;
    if (qty == 2) return subTier1PriceCents + subTier2PriceCents;
    return subTier1PriceCents + subTier2PriceCents + (qty - 2) * subTier3PriceCents;
  }
}

// ---------------------------------------------------------------------------
// CartModel — single source of truth for cart state
// ---------------------------------------------------------------------------

class CartModel extends ChangeNotifier {
  int _quantity = 0;
  bool _showVolumeMessage = false;
  List<AdminOrg> _adminOrgs = [];
  String? _selectedOrgId;
  PricingConfig _pricing = PricingConfig.defaults;
  String? _transferredUserEmail;
  bool _isTransferredSession = false;
  bool _isTransferredOrgAdmin = false;
  String? _transferToken;

  int get quantity => _quantity;
  bool get isEmpty => _quantity == 0;
  bool get atMaxQuantity => _quantity >= maxQuantity;
  bool get showVolumeMessage => _showVolumeMessage;
  List<AdminOrg> get adminOrgs => _adminOrgs;
  String? get selectedOrgId => _selectedOrgId;
  AdminOrg? get selectedOrg =>
      _selectedOrgId != null
          ? _adminOrgs.firstWhere((o) => o.orgId == _selectedOrgId)
          : null;
  PricingConfig get pricing => _pricing;
  String? get transferredUserEmail => _transferredUserEmail;
  bool get isTransferredSession => _isTransferredSession;
  bool get isTransferredOrgAdmin => _isTransferredOrgAdmin;
  String? get transferToken => _transferToken;

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

  void setAdminOrgs(List<AdminOrg> orgs) {
    _adminOrgs = orgs;
    if (orgs.length == 1) {
      _selectedOrgId = orgs.first.orgId;
    }
    notifyListeners();
  }

  void setSelectedOrgId(String? orgId) {
    _selectedOrgId = orgId;
    notifyListeners();
  }

  void setPricing(PricingConfig pricing) {
    _pricing = pricing;
    notifyListeners();
  }

  void setTransferredUser(String email, {bool isOrgAdmin = false, String? transferToken}) {
    _transferredUserEmail = email;
    _isTransferredSession = true;
    _isTransferredOrgAdmin = isOrgAdmin;
    _transferToken = transferToken;
    notifyListeners();
  }

  void clear() {
    _quantity = 0;
    _adminOrgs = [];
    _selectedOrgId = null;
    _transferredUserEmail = null;
    _isTransferredSession = false;
    _isTransferredOrgAdmin = false;
    _transferToken = null;
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

  // Returns true if user is authenticated (Supabase) or is a transferred org admin
  // Non-admin transferred users see editable fields like guests
  bool _isLoggedIn(BuildContext context) {
    final supabaseUser = Supabase.instance.client.auth.currentUser != null;
    final cart = context.read<CartModel>();
    final transferredUser = cart.isTransferredSession;
    final transferredAdmin = cart.isTransferredOrgAdmin;
    // Only treat as "logged in" for org selection if:
    // 1. They have a Supabase session, OR
    // 2. They are a transferred org admin
    return supabaseUser || (transferredUser && transferredAdmin);
  }

  String? _getUserEmail(BuildContext context) {
    // Prefer Supabase session, fall back to transferred session
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser?.email != null) {
      return supabaseUser!.email;
    }
    return context.read<CartModel>().transferredUserEmail;
  }

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

    // Defer loading until after first frame to safely access context
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cart = context.read<CartModel>();

      // Load pricing config for all users
      await _loadPricing(cart);

      if (!mounted) return;

      // Load user-specific data if logged in (including transferred org admins)
      if (_isLoggedIn(context)) {
        await _loadUserOrgs(cart);
      }

      if (!mounted) return;

      // Pre-fill email from transferred users (even non-admins)
      if (cart.transferredUserEmail != null) {
        setState(() {
          _emailController.text = cart.transferredUserEmail!;
        });
      }
    });
  }

  Future<void> _loadPricing(CartModel cart) async {
    try {
      final pricingResponse = await Supabase.instance.client
          .schema('ost_admin_public')
          .rpc('get_pricing');
      final pricingList = pricingResponse as List?;
      if (pricingList != null && pricingList.isNotEmpty) {
        cart.setPricing(PricingConfig.fromJson(pricingList.first as Map<String, dynamic>));
      }
    } catch (e) {
      log('Error loading pricing: $e');
    }
  }

  Future<void> _loadUserOrgs(CartModel cart) async {
    try {
      // Load admin orgs from Supabase for authenticated users
      final orgsResponse = await Supabase.instance.client
          .schema('ost_admin_public')
          .rpc('get_user_admin_orgs');

      if (orgsResponse != null) {
        final orgs = (orgsResponse as List)
            .map((o) => AdminOrg.fromJson(o as Map<String, dynamic>))
            .toList();
        cart.setAdminOrgs(orgs);
      }
    } catch (e) {
      log('Error loading user orgs: $e');
    }
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
        if (!_isLoggedIn(context) && _showReturningAdminBanner)
          MaterialBanner(
            content: const Text(
              'Already using Kai? Order additional modules from the app to take advantage of tiered subscription pricing.',
            ),
            actions: [
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
              if (_isLoggedIn(context))
                _buildOrgSelector()
              else
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
              // Show non-editable display if we have an email from any source
              // (Supabase session or transferred user), otherwise show editable field
              if (_getUserEmail(context) != null)
                _buildEmailDisplay(context)
              else
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
                    // Show tiered pricing breakdown for logged-in users
                    if (_isLoggedIn(context) && cart.selectedOrg != null)
                      _buildLoggedInPricing(cart)
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
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

              // CTA - disabled if logged in but no org selected
              Builder(builder: (context) {
                final canCheckout = !_isLoggedIn(context) || cart.selectedOrgId != null;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: (_loading || !canCheckout) ? null : _continueToCheckout,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Continue to Checkout',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                );
              }),
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

    final cart = context.read<CartModel>();

    // For logged-in users with orgs, validate org selection
    if (_isLoggedIn(context)) {
      if (cart.selectedOrgId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a club')),
        );
        return;
      }
    }

    setState(() => _loading = true);

    try {
      final qty = cart.quantity;
      final origin = Uri.base.origin;

      if (_isLoggedIn(context) && cart.selectedOrgId != null) {
        // Logged-in user or transferred user: use create-checkout-session
        final body = {
          'org_id': cart.selectedOrgId,
          'module_qty': qty,
          'success_url': '$origin/order/success?session_id={CHECKOUT_SESSION_ID}',
          'cancel_url': '$origin/order',
        };

        // If transferred user has a transfer token, include it for authorization
        if (cart.transferToken != null) {
          body['transfer_token'] = cart.transferToken;
        }

        dynamic response;
        try {
          response = await Supabase.instance.client.functions.invoke(
            'create-checkout-session',
            body: body,
          );
        } catch (invokeError) {
          throw Exception('FUNCTION INVOKE ERROR: $invokeError');
        }

        final data = response.data;
        if (data == null) {
          throw Exception('Response data is null. Status: ${response.status}');
        }

        if (data is! Map<String, dynamic>) {
          throw Exception('Response data is not a Map. Got: ${data.runtimeType} - $data');
        }

        final checkoutUrl = data['checkout_url'] as String?;

        if (checkoutUrl != null) {
          web.window.history.replaceState(null, '', '${Uri.base.origin}/order');
          await launchUrl(Uri.parse(checkoutUrl), webOnlyWindowName: '_self');
        } else {
          throw Exception('No checkout URL returned. Response: ${data.keys.toList()}');
        }
      } else {
        // Guest checkout
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

  Widget _buildOrgSelector() {
    final cart = context.watch<CartModel>();
    final orgs = cart.adminOrgs;

    if (orgs.isEmpty) {
      return const Text('Loading organizations...');
    }

    if (orgs.length == 1) {
      // Single org: show as fixed text
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Club/Organization',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            orgs.first.orgName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Divider(),
        ],
      );
    }

    // Multiple orgs: show dropdown
    return FormField<String>(
      initialValue: cart.selectedOrgId,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a club';
        }
        return null;
      },
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Select a club',
            border: const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: cart.selectedOrgId,
              hint: const Text('Select a club'),
              items: orgs.map((org) {
                return DropdownMenuItem(
                  value: org.orgId,
                  child: Text(org.orgName),
                );
              }).toList(),
              onChanged: (value) {
                cart.setSelectedOrgId(value);
                field.didChange(value);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailDisplay(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Email',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          _getUserEmail(context) ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildLoggedInPricing(CartModel cart) {
    final org = cart.selectedOrg;
    if (org == null) {
      return const SizedBox.shrink();
    }

    final qty = cart.quantity;
    final currentQty = org.stripeSubscriptionQty;
    final newTotalQty = currentQty + qty;

    final currentMonthly = cart.pricing.calculateMonthlyCents(currentQty);
    final newMonthly = cart.pricing.calculateMonthlyCents(newTotalQty);
    final additionalMonthly = newMonthly - currentMonthly;

    String formatCents(int cents) {
      return '\$${(cents / 100).toStringAsFixed(0)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription Update (when activated):',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        _buildPriceRow(
          'Current monthly',
          '',
          '${formatCents(currentMonthly)}/mo',
        ),
        const SizedBox(height: 4),
        _buildPriceRow(
          'New monthly',
          '',
          '${formatCents(newMonthly)}/mo',
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Additional cost',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              '+${formatCents(additionalMonthly)}/mo',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ],
    );
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
