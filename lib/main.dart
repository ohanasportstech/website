import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:website/pages/app_link_fallback.dart';
import 'pages/home.dart';
import 'pages/about.dart';
import 'pages/kai_module.dart';
import 'pages/order_success.dart';
import 'pages/auth_callback.dart';
import 'package:url_strategy/url_strategy.dart';
import 'widgets/markdown_viewer.dart';
import 'widgets/cart.dart';
import 'utils/beta_access.dart';

// Environment configuration for Supabase
// Set the environment via dart-define: --dart-define=SUPABASE_ENV=local|staging|production
// Default is 'local' for development.
//
// Production credentials are hardcoded below (Supabase publishable keys are public
// and safe to ship in client code). Local and staging credentials must be
// supplied via --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUB_KEY=...

const String _supabaseEnv = String.fromEnvironment('SUPABASE_ENV', defaultValue: 'local');

const String _productionSupabaseUrl = 'https://tzjjzybkbkbsnoxxizfx.supabase.co';
const String _productionSupabaseKey = 'sb_publishable_5k2gWvaKSIGHgZJjdelUtw_FgHx_fW1';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  const String dartDefineUrl = String.fromEnvironment('SUPABASE_URL');
  const String dartDefineKey = String.fromEnvironment('SUPABASE_PUB_KEY');

  final String supabaseUrl;
  final String supabasePublishableKey;

  if (_supabaseEnv == 'production') {
    // Production is hardcoded so deployments don't need dart-define values.
    // dart-define can still override it if needed.
    supabaseUrl = dartDefineUrl.isNotEmpty ? dartDefineUrl : _productionSupabaseUrl;
    supabasePublishableKey = dartDefineKey.isNotEmpty ? dartDefineKey : _productionSupabaseKey;
  } else {
    // Local and staging values must be supplied at build time so they are not
    // committed to source control.
    assert(
      dartDefineUrl.isNotEmpty && dartDefineKey.isNotEmpty,
      'SUPABASE_URL and SUPABASE_PUB_KEY must be provided via --dart-define for environment: $_supabaseEnv',
    );
    supabaseUrl = dartDefineUrl;
    supabasePublishableKey = dartDefineKey;
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  // Validate any beta secret in the URL against the Cloudflare Pages Function.
  await BetaAccess.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  TextStyle? _scaleStyle(TextStyle? s, double factor) =>
      s?.copyWith(fontSize: s.fontSize != null ? s.fontSize! * factor : null);

  TextTheme _scaledTextTheme(TextTheme base, double factor) {
    return base.copyWith(
      displayLarge: _scaleStyle(base.displayLarge, factor),
      displayMedium: _scaleStyle(base.displayMedium, factor),
      displaySmall: _scaleStyle(base.displaySmall, factor),
      headlineLarge: _scaleStyle(base.headlineLarge, factor),
      headlineMedium: _scaleStyle(base.headlineMedium, factor),
      headlineSmall: _scaleStyle(base.headlineSmall, factor),
      titleLarge: _scaleStyle(base.titleLarge, factor),
      titleMedium: _scaleStyle(base.titleMedium, factor),
      titleSmall: _scaleStyle(base.titleSmall, factor),
      bodyLarge: _scaleStyle(base.bodyLarge, factor),
      bodyMedium: _scaleStyle(base.bodyMedium, factor),
      bodySmall: _scaleStyle(base.bodySmall, factor),
      labelLarge: _scaleStyle(base.labelLarge, factor),
      labelMedium: _scaleStyle(base.labelMedium, factor),
      labelSmall: _scaleStyle(base.labelSmall, factor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF0077C8); // kaiBlue

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => BetaAccess.instance),
      ],
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kai Tennis',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
      ),
      builder: (context, child) {
        final width = MediaQuery.sizeOf(context).width;
        // Scale down typography when viewport is narrow
        final scale = (width / 1000).clamp(0.8, 1.0);
        final theme = Theme.of(context);
        final adjustedTextTheme = _scaledTextTheme(theme.textTheme, scale);
        return Theme(
          data: theme.copyWith(textTheme: adjustedTextTheme),
          child: child!,
        );
      },
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        final path = uri.path;
        
        // Handle routes with query parameters
        if (path == '/playlist') {
          final id = uri.queryParameters['id'];
          return MaterialPageRoute(
            builder: (context) => AppLinkFallbackPage(
              contentType: 'playlist',
              contentId: id,
            ),
            settings: settings,
          );
        }
        
        if (path == '/drill') {
          final id = uri.queryParameters['id'];
          return MaterialPageRoute(
            builder: (context) => AppLinkFallbackPage(
              contentType: 'drill',
              contentId: id,
            ),
            settings: settings,
          );
        }

        if (path == '/invite') {
          final code = uri.queryParameters['code'];
          return MaterialPageRoute(
            builder: (context) => AppLinkFallbackPage(
              contentType: 'invite',
              contentId: code,
            ),
            settings: settings,
          );
        }
        
        // Handle static routes
        // Ordering routes are gated behind the beta feature flag in production.
        final orderingRoutes = {'/order/success'};
        if (orderingRoutes.contains(path) && !BetaAccess.enabled) {
          return MaterialPageRoute(
            builder: (context) => const HomePage(),
            settings: settings,
          );
        }

        final routes = {
          '/': (context) => const HomePage(),
          '/about': (context) => const AboutPage(),
          '/docs/privacy-policy': (context) => const MarkdownViewer(assetPath: 'assets/markdown/privacy-policy.md', title: 'Ohana Sports Privacy Policy', errorMessage: 'Failed to load Privacy Policy'),
          '/docs/terms-of-use': (context) => const MarkdownViewer(assetPath: 'assets/markdown/terms-of-use.md', title: 'Ohana Sports Terms of Use', errorMessage: 'Failed to load Terms of Use'),
          '/pages/data-deletion': (context) => const MarkdownViewer(assetPath: 'assets/markdown/data-deletion.md', title: 'Ohana Sports Data Deletion', errorMessage: 'Failed to load Data Deletion'),
          '/pages/help': (context) => const MarkdownViewer(assetPath: 'assets/markdown/help.md', title: 'Ohana Sports Help', errorMessage: 'Failed to load Help'),
          '/kai-module': (context) => const KaiModulePage(),
          '/order/success': (context) => const OrderSuccessPage(),
          '/auth/callback': (context) => const AuthCallbackPage(),
          '/pages/subscription': (context) => const MarkdownViewer(assetPath: 'assets/markdown/subscription.md', title: 'Ohana Sports Subscription', errorMessage: 'Failed to load Subscription'),
        };
        
        if (routes.containsKey(path)) {
          return MaterialPageRoute(
            builder: routes[path]!,
            settings: settings,
          );
        }
        
        // 404 - redirect to home
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
          settings: settings,
        );
      },
      ),
    );
  }
}
