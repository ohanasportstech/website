import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

/// Production beta feature flag for ordering functionality.
///
/// Ordering is enabled by visiting any page with `?beta=<secret>` in the URL.
/// The secret is validated server-side by a Cloudflare Pages Function so it can
/// be changed from the Cloudflare dashboard without redeploying.
///
/// It can also be enabled programmatically after validating a transfer token
/// from the Kai app "Buy a KAI Module" flow.
///
/// Once enabled, the flag is persisted in localStorage so navigation within
/// the site keeps ordering visible. The public will not see ordering UI unless
/// they have the secret link or a valid transfer token.
class BetaAccess extends ChangeNotifier {
  static const _storageKey = 'kai_beta_access_EM15';
  static const _betaParam = 'beta';

  static final BetaAccess _instance = BetaAccess._internal();
  static BetaAccess get instance => _instance;

  factory BetaAccess() => _instance;

  BetaAccess._internal() {
    _enabled = web.window.localStorage.getItem(_storageKey) == 'true';
  }

  bool _enabled = false;

  bool get isEnabled => _enabled;

  static bool get enabled => instance.isEnabled;

  /// Checks the URL for a beta secret and validates it against the server.
  /// If valid, enables ordering mode and persists it.
  static Future<void> init() async {
    final uri = Uri.parse(web.window.location.href);
    final betaParam = uri.queryParameters[_betaParam];
    if (betaParam == null || betaParam.isEmpty) return;

    final valid = await validateSecret(betaParam);
    if (valid) _instance.enable();
  }

  /// Validates a beta secret against the Cloudflare Pages Function.
  static Future<bool> validateSecret(String secret) async {
    try {
      final response = await http.get(
        Uri.parse('/api/beta-check?secret=${Uri.encodeComponent(secret)}'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Beta secret validation failed: $e');
      return false;
    }
  }

  /// Enables ordering mode and persists it across the session.
  void enable() {
    if (_enabled) return;
    _enabled = true;
    web.window.localStorage.setItem(_storageKey, 'true');
    notifyListeners();
  }

  /// Disables ordering mode and clears the persisted flag.
  void disable() {
    if (!_enabled) return;
    _enabled = false;
    web.window.localStorage.removeItem(_storageKey);
    notifyListeners();
  }
}
