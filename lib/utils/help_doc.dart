/// Parser for the structured help document in assets/markdown/help.md.
///
/// The document is plain markdown with two conventions layered on top:
///
///   * `## Heading` starts a section, `### Heading` starts a panel inside it.
///   * An HTML comment directly under a section heading carries its metadata,
///     e.g. `<!-- icon: rocket_launch | audience: player | layout: steps -->`.
///     A comment under a panel heading sets that panel's icon.
///
/// Comments are invisible in any other markdown renderer, so the file stays
/// readable and editable on its own.
library;

enum HelpAudience {
  all('All'),
  player('Players'),
  admin('Club admins');

  const HelpAudience(this.label);

  final String label;

  static HelpAudience parse(String value) {
    switch (value.trim().toLowerCase()) {
      case 'player':
      case 'players':
        return HelpAudience.player;
      case 'admin':
      case 'admins':
        return HelpAudience.admin;
      default:
        return HelpAudience.all;
    }
  }
}

/// How the panels of a section are presented.
enum HelpLayout {
  /// Collapsible panels, the first one open.
  cards,

  /// Numbered walkthrough, all steps visible.
  steps,

  /// Collapsible panels, all closed.
  faq,

  /// No panels; the body is rendered as-is.
  plain;

  static HelpLayout parse(String value) {
    switch (value.trim().toLowerCase()) {
      case 'steps':
        return HelpLayout.steps;
      case 'faq':
        return HelpLayout.faq;
      case 'plain':
        return HelpLayout.plain;
      default:
        return HelpLayout.cards;
    }
  }
}

class HelpPanel {
  final String title;
  final String body;
  final String iconName;

  const HelpPanel({required this.title, required this.body, this.iconName = ''});

  bool matches(String query) => title.toLowerCase().contains(query) || body.toLowerCase().contains(query);
}

class HelpSection {
  final String title;
  final String iconName;
  final HelpAudience audience;
  final HelpLayout layout;
  final String lede;
  final List<HelpPanel> panels;

  const HelpSection({
    required this.title,
    required this.iconName,
    required this.audience,
    required this.layout,
    required this.lede,
    required this.panels,
  });

  bool matches(String query) =>
      title.toLowerCase().contains(query) || lede.toLowerCase().contains(query) || panels.any((p) => p.matches(query));

  bool visibleTo(HelpAudience filter) =>
      filter == HelpAudience.all || audience == HelpAudience.all || audience == filter;
}

class HelpDoc {
  final String lede;
  final List<HelpSection> sections;

  const HelpDoc({required this.lede, required this.sections});
}

final _commentPattern = RegExp(r'^\s*<!--(.*)-->\s*$');

HelpDoc parseHelpDoc(String source) {
  final lede = StringBuffer();
  final sections = <HelpSection>[];

  String? sectionTitle;
  String iconName = '';
  var audience = HelpAudience.all;
  var layout = HelpLayout.cards;
  final sectionLede = StringBuffer();
  var panels = <HelpPanel>[];
  String? panelTitle;
  var panelIcon = '';
  final panelBody = StringBuffer();

  void closePanel() {
    if (panelTitle == null) return;
    panels.add(HelpPanel(title: panelTitle!, body: panelBody.toString().trim(), iconName: panelIcon));
    panelTitle = null;
    panelIcon = '';
    panelBody.clear();
  }

  void closeSection() {
    closePanel();
    if (sectionTitle == null) return;
    sections.add(
      HelpSection(
        title: sectionTitle!,
        iconName: iconName,
        audience: audience,
        layout: layout,
        lede: sectionLede.toString().trim(),
        panels: panels,
      ),
    );
    sectionTitle = null;
    iconName = '';
    audience = HelpAudience.all;
    layout = HelpLayout.cards;
    sectionLede.clear();
    panels = <HelpPanel>[];
  }

  for (final line in source.split('\n')) {
    final comment = _commentPattern.firstMatch(line);
    if (comment != null) {
      final onSectionHeading = sectionTitle != null && panelTitle == null && sectionLede.isEmpty;
      final onPanelHeading = panelTitle != null && panelBody.toString().trim().isEmpty;
      if (onSectionHeading || onPanelHeading) {
        for (final attribute in comment.group(1)!.split('|')) {
          final parts = attribute.split(':');
          if (parts.length < 2) continue;
          final key = parts[0].trim().toLowerCase();
          final value = parts.sublist(1).join(':').trim();
          if (onPanelHeading) {
            if (key == 'icon') panelIcon = value;
            continue;
          }
          switch (key) {
            case 'icon':
              iconName = value;
            case 'audience':
              audience = HelpAudience.parse(value);
            case 'layout':
              layout = HelpLayout.parse(value);
          }
        }
      }
      continue;
    }

    if (line.startsWith('## ') && !line.startsWith('### ')) {
      closeSection();
      sectionTitle = line.substring(3).trim();
      continue;
    }

    if (line.startsWith('### ')) {
      closePanel();
      panelTitle = line.substring(4).trim();
      continue;
    }

    if (panelTitle != null) {
      panelBody.writeln(line);
    } else if (sectionTitle != null) {
      sectionLede.writeln(line);
    } else {
      lede.writeln(line);
    }
  }

  closeSection();

  return HelpDoc(lede: lede.toString().trim(), sections: sections);
}
