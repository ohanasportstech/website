import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownViewer extends StatelessWidget {
  final String assetPath;
  final String title;
  final String errorMessage;
  final double maxWidth;

  const MarkdownViewer({
    super.key,
    required this.assetPath,
    required this.title,
    required this.errorMessage,
    this.maxWidth = 900,
  });

  Future<String> _loadMarkdown() async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      throw Exception('Failed to load markdown from $assetPath');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: FutureBuilder<String>(
            future: _loadMarkdown(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    errorMessage,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.black),
                  ),
                );
              }
              return Markdown(
                data: snapshot.data ?? '',
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.75,
                        color: Colors.black87,
                      ),
                  pPadding: const EdgeInsets.only(bottom: 4.0),
                  blockSpacing: 4.0,
                  h1: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                  h1Padding: const EdgeInsets.only(top: 32.0),
                  h2: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                  h2Padding: const EdgeInsets.only(top: 32.0),
                  h3: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                  h3Padding: const EdgeInsets.only(top: 32.0),
                  h4: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                  h4Padding: const EdgeInsets.only(top: 32.0),
                  listIndent: 24.0,    // Indentation for lists
                  listBulletPadding: const EdgeInsets.only(right: 8.0),  // Space after list bullets
                  a: const TextStyle(color: Colors.blue),
                  code: const TextStyle(backgroundColor: Color(0xFFf5f5f5)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}