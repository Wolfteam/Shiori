import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/elements/widgets/element_debuff_card.dart';
import 'package:shiori/presentation/elements/widgets/element_reaction_card.dart';
import 'package:shiori/presentation/elements/widgets/sliver_element_debuffs.dart';
import 'package:shiori/presentation/elements/widgets/sliver_element_reactions.dart';
import 'package:shiori/presentation/elements/widgets/sliver_element_resonances.dart';

import '../extensions/widget_tester_extensions.dart';
import '../game_data.dart';
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

  group('Elements page', () {
    testWidgets('debuffs, reactions and resonances exist', (widgetTester) async {
      await navigate(widgetTester);

      final Finder scrollViewFinder = find.byType(CustomScrollView);
      await widgetTester.doAppDragUntilVisible(find.byType(SliverElementDebuffs), scrollViewFinder, BasePage.verticalDragOffset);
      await widgetTester.doAppDragUntilVisible(
        find.byType(SliverElementReactions),
        scrollViewFinder,
        BasePage.verticalDragOffset,
      );
      await widgetTester.doAppDragUntilVisible(
        find.byType(SliverElementResonances),
        scrollViewFinder,
        const Offset(0, BasePage.verticalScrollDelta * -5),
      );

      expect(
        find.descendant(of: find.byType(SliverElementDebuffs), matching: find.byType(ElementDebuffCard)),
        findsNWidgets(GameData.elementDebuffCount),
        reason: 'Elements page must render all ${GameData.elementDebuffCount} elemental debuffs from elements.json',
      );
      expect(
        find.descendant(of: find.byType(SliverElementReactions), matching: find.byType(ElementReactionCard)),
        findsNWidgets(GameData.elementReactionCount),
        reason: 'Elements page must render all ${GameData.elementReactionCount} elemental reactions from elements.json',
      );
      expect(
        find.descendant(of: find.byType(SliverElementResonances), matching: find.byType(ElementReactionCard)),
        findsNWidgets(GameData.elementResonanceCount),
        reason: 'Elements page must render all ${GameData.elementResonanceCount} resonances from elements.json',
      );
    });
  });
}
