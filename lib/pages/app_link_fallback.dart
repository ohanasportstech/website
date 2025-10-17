import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLinkFallbackPage extends StatelessWidget {
  final String contentType; // 'playlist' or 'drill'
  final String? contentId;

  const AppLinkFallbackPage({
    super.key,
    required this.contentType,
    this.contentId,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final appleUrl = Uri.parse('https://apps.apple.com/app/kai-tennis/id6738675033');
    final playUrl = Uri.parse('https://play.google.com/store/apps/details?id=net.OhanaSports.Kai');

    // Customize messages based on content type
    final String titleText = 'Open in Kai Tennis';
    final String descriptionWithId = contentType == 'playlist'
        ? 'This playlist is best viewed in the Kai Tennis app.'
        : 'This drill is best viewed in the Kai Tennis app.';
    final String descriptionWithoutId = contentType == 'playlist'
        ? 'View playlists and training content in the Kai Tennis app.'
        : 'View drills and training content in the Kai Tennis app.';
    final String idLabel = contentType == 'playlist' ? 'Playlist ID' : 'Drill ID';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'icons/AppIcon.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  titleText,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  contentId != null ? descriptionWithId : descriptionWithoutId,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Download buttons
                Text(
                  'Download the app to get started:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // App Store Button
                InkWell(
                  onTap: () => launchUrl(appleUrl, mode: LaunchMode.externalApplication),
                  borderRadius: BorderRadius.circular(12),
                  child: SvgPicture.asset(
                    'assets/icons/AppStore.svg',
                    height: 56,
                    semanticsLabel: 'Download on the App Store',
                  ),
                ),
                const SizedBox(height: 16),

                // Google Play Button
                InkWell(
                  onTap: () => launchUrl(playUrl, mode: LaunchMode.externalApplication),
                  borderRadius: BorderRadius.circular(12),
                  child: SvgPicture.asset(
                    'assets/icons/GooglePlay.svg',
                    height: 56,
                    semanticsLabel: 'Get it on Google Play',
                  ),
                ),
                const SizedBox(height: 48),

                // Back to home link
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                  child: Text(
                    'Visit Kai Tennis Website',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ),

                if (contentId != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '$idLabel: $contentId',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black45,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
