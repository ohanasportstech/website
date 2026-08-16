import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:website/utils/help_doc.dart';

const _kaiBlue = Color(0xFF0077C8);
const _kaiInk = Color(0xFF0A1A2B);
const _wideBreakpoint = 1000.0;

const Map<String, IconData> _sectionIcons = {
  'rocket_launch': Icons.rocket_launch_outlined,
  'play_circle_outline': Icons.play_circle_outline,
  'grid_view': Icons.grid_view_outlined,
  'sports_tennis': Icons.sports_tennis_outlined,
  'sports': Icons.sports_outlined,
  'my_location': Icons.my_location_outlined,
  'movie_filter': Icons.movie_filter_outlined,
  'bluetooth_connected': Icons.bluetooth_connected,
  'workspace_premium': Icons.workspace_premium_outlined,
  'admin_panel_settings': Icons.admin_panel_settings_outlined,
  'help_outline': Icons.help_outline,
  'support_agent': Icons.support_agent_outlined,
  'info': Icons.info_outline,
  'memory': Icons.memory_outlined,
  'shuffle': Icons.shuffle,
  'person': Icons.person_outline,
  'timer': Icons.timer_outlined,
  'favorite': Icons.favorite_border,
  'tune': Icons.tune,
  'share': Icons.ios_share_outlined,
  'inbox': Icons.inbox_outlined,
  'phone_iphone': Icons.phone_iphone,
};

/// Icons taken straight from the Kai app, so the help page and the app agree.
const Map<String, String> _appIcons = {
  'nav_home': 'assets/icons/navHome.svg',
  'nav_drills': 'assets/icons/navDrills.svg',
  'nav_shots': 'assets/icons/navShots.svg',
  'nav_studio': 'assets/icons/navStudio.svg',
};

Widget _helpIcon(String name, {double size = 24, Color color = _kaiBlue}) {
  final asset = _appIcons[name];
  if (asset != null) {
    return SvgPicture.asset(asset, width: size, height: size, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
  }
  return Icon(_sectionIcons[name] ?? Icons.article_outlined, size: size, color: color);
}

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, bool> _overrides = {};

  late final Future<HelpDoc> _doc = _loadDoc();
  HelpAudience _audience = HelpAudience.all;
  String _query = '';
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<HelpDoc> _loadDoc() async {
    return parseHelpDoc(await rootBundle.loadString('assets/markdown/help.md'));
  }

  void _onScroll() {
    final show = _scrollController.offset > 600;
    if (show != _showBackToTop) setState(() => _showBackToTop = show);
  }

  String _panelId(HelpSection section, int index) => '${section.title}#$index';

  /// A panel is open when the reader last opened it, and otherwise falls back
  /// to the default for its layout: steps are always open, and other panels
  /// open only on a search match.
  bool _isExpanded(HelpSection section, int index) {
    final override = _overrides[_panelId(section, index)];
    if (override != null) return override;
    if (section.layout == HelpLayout.steps) return true;
    if (_query.isNotEmpty) return section.panels[index].matches(_query);
    return false;
  }

  void _togglePanel(HelpSection section, int index) {
    final expanded = _isExpanded(section, index);
    setState(() => _overrides[_panelId(section, index)] = !expanded);
  }

  void _onSearch(String value) {
    setState(() {
      _query = value.trim().toLowerCase();
      // Let the new results decide what is open.
      _overrides.clear();
    });
  }

  void _scrollTo(HelpSection section) {
    final key = _sectionKeys[section.title];
    final context = key?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      alignment: 0.05,
    );
  }

  List<HelpSection> _visibleSections(HelpDoc doc) {
    return doc.sections.where((s) => s.visibleTo(_audience)).where((s) => _query.isEmpty || s.matches(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              backgroundColor: _kaiBlue,
              foregroundColor: Colors.white,
              tooltip: 'Back to top',
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              ),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: FutureBuilder<HelpDoc>(
        future: _doc,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_kaiBlue)));
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(24), child: Text('Failed to load Help')),
            );
          }

          final doc = snapshot.data!;
          final sections = _visibleSections(doc);
          final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _Hero(lede: doc.lede, searchController: _searchController, onSearch: _onSearch),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(isWide ? 32 : 16, 28, isWide ? 32 : 16, 96),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AudienceFilter(selected: _audience, onChanged: (value) => setState(() => _audience = value)),
                          const SizedBox(height: 24),
                          if (sections.isEmpty)
                            _EmptyResults(query: _searchController.text)
                          else if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 260,
                                  child: _TableOfContents(sections: sections, onSelected: _scrollTo),
                                ),
                                const SizedBox(width: 32),
                                Expanded(child: _buildSections(sections)),
                              ],
                            )
                          else
                            _buildSections(sections),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSections(List<HelpSection> sections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _SectionCard(
              key: _sectionKeys.putIfAbsent(section.title, GlobalKey.new),
              section: section,
              isExpanded: (index) => _isExpanded(section, index),
              onToggle: (index) => _togglePanel(section, index),
            ),
          ),
      ],
    );
  }
}

// MARK: Hero
class _Hero extends StatelessWidget {
  final String lede;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  const _Hero({required this.lede, required this.searchController, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_kaiInk, _kaiBlue]),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, isWide ? 72 : 44, isWide ? 32 : 20, isWide ? 56 : 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).canPop()
                      ? Navigator.of(context).pop()
                      : Navigator.of(context).pushNamed('/'),
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  label: const Text('Kai Tennis', style: TextStyle(color: Colors.white70)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Help Center',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Text(
                    lede,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85), height: 1.6),
                  ),
                ),
                const SizedBox(height: 28),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearch,
                    style: const TextStyle(color: _kaiInk),
                    decoration: InputDecoration(
                      hintText: 'Search help — drills, sharing, Bluetooth…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              tooltip: 'Clear search',
                              onPressed: () {
                                searchController.clear();
                                onSearch('');
                              },
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: Audience filter
class _AudienceFilter extends StatelessWidget {
  final HelpAudience selected;
  final ValueChanged<HelpAudience> onChanged;

  const _AudienceFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 4),
          child: Text(
            'Show topics for',
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ),
        for (final audience in HelpAudience.values)
          ChoiceChip(
            label: Text(audience.label),
            selected: selected == audience,
            showCheckmark: false,
            selectedColor: _kaiBlue,
            backgroundColor: Colors.white,
            side: BorderSide(color: selected == audience ? _kaiBlue : Colors.black12),
            labelStyle: TextStyle(
              color: selected == audience ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => onChanged(audience),
          ),
      ],
    );
  }
}

// MARK: Table of contents
class _TableOfContents extends StatelessWidget {
  final List<HelpSection> sections;
  final ValueChanged<HelpSection> onSelected;

  const _TableOfContents({required this.sections, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Text(
              'On this page',
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 0.4),
            ),
          ),
          for (final section in sections)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelected(section),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  children: [
                    SizedBox(width: 20, child: Center(child: _helpIcon(section.iconName, size: 18))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(section.title, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// MARK: Section
class _SectionCard extends StatelessWidget {
  final HelpSection section;
  final bool Function(int index) isExpanded;
  final ValueChanged<int> onToggle;

  const _SectionCard({super.key, required this.section, required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: const [BoxShadow(color: Color(0x0D0A1A2B), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _kaiBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: _helpIcon(section.iconName)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  section.title,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: _kaiInk, letterSpacing: -0.5),
                ),
              ),
              if (section.audience != HelpAudience.all)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5FA), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    section.audience.label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54),
                  ),
                ),
            ],
          ),
          if (section.lede.isNotEmpty) ...[const SizedBox(height: 12), HelpMarkdown(data: section.lede)],
          if (section.panels.isNotEmpty) const SizedBox(height: 8),
          for (var i = 0; i < section.panels.length; i++)
            section.layout == HelpLayout.steps
                ? _StepTile(number: i + 1, panel: section.panels[i], isLast: i == section.panels.length - 1)
                : _ExpanderTile(panel: section.panels[i], expanded: isExpanded(i), onTap: () => onToggle(i)),
        ],
      ),
    );
  }
}

// MARK: Panels
class _ExpanderTile extends StatelessWidget {
  final HelpPanel panel;
  final bool expanded;
  final VoidCallback onTap;

  const _ExpanderTile({required this.panel, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: expanded ? const Color(0xFFF7FAFD) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: expanded ? _kaiBlue.withValues(alpha: 0.35) : Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: [
                    if (panel.iconName.isNotEmpty) ...[
                      SizedBox(width: 24, child: Center(child: _helpIcon(panel.iconName, size: 22))),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        panel.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _kaiInk),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(Icons.keyboard_arrow_down, color: _kaiBlue),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: HelpMarkdown(data: panel.body),
              ),
              crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
              sizeCurve: Curves.easeOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int number;
  final HelpPanel panel;
  final bool isLast;

  const _StepTile({required this.number, required this.panel, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _kaiBlue, shape: BoxShape.circle),
                child: Text(
                  '$number',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: _kaiBlue.withValues(alpha: 0.18),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    panel.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kaiInk),
                  ),
                  const SizedBox(height: 4),
                  HelpMarkdown(data: panel.body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final String query;

  const _EmptyResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 40, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            query.isEmpty ? 'Nothing to show for this filter.' : 'No help topics match “$query”.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Email support@ohanasports.net and we’ll help you out.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// MARK: Markdown
class HelpMarkdown extends StatelessWidget {
  final String data;

  const HelpMarkdown({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MarkdownBody(
      data: data,
      onTapLink: (text, href, title) async {
        if (href == null) return;
        if (href.startsWith('/')) {
          if (context.mounted) Navigator.of(context).pushNamed(href);
          return;
        }
        final uri = Uri.parse(href);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyLarge?.copyWith(height: 1.7, color: Colors.black87),
        pPadding: const EdgeInsets.only(bottom: 8),
        listBullet: theme.textTheme.bodyLarge?.copyWith(height: 1.7, color: Colors.black87),
        listIndent: 22,
        listBulletPadding: const EdgeInsets.only(right: 8),
        blockquoteDecoration: BoxDecoration(
          color: const Color(0xFFEFF6FC),
          borderRadius: BorderRadius.circular(12),
          border: const Border(left: BorderSide(color: _kaiBlue, width: 4)),
        ),
        blockquotePadding: const EdgeInsets.all(14),
        a: const TextStyle(color: _kaiBlue, fontWeight: FontWeight.w600),
        strong: const TextStyle(fontWeight: FontWeight.w700, color: _kaiInk),
        code: const TextStyle(backgroundColor: Color(0xFFF1F3F6), fontFamily: 'monospace'),
      ),
    );
  }
}
