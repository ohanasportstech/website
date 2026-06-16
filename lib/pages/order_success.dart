import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:website/widgets/header.dart';

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
  String? orderId;
  String? stripeStatus;
  DateTime? orderDate;
  String? shippingName;
  String? shippingLine1;
  String? shippingLine2;
  String? shippingCity;
  String? shippingState;
  String? shippingPostalCode;
  bool isAdditionalModules = false;
  bool _loadingDetails = true;
  double _summaryOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    sessionId = Uri.base.queryParameters['session_id'];
    if (sessionId != null && sessionId!.isNotEmpty) {
      _fetchOrderDetails();
    }
  }

  Future<void> _fetchOrderDetails({int attempt = 0}) async {
    const maxAttempts = 5;
    const delays = [0, 1500, 3000, 5000, 8000]; // ms before each attempt
    try {
      if (attempt > 0) {
        await Future.delayed(Duration(milliseconds: delays[attempt]));
      }
      if (!mounted) return;

      final response = await Supabase.instance.client.functions.invoke(
        'get-order-details',
        body: {'session_id': sessionId!},
      );
      final data = response.data as Map<String, dynamic>?;

      // Retry if we got no data or a clearly incomplete response (e.g. cold-start
      // race or webhook not yet written to DB).
      if ((data == null || data['status'] == null) && attempt < maxAttempts - 1) {
        return _fetchOrderDetails(attempt: attempt + 1);
      }

      if (data != null && mounted) {
        setState(() {
          orderId = data['order_id'] as String?;
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
          isAdditionalModules = data['is_additional_modules'] as bool? ?? false;
          _loadingDetails = false;
        });
        // Trigger fade-in on the next frame so AnimatedOpacity sees the 0→1 transition
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _summaryOpacity = 1.0);
        });
      }
    } catch (_) {
      if (attempt < maxAttempts - 1) {
        return _fetchOrderDetails(attempt: attempt + 1);
      }
      if (mounted) setState(() { _loadingDetails = false; _summaryOpacity = 1.0; });
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
      body: Stack(
        children: [
          SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 136, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset('assets/icons/AppIcon.png', width: 80, height: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thanks for your order!',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check your email for more information and module activation codes.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Order summary card
                  Container(
                    width: double.infinity,
                    height: 400,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _loadingDetails
                        ? _buildLoadingCardContent(theme)
                        : AnimatedOpacity(
                            opacity: _summaryOpacity,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                            child: _buildSummaryCardContent(theme),
                          ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Download the Kai Tennis app today!',
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
                ],
              ),
            ),
          ),
        ),
      ),
          GlassHeader(
            onLogoPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            onGetKaiPressed: () => Navigator.of(context).pushNamed('/kai-module'),
            onHowItWorksPressed: () => Navigator.of(context).pushNamed('/?section=how-it-works'),
            onClubsPressed: () => Navigator.of(context).pushNamed('/?section=clubs'),
            onPlayersPressed: () => Navigator.of(context).pushNamed('/?section=players'),
          ),
        ],
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
          _summaryRow(context, 'Monthly subscription', isAdditionalModules ? '\$$monthlyTotal/mo' : '\$$monthlyTotal/mo after 60-day trial'),
          const SizedBox(height: 8),
          if (orderId != null)
            _summaryRow(
              context,
              'Order ID',
              orderId!.substring(0, 8).toUpperCase()
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
