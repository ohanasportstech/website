import 'package:flutter_test/flutter_test.dart';

import 'package:website/strings.dart';

void main() {
  test('Ordering copy is configured for public launch', () {
    expect(Strings.navOrderKai, 'Order Kai');
    expect(Strings.ctaOrderKai, 'Order Kai');
    expect(Strings.faq3A, contains('available to order now'));
  });
}
