import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:website/pages/app_link_fallback.dart';
import 'pages/home.dart';
import 'pages/about.dart';
import 'package:url_strategy/url_strategy.dart';
import 'widgets/markdown_viewer.dart';

void main() {
  setPathUrlStrategy();
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kai Tennis',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
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
        
        // Handle static routes
        final routes = {
          '/': (context) => const HomePage(),
          '/about': (context) => const AboutPage(),
          '/docs/privacy-policy': (context) => const MarkdownViewer(assetPath: 'assets/markdown/privacy-policy.md', title: 'Ohana Sports Privacy Policy', errorMessage: 'Failed to load Privacy Policy'),
          '/docs/terms-of-use': (context) => const MarkdownViewer(assetPath: 'assets/markdown/terms-of-use.md', title: 'Ohana Sports Terms of Use', errorMessage: 'Failed to load Terms of Use'),
          '/pages/data-deletion': (context) => const MarkdownViewer(assetPath: 'assets/markdown/data-deletion.md', title: 'Ohana Sports Data Deletion', errorMessage: 'Failed to load Data Deletion'),
          '/pages/help': (context) => const MarkdownViewer(assetPath: 'assets/markdown/help.md', title: 'Ohana Sports Help', errorMessage: 'Failed to load Help'),
          '/pages/kai-module': (context) => const MarkdownViewer(assetPath: 'assets/markdown/kai-module.md', title: 'Ohana Sports Kai SmartModule', errorMessage: 'Failed to load Kai SmartModule'),
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
    );
  }
}
