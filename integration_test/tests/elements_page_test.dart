import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/elements/widgets/sliver_element_debuffs.dart';
import 'package:shiori/presentation/elements/widgets/sliver_element_reactions.dart';
import 'package:shiori/presentation/elements/widgets/sliver_element_resonances.dart';

import '../views/views.dart';

void main() {
  Future<void> navigate(WidgetTester widgetTester) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize();
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnElementsCard();
  }

  testWidgets('debuffs, reactions and resonances exist', (widgetTester) async {
    await navigate(widgetTester);

    final Finder scrollViewFinder = find.byType(CustomScrollView);
    await widgetTester.dragUntilVisible(find.byType(SliverElementDebuffs), scrollViewFinder, BasePage.verticalDragOffset);
    await widgetTester.dragUntilVisible(find.byType(SliverElementReactions), scrollViewFinder, BasePage.verticalDragOffset);
    await widgetTester.dragUntilVisible(find.byType(SliverElementResonances), scrollViewFinder, BasePage.verticalDragOffset);
  });
}
