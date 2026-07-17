import 'package:flutter/material.dart';

class FeatureSection extends StatelessWidget {
  final String header;
  final String subHeader;
  final List<String> bullets;
  final String image;
  final bool isMobile;
  final double spacing;

  const FeatureSection({
    super.key,
    required this.header,
    required this.subHeader,
    required this.bullets,
    required this.image,
    required this.isMobile,
    this.spacing = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(height: isMobile ? 24 : 40),
        isMobile ? _buildMobileBody(context) : _buildDesktopBody(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(
          subHeader,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildBullets(context)),
        SizedBox(width: spacing * 2),
        Expanded(flex: 4, child: _buildImage(context)),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(context),
        SizedBox(height: spacing),
        _buildBullets(context),
      ],
    );
  }

  Widget _buildBullets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bullets.map((bullet) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•  ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600], height: 1.5),
              ),
              Expanded(
                child: Text(
                  bullet,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600], height: 1.5),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(aspectRatio: 1.0, child: Image.asset(image, fit: BoxFit.cover)),
    );
  }
}
