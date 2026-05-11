import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({super.key});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  late final String? sessionId;
  String orgName = '';
  String email = '';
  int quantity = 0;
  int hardwareTotal = 0;
  int monthlyTotal = 0;
  String? paymentIntentId;
  String? stripeStatus;
  DateTime? orderDate;
  String? shippingName;
  String? shippingLine1;
  String? shippingLine2;
  String? shippingCity;
  String? shippingState;
  String? shippingPostalCode;
  bool _loadingDetails = true;

  @override
  void initState() {
    super.initState();
    sessionId = Uri.base.queryParameters['session_id'];
    if (sessionId != null && sessionId!.isNotEmpty) {
      _fetchOrderDetails();
    }
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-order-details',
        body: {'session_id': sessionId!},
      );
      final data = response.data as Map<String, dynamic>?;
      if (data != null && mounted) {
        setState(() {
          paymentIntentId = data['payment_intent_id'] as String?;
          stripeStatus = data['status'] as String?;
          final createdAt = data['created_at'] as String?;
          orderDate = createdAt != null ? DateTime.tryParse(createdAt)?.toLocal() : null;
          shippingName = data['customer_name'] as String?;
          shippingLine1 = data['shipping_line1'] as String?;
          shippingLine2 = data['shipping_line2'] as String?;
          shippingCity = data['shipping_city'] as String?;
          shippingState = data['shipping_state'] as String?;
          shippingPostalCode = data['shipping_postal_code'] as String?;
          // Fill in sessionStorage-sourced fields from Stripe if empty (revisit case)
          if (orgName.isEmpty) orgName = (data['org_name'] as String?) ?? '';
          if (email.isEmpty) email = (data['customer_email'] as String?) ?? '';
          if (quantity == 0) quantity = (data['module_qty'] as int?) ?? 0;
          if (hardwareTotal == 0) hardwareTotal = (((data['hardware_total_cents'] as int?) ?? 0) / 100).round();
          if (monthlyTotal == 0) monthlyTotal = (((data['monthly_total_cents'] as int?) ?? 0) / 100).round();
          _loadingDetails = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDetails = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sessionId == null || sessionId!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Icon(Icons.check_circle, size: 80, color: Colors.green[600]),
                  const SizedBox(height: 16),
                  Text(
                    'Order received!',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check your email for admin codes to activate your modules.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Order summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _loadingDetails
                          ? _buildLoadingCardContent(theme)
                          : _buildSummaryCardContent(theme),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Download the Kai Tennis app and use your codes to get started.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Download app buttons
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      InkWell(
                        onTap: () => launchUrl(
                          Uri.parse('https://apps.apple.com/us/app/kai-tennis/id6748925788'),
                          mode: LaunchMode.externalApplication,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: SvgPicture.asset('assets/icons/AppStore.svg', height: 44, semanticsLabel: 'Download on the App Store'),
                      ),
                      InkWell(
                        onTap: () => launchUrl(
                          Uri.parse('https://play.google.com/store/apps/details?id=net.OhanaSports.Kai'),
                          mode: LaunchMode.externalApplication,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: SvgPicture.asset('assets/icons/GooglePlay.svg', height: 44, semanticsLabel: 'Get it on Google Play'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                    child: const Text('Close'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCardContent(ThemeData theme) {
    return Center(
      key: const ValueKey('loading'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            Text('Retrieving order details…', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardContent(ThemeData theme) {
    return Column(
      key: const ValueKey('loaded'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _summaryRow(context, 'Order date', orderDate != null ? _formatDate(orderDate!) : '—'),
          const SizedBox(height: 8),
          _summaryRow(context, 'Organization', orgName.isNotEmpty ? orgName : '—'),
          const SizedBox(height: 8),
          _summaryRow(context, 'Contact Email', email.isNotEmpty ? email : '—'),
          const SizedBox(height: 8),
          _summaryRow(context, 'Modules', quantity > 0 ? '$quantity' : '—'),
          const SizedBox(height: 8),
          _summaryRow(context, 'Ship to', _formatShippingAddress()),
          const Divider(height: 24),
          _summaryRow(context, 'Hardware total', '\$$hardwareTotal'),
          const SizedBox(height: 8),
          _summaryRow(context, 'Monthly subscription', '\$$monthlyTotal/mo after 60-day trial'),
          const SizedBox(height: 8),
          _summaryRow(
            context,
            'Transaction ID',
            paymentIntentId ?? sessionId!.substring(0, 24),
            valueStyle: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
          if (stripeStatus != null) ...[
            const SizedBox(height: 8),
            _summaryRow(context, 'Payment status', stripeStatus!.toUpperCase()),
          ],
        ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatShippingAddress() {
    final parts = <String>[
      if (shippingName != null && shippingName!.isNotEmpty) shippingName!,
      if (shippingLine1 != null && shippingLine1!.isNotEmpty) shippingLine1!,
      if (shippingLine2 != null && shippingLine2!.isNotEmpty) shippingLine2!,
      if (shippingCity != null && shippingCity!.isNotEmpty)
        [
          shippingCity!,
          if (shippingState != null && shippingState!.isNotEmpty) shippingState!,
          if (shippingPostalCode != null && shippingPostalCode!.isNotEmpty) shippingPostalCode!,
        ].join(', '),
    ];
    return parts.isNotEmpty ? parts.join('\n') : '—';
  }

  Widget _summaryRow(BuildContext context, String label, String value, {TextStyle? valueStyle}) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Expanded(
          child: Text(value, style: valueStyle ?? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
