import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';

import '../extensions/widget_tester_extensions.dart';
import 'base_page.dart';

class DetailPage extends BasePage {
  const DetailPage(super.tester);

  Future<DetailPage> doCheckInPortrait(List<String> expectedDescriptions) async {
    const verticalOffset = Offset(0, -50);

    final Finder scrollViewFinder = find.byType(SingleChildScrollView);
    expect(scrollViewFinder, findsOneWidget);

    for (final String description in expectedDescriptions) {
      final Finder finder = find.widgetWithText(DetailSection, description);
      await tester.doAppDragUntilVisible(finder, scrollViewFinder, verticalOffset);
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
      await tester.doAppDragUntilVisible(tabFinder, tabControllerFinder, horizontalOffset);

      await tester.tap(tabFinder);
      await tester.pumpAndSettle();

      final Finder scrollViewFinder = find.byType(SingleChildScrollView).first;
      final List<String> descriptions = expectedDescriptions[i].split(';');
      for (final String description in descriptions) {
        final Finder finder = find.widgetWithText(DetailSection, description);
        await tester.doAppDragUntilVisible(finder, scrollViewFinder, verticalOffset);
        await tester.pumpAndSettle();
      }
    }

    return this;
  }

  Future<DetailPage> doCheckContent(List<String> expectedDescriptions) async {
    const Offset verticalOffset = Offset(0, -50);
    final Finder scrollViewFinder = find.byType(SingleChildScrollView).first;
    for (int i = 0; i < expectedDescriptions.length; i++) {
      final List<String> descriptions = expectedDescriptions[i].split(';');
      for (final String description in descriptions) {
        final Finder finder = find.widgetWithText(DetailSection, description);
        await tester.doAppDragUntilVisible(finder, scrollViewFinder, verticalOffset);
        await tester.pumpAndSettle();
      }
    }

    return this;
  }
}
