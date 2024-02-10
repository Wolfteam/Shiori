import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/shared/details/detail_main_card.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

import '../extensions/widget_tester_extensions.dart';
import '../views/views.dart';

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
    final CommonBottomSheet bottomSheet = await mainPage.tapFilterIcon();
    await bottomSheet.tapOnWeaponImg(WeaponType.claymore);
    await bottomSheet.tapOnRarityStarIcon(4);
    await bottomSheet.tapOnLocationIcon(3);
    await bottomSheet.tapOnSlidersIcon(0);
    await bottomSheet.tapOnButton(onOk: true);
  }

  group('Weapons page', () {
    testWidgets('filter changes but gets reset', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForPrototypeArchaic(widgetTester);

      final mainPage = MainTabPage(widgetTester);
      await mainPage.enterSearchText('');
      final CommonBottomSheet bottomSheet = await mainPage.tapFilterIcon();
      await bottomSheet.tapOnButton(onReset: true);

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

      expect(find.widgetWithText(DetailMainCard, 'Prototype Archaic'), findsOneWidget);

      final DetailPage page = DetailPage(widgetTester);
      if (widgetTester.isUsingDesktopLayout || widgetTester.isLandscape) {
        const expectedDescriptions = <String>[
          'Description',
          'Ascension Materials',
          'Crafting Materials',
          'Builds',
          'Refinements',
          'Stats',
        ];

        await page.doCheckContent(expectedDescriptions);
      } else {
        const expectedDescriptions = <String>[
          'Description',
          'Builds',
          'Crafting Materials',
          'Ascension Materials',
          'Refinements',
        ];
        await page.doCheckInPortrait(expectedDescriptions);
      }
    });
  });
}
