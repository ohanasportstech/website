import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:website/widgets/login_modal.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _loading = true;
  Map<String, dynamic>? _userStats;
  List<Map<String, dynamic>>? _adminOrgs;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() => _isLoggedIn = user != null);

    if (user != null) {
      await _loadUserData();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Load user stats
      final statsResponse = await Supabase.instance.client
          .rpc('get_stats')
          .select()
          .maybeSingle();

      // Load admin orgs
      final orgsResponse = await Supabase.instance.client
          .from('user_profiles')
          .select('orgs!inner(*)')
          .eq('id', Supabase.instance.client.auth.currentUser!.id);

      setState(() {
        _userStats = statsResponse;
        _adminOrgs = orgsResponse.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not logged in, show login prompt
    if (!_isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please sign in to view your account',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => showLoginModal(
                  context,
                  onSuccess: () => _checkAuthAndLoadData(),
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final nav = Navigator.of(context);
              await Supabase.instance.client.auth.signOut();
              nav.pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: User Stats
                        _buildStatsSection(),
                        const SizedBox(height: 32),

                        // Section 2: Club Management (for admins)
                        if (_adminOrgs != null && _adminOrgs!.isNotEmpty)
                          _buildClubManagementSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatsSection() {
    if (_userStats == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.bar_chart, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Start a session in the Kai Tennis app to see your stats here',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final practiceTime = _userStats!['practice_time_minutes'] ?? 0;
    final drills = _userStats!['drills_completed'] ?? 0;
    final shots = _userStats!['shots_hit'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Practice Time',
                '${practiceTime ~/ 60}h ${practiceTime % 60}m',
                Icons.timer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Drills',
                '$drills',
                Icons.sports_tennis,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Shots',
                '$shots',
                Icons.sports_handball,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Club Management',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...(_adminOrgs ?? []).map((org) => _buildOrgCard(org)),
      ],
    );
  }

  Widget _buildOrgCard(Map<String, dynamic> org) {
    final orgName = org['name'] ?? 'Unknown Club';
    final moduleCount = org['module_count'] ?? 1;
    final status = org['subscription_status'] ?? 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Org header
            Row(
              children: [
                Expanded(
                  child: Text(
                    orgName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'active'
                        ? Colors.green[100]
                        : status == 'trialing'
                            ? Colors.blue[100]
                            : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: status == 'active'
                          ? Colors.green[800]
                          : status == 'trialing'
                              ? Colors.blue[800]
                              : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$moduleCount module${moduleCount > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 32),

            // Add modules section
            Text(
              'Add Modules',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildAddModulesSection(org, moduleCount),
            const SizedBox(height: 16),

            // Billing portal link
            TextButton.icon(
              onPressed: () => _openBillingPortal(org['id']),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Manage billing & invoices'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddModulesSection(Map<String, dynamic> org, int currentCount) {
    final quantityToAdd = ValueNotifier<int>(1);

    return ValueListenableBuilder<int>(
      valueListenable: quantityToAdd,
      builder: (context, quantity, _) {
        final newTotal = currentCount + quantity;
        final hardwareCost = 399 * quantity;
        final newMonthly = _calculateMonthlyCost(newTotal);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quantity selector
            Row(
              children: [
                const Text('Add:'),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: quantity > 1 ? () => quantityToAdd.value-- : null,
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$quantity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: quantity < 10 ? () => quantityToAdd.value++ : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Summary
            Text('New total: $newTotal modules'),
            Text('Hardware charge: \$$hardwareCost'),
            Text('New monthly: \$$newMonthly/mo'),
            const SizedBox(height: 16),

            // CTA
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _addModules(org['id'], newTotal),
                child: const Text('Add Modules & Continue to Checkout'),
              ),
            ),
          ],
        );
      },
    );
  }

  int _calculateMonthlyCost(int quantity) {
    if (quantity == 1) return 199;
    if (quantity == 2) return 199 + 149;
    return 199 + 149 + ((quantity - 2) * 99);
  }

  Future<void> _addModules(String orgId, int newTotal) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'create-checkout-session',
        body: {
          'org_id': orgId,
          'module_qty': newTotal,
          'success_url': '${Uri.base.origin}/#/order-success',
          'cancel_url': '${Uri.base.origin}/#/account',
        },
      );

      final data = response.data as Map<String, dynamic>?;
      final checkoutUrl = data?['checkout_url'] as String?;

      if (checkoutUrl != null) {
        if (mounted) {
          await launchUrl(Uri.parse(checkoutUrl), webOnlyWindowName: '_self');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create checkout session')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating checkout: $e')),
        );
      }
    }
  }

  Future<void> _openBillingPortal(String orgId) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'create-portal-session',
        body: {'org_id': orgId},
      );

      final data = response.data as Map<String, dynamic>?;
      final portalUrl = data?['portal_url'] as String?;

      if (portalUrl != null) {
        if (mounted) {
          await launchUrl(Uri.parse(portalUrl), webOnlyWindowName: '_blank');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening billing portal: $e')),
        );
      }
    }
  }
}
