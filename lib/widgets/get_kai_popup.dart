import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class GetKaiPopup extends StatelessWidget {
  const GetKaiPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? double.infinity : 800,
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: isMobile
                  ? _buildMobileLayout(context)
                  : _buildDesktopLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Get the App
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/app1.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kai Tennis App',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStoreBadges(),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Right column - Kai Module
        Expanded(
          child: Column(
            children: [
              // Module image placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.sports_tennis, size: 80, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kai Module',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // CTA button
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/kai-module');
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: const Text(
                  'Learn More',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/app1.png',
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Kai Tennis App',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildStoreBadges(),
        const Divider(height: 32),
        // Kai Module section
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.sports_tennis, size: 60, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Kai Module',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/kai-module');
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
          child: const Text(
            'Learn More',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreBadges() {
    final appleUrl = Uri.parse('https://apps.apple.com/us/app/kai-tennis/id6748925788');
    final playUrl = Uri.parse('https://play.google.com/store/apps/details?id=net.OhanaSports.Kai');
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        InkWell(
          onTap: () => launchUrl(appleUrl, mode: LaunchMode.externalApplication),
          borderRadius: BorderRadius.circular(12),
          child: SvgPicture.asset(
            'assets/icons/AppStore.svg',
            height: 36,
            semanticsLabel: 'Download on the App Store',
          ),
        ),
        InkWell(
          onTap: () => launchUrl(playUrl, mode: LaunchMode.externalApplication),
          borderRadius: BorderRadius.circular(12),
          child: SvgPicture.asset(
            'assets/icons/GooglePlay.svg',
            height: 36,
            semanticsLabel: 'Get it on Google Play',
          ),
        ),
      ],
    );
  }
}

// Helper function to show the popup
void showGetKaiPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const GetKaiPopup(),
  );
}
