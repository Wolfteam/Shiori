import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/shared/details/detail_general_card.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

import 'pages/pages.dart';

void main() {
  Future<void> navigateToTab(WidgetTester widgetTester) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize();
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.doCheckOnWeaponsTab();
  }

  Future<void> filterForPrototypeArchaic(WidgetTester widgetTester) async {
    final mainPage = MainTabPage(widgetTester);
    await mainPage.enterSearchText('archaic');
    await mainPage.tapFilterIcon();
    await mainPage.tapOnWeaponImg(WeaponType.claymore);
    await mainPage.tapOnRarityStarIcon(4);
    await mainPage.tapOnCommonBottomSheetButton(onOk: true);
  }

  group('Weapons page', () {
    testWidgets('filter changes but gets reset', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForPrototypeArchaic(widgetTester);

      final mainPage = MainTabPage(widgetTester);
      await mainPage.enterSearchText('');
      await mainPage.tapFilterIcon();
      await mainPage.tapOnCommonBottomSheetButton(onReset: true);

      final Finder finder = find.byType(WeaponCard);
      expect(finder, findsAtLeastNWidgets(2));
    });

    testWidgets('filter returns 1 result', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForPrototypeArchaic(widgetTester);

      final Finder finder = find.byType(WeaponCard);
      expect(finder, findsOneWidget);
    });

    testWidgets('filter returns 1 result, tap on it and check its details', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForPrototypeArchaic(widgetTester);

      final Finder weaponFinder = find.byType(WeaponCard);
      await widgetTester.tap(weaponFinder);
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(DetailGeneralCard, 'Prototype Archaic'), findsOneWidget);

      const verticalOffset = Offset(0, -50);
      const expectedDescriptions = <String>[
        'Description',
        'Builds',
        'Crafting Materials',
        'Ascension Materials',
        'Refinements',
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
