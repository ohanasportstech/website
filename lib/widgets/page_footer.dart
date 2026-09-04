import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:website/strings.dart';

/// Horizontal quick links used above the footer on the home and about pages.
class QuickLinksSection extends StatelessWidget {
  const QuickLinksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final legalItems = const [
      [Strings.legalTermsOfUse, '/docs/terms-of-use'],
      [Strings.legalTermsOfPurchase, '/docs/terms-of-purchase'],
      [Strings.legalPrivacyPolicy, '/docs/privacy-policy'],
      [Strings.legalCopyrightPolicy, '/docs/copyright-policy'],
      [Strings.legalDataDeletion, '/pages/data-deletion'],
      [Strings.legalWarranty, '/docs/warranty'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _textLink(context, Strings.quickLinksHelpCenter, () => _navigate(context, '/pages/help')),
            _LegalDropdown(items: legalItems, onSelected: (route) => _navigate(context, route)),
            _textLink(context, Strings.quickLinksFaq, () => _navigate(context, '/pages/help?section=faq')),
            _textLink(context, Strings.quickLinksAboutUs, () => _navigate(context, '/about')),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  Widget _textLink(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      mouseCursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _LegalDropdown extends StatelessWidget {
  final List<List<String>> items;
  final ValueChanged<String> onSelected;

  const _LegalDropdown({required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      tooltip: '',
      itemBuilder: (context) =>
          items.map((item) => PopupMenuItem<String>(value: item[1], child: Text(item[0]))).toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Strings.quickLinksLegal,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 20),
          ],
        ),
      ),
    );
  }
}

/// App store download badges.
class GetTheAppSection extends StatelessWidget {
  const GetTheAppSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appleUrl = Uri.parse('https://apps.apple.com/us/app/kai-tennis/id6748925788');
    final playUrl = Uri.parse('https://play.google.com/store/apps/details?id=net.OhanaSports.Kai');
    return Container(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width < 700 ? 20 : 80,
        30,
        MediaQuery.sizeOf(context).width < 700 ? 20 : 80,
        20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: [
                  InkWell(
                    onTap: () => launchUrl(appleUrl, mode: LaunchMode.externalApplication),
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(
                      'assets/icons/AppStore.svg',
                      height: 44,
                      semanticsLabel: 'Download on the App Store',
                    ),
                  ),
                  InkWell(
                    onTap: () => launchUrl(playUrl, mode: LaunchMode.externalApplication),
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(
                      'assets/icons/GooglePlay.svg',
                      height: 44,
                      semanticsLabel: 'Get it on Google Play',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Social links, copyright, and tagline used at the very bottom of pages.
class Footer extends StatelessWidget {
  const Footer({super.key});

  Future<void> _launchSocial(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _socialIcon(String asset, String url, String label) {
    return InkWell(
      onTap: () => _launchSocial(url),
      borderRadius: BorderRadius.circular(8),
      mouseCursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(
          asset,
          height: 32,
          semanticsLabel: label,
          colorFilter: ColorFilter.mode(Colors.grey[800]!, BlendMode.srcIn),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _socialIcon('assets/icons/youtube.svg', Strings.socialYouTube, 'YouTube'),
                  _socialIcon('assets/icons/facebook.svg', Strings.socialFacebook, 'Facebook'),
                  _socialIcon('assets/icons/instagram.svg', Strings.socialInstagram, 'Instagram'),
                  _socialIcon('assets/icons/tiktok.svg', Strings.socialTikTok, 'TikTok'),
                  _socialIcon('assets/icons/x.svg', Strings.socialX, 'X'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(Strings.footerCopyright),
              const SizedBox(height: 8),
              const Text(Strings.footerTagline),
              const SizedBox(height: 400),
            ],
          ),
        ),
      ),
    );
  }
}
