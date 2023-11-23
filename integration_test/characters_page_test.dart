import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/shared/details/detail_general_card.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';

import 'pages/pages.dart';

void main() {
  Future<void> navigateToTab(WidgetTester widgetTester) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize();
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.doCheckOnCharactersTab();
  }

  Future<void> filterForKeqing(WidgetTester widgetTester) async {
    final mainPage = MainTabPage(widgetTester);
    await mainPage.enterSearchText('k');
    await mainPage.tapFilterIcon();
    await mainPage.tapOnElementImg(ElementType.electro);
    await mainPage.tapOnWeaponImg(WeaponType.sword);
    await mainPage.tapOnRarityStarIcon(5);
    await mainPage.tapOnCommonBottomSheetButton(onOk: true);
  }

  group('Characters page', () {
    testWidgets('filter changes but gets reset', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForKeqing(widgetTester);

      final mainPage = MainTabPage(widgetTester);
      await mainPage.enterSearchText('');
      await mainPage.tapFilterIcon();
      await mainPage.tapOnCommonBottomSheetButton(onReset: true);

      final Finder finder = find.byType(CharacterCard);
      expect(finder, findsAtLeastNWidgets(2));
    });

    testWidgets('filter returns 1 result', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForKeqing(widgetTester);

      final Finder finder = find.byType(CharacterCard);
      expect(finder, findsOneWidget);
    });

    testWidgets('filter returns 1 result, tap on it and check its details', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForKeqing(widgetTester);

      final Finder keqingFinder = find.byType(CharacterCard);
      await widgetTester.tap(keqingFinder);
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(DetailGeneralCard, 'Keqing'), findsOneWidget);

      const verticalOffset = Offset(0, -50);
      const expectedDescriptions = <String>[
        'Description',
        'Skills',
        'Builds',
        'Ascension Materials',
        'Talents Ascension',
        'Passives',
        'Constellations',
        'Stats',
      ];

      final Finder scrollViewFinder = find.byType(SingleChildScrollView);
      for (final String description in expectedDescriptions) {
        final Finder finder = find.widgetWithText(ItemDescriptionTitle, description);
        await widgetTester.dragUntilVisible(finder, scrollViewFinder, verticalOffset);
        await widgetTester.pumpAndSettle();
      }
    });
  });
}
