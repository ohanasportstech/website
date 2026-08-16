import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:website/utils/help_doc.dart';

void main() {
  group('parseHelpDoc', () {
    const source = '''
<!-- lede -->
Intro copy.

## First Section
<!-- icon: rocket_launch | audience: player | layout: steps -->

Section intro.

### Step one

Do the thing.

### Step two

Do the other thing.

## Admin Section
<!-- icon: admin_panel_settings | audience: admin -->

### Only panel

Admin copy.
''';

    test('splits sections, panels and metadata', () {
      final doc = parseHelpDoc(source);

      expect(doc.lede, 'Intro copy.');
      expect(doc.sections.map((s) => s.title), ['First Section', 'Admin Section']);

      final first = doc.sections.first;
      expect(first.iconName, 'rocket_launch');
      expect(first.audience, HelpAudience.player);
      expect(first.layout, HelpLayout.steps);
      expect(first.lede, 'Section intro.');
      expect(first.panels.map((p) => p.title), ['Step one', 'Step two']);
      expect(first.panels.first.body, 'Do the thing.');

      final second = doc.sections.last;
      expect(second.audience, HelpAudience.admin);
      expect(second.layout, HelpLayout.cards);
      expect(second.lede, isEmpty);
    });

    test('metadata comments never leak into rendered copy', () {
      final doc = parseHelpDoc(source);

      expect(doc.lede, isNot(contains('<!--')));
      for (final section in doc.sections) {
        expect(section.lede, isNot(contains('<!--')));
        for (final panel in section.panels) {
          expect(panel.body, isNot(contains('<!--')));
        }
      }
    });

    test('audience filtering', () {
      final doc = parseHelpDoc(source);
      final admin = doc.sections.last;

      expect(admin.visibleTo(HelpAudience.all), isTrue);
      expect(admin.visibleTo(HelpAudience.admin), isTrue);
      expect(admin.visibleTo(HelpAudience.player), isFalse);
    });

    test('search matches titles and bodies', () {
      final doc = parseHelpDoc(source);

      expect(doc.sections.first.matches('other thing'), isTrue);
      expect(doc.sections.first.matches('billing'), isFalse);
    });

    test('the shipped help.md parses into sections with icons', () {
      final doc = parseHelpDoc(File('assets/markdown/help.md').readAsStringSync());

      expect(doc.lede, isNotEmpty);
      expect(doc.sections.length, greaterThan(5));
      for (final section in doc.sections) {
        expect(section.iconName, isNotEmpty, reason: section.title);
        expect(section.title, isNot(startsWith('#')));
      }
      expect(
        doc.sections.any((s) => s.layout == HelpLayout.faq),
        isTrue,
        reason: 'help.md should contain an FAQ section',
      );
    });
  });
}
