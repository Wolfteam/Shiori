import 'package:flutter_test/flutter_test.dart';

import '../views/views.dart';

void main() {
  group('Game codes page', () {
    testWidgets('Refreshes game codes', (widgetTester) async {
      final page = GameCodesPage(widgetTester);
      await page.navigate();
      await page.doPullToRefresh();
    });

    testWidgets('Marks game codes as used', (widgetTester) async {
      final page = GameCodesPage(widgetTester);
      await page.navigate();
      await page.doPullToRefresh();
      await page.markGameCodeAsUsed(0);
    });
  });
}
