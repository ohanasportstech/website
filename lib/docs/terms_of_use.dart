import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  Future<String> _loadMarkdown() async {
    return await rootBundle.loadString('assets/terms-of-use.md');
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: const Text('Terms of Use'),
        backgroundColor: color.surface,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: FutureBuilder<String>(
            future: _loadMarkdown(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Failed to load terms of use.', style: Theme.of(context).textTheme.bodyLarge),
                );
              }
              return Markdown(
                data: snapshot.data ?? '',
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  h1: Theme.of(context).textTheme.headlineMedium,
                  h2: Theme.of(context).textTheme.headlineSmall,
                  p: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
