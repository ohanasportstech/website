import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF0077C8); // sporty green-teal
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
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark(useMaterial3: true).textTheme),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/about': (context) => const AboutPage(),
        '/docs/privacy-policy': (context) => const MarkdownViewer(assetPath: 'privacy-policy.md', title: 'Ohana Sports Privacy Policy', errorMessage: 'Failed to load Privacy Policy'),
        '/docs/terms-of-use': (context) => const MarkdownViewer(assetPath: 'terms-of-use.md', title: 'Ohana Sports Terms of Use', errorMessage: 'Failed to load Terms of Use'),
      },
    );
  }
}
