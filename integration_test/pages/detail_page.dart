import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';

import 'base_page.dart';

class DetailPage extends BasePage {
  const DetailPage(super.tester);

  Future<DetailPage> doCheckInPortrait(List<String> expectedDescriptions) async {
    const verticalOffset = Offset(0, -50);

    final Finder scrollViewFinder = find.byType(SingleChildScrollView);
    expect(scrollViewFinder, findsOneWidget);

    for (final String description in expectedDescriptions) {
      final Finder finder = find.widgetWithText(ItemDescriptionTitle, description);
      await tester.dragUntilVisible(finder, scrollViewFinder, verticalOffset);
      await tester.pumpAndSettle();
    }

    return this;
  }

  Future<DetailPage> doCheckInLandscape(List<String> expectedTabTitles, List<String> expectedDescriptions) async {
    assert(expectedTabTitles.isNotEmpty);
    assert(expectedDescriptions.isNotEmpty);

    const horizontalOffset = Offset(-50, 0);
    const verticalOffset = Offset(0, -50);

    final Finder tabControllerFinder = find.byType(TabBar);
    expect(tabControllerFinder, findsOneWidget);

    for (int i = 0; i < expectedTabTitles.length; i++) {
      final String tabTitle = expectedTabTitles[i];
      final Finder tabFinder = find.widgetWithText(Tab, tabTitle);
      expect(tabFinder, findsOneWidget);
      await tester.dragUntilVisible(tabFinder, tabControllerFinder, horizontalOffset);

      await tester.tap(tabFinder);
      await tester.pumpAndSettle();

      final Finder scrollViewFinder = find.byType(SingleChildScrollView).first;
      final List<String> descriptions = expectedDescriptions[i].split(';');
      for (final String description in descriptions) {
        final Finder finder = find.widgetWithText(ItemDescriptionTitle, description);
        await tester.dragUntilVisible(finder, scrollViewFinder, verticalOffset);
        await tester.pumpAndSettle();
      }
    }

    return this;
  }
}
