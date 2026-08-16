import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/materials/widgets/material_card.dart';
import 'package:shiori/presentation/shared/details/detail_main_card.dart';

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
    await mainPage.tapOnMaterialsCard();
  }

  Future<void> filterForStainedMask(WidgetTester widgetTester) async {
    final mainPage = MainTabPage(widgetTester);
    await mainPage.enterSearchText('stained');
    final CommonBottomSheet bottomSheet = await mainPage.tapFilterIcon();
    await bottomSheet.tapOnRarityStarIcon(GameData.stainedMask.rarity);
    await bottomSheet.tapOnButton(onOk: true);
  }

  group('Materials page', () {
    testWidgets('filter changes but gets reset', (widgetTester) async {
      await navigate(widgetTester);
      await filterForStainedMask(widgetTester);

      final mainPage = MainTabPage(widgetTester);
      await mainPage.enterSearchText('');
      final CommonBottomSheet bottomSheet = await mainPage.tapFilterIcon();
      await bottomSheet.tapOnButton(onReset: true);

      final Finder finder = find.byType(MaterialCard);
      expect(
        finder,
        findsAtLeastNWidgets(3),
        reason: 'Resetting the filters should show the full material grid again (>= 3 cards)',
      );
    });

    testWidgets('filter returns 1 result', (widgetTester) async {
      await navigate(widgetTester);
      await filterForStainedMask(widgetTester);

      final Finder finder = find.byType(MaterialCard);
      expect(
        finder,
        findsOneWidget,
        reason: 'Filtering for ${GameData.stainedMask.name} should leave exactly one material card',
      );

      final MaterialCard card = widgetTester.widget<MaterialCard>(finder);
      expect(
        card.keyName,
        GameData.stainedMask.key,
        reason: 'Filtering must isolate ${GameData.stainedMask.name} (key ${GameData.stainedMask.key})',
      );
      expect(
        card.rarity,
        GameData.stainedMask.rarity,
        reason: '${GameData.stainedMask.name} must render as a ${GameData.stainedMask.rarity}★ material',
      );
      expect(
        card.type,
        GameData.stainedMask.type,
        reason: '${GameData.stainedMask.name} must be a ${GameData.stainedMask.type.name} material',
      );
    });

    testWidgets('filter returns 1 result, tap on it and check its details', (widgetTester) async {
      await navigate(widgetTester);
      await filterForStainedMask(widgetTester);

      final Finder cardFinder = find.byType(MaterialCard);
      await widgetTester.tap(cardFinder);
      await widgetTester.pumpAndSettle();

      expect(
        find.widgetWithText(DetailMainCard, GameData.stainedMask.name),
        findsOneWidget,
        reason: 'Tapping the card must open the ${GameData.stainedMask.name} detail page',
      );

      const expectedDescriptions = <String>[
        'Description',
        'Obtained From',
        'Related',
        'Characters',
        'Weapons',
        'Dropped by',
      ];
      final DetailPage page = DetailPage(widgetTester);
      if (widgetTester.isUsingDesktopLayout || widgetTester.isLandscape) {
        await page.doCheckContent(expectedDescriptions);
      } else {
        await page.doCheckInPortrait(expectedDescriptions);
      }
    });
  });
}
