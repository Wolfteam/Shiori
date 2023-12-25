import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../views/views.dart';

void main() {
  Future<void> navigate(WidgetTester widgetTester) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize();
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnChartsCard();
  }

  group('Charts page', () {
    testWidgets('all data exist', (widgetTester) async {
      await navigate(widgetTester);

      final Finder scrollViewFinder = find.byType(ListView).first;

      final expected = <String>[
        'Top characters',
        'Top weapons',
        'Elements',
        'Birthdays',
        'Ascension Stats',
        'Regions',
        'Genders',
      ];

      for (final String title in expected) {
        await widgetTester.dragUntilVisible(find.widgetWithText(Column, title), scrollViewFinder, BasePage.verticalDragOffset);
        expect(find.descendant(of: find.widgetWithText(Column, title), matching: find.byType(Card)), findsAtLeastNWidgets(1));
      }
    });
  });
}
