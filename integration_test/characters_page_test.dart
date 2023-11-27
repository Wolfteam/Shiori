import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/shared/details/detail_general_card.dart';

import 'extensions/widget_tester_extensions.dart';
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
    final CommonBottomSheet bottomSheet = await mainPage.tapFilterIcon();
    await bottomSheet.tapOnElementImg(ElementType.electro);
    await bottomSheet.tapOnWeaponImg(WeaponType.sword);
    await bottomSheet.tapOnRarityStarIcon(5);
    await bottomSheet.tapOnButton(onOk: true);
  }

  group('Characters page', () {
    testWidgets('filter changes but gets reset', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForKeqing(widgetTester);

      final mainPage = MainTabPage(widgetTester);
      await mainPage.enterSearchText('');
      final CommonBottomSheet bottomSheet = await mainPage.tapFilterIcon();
      await bottomSheet.tapOnButton(onReset: true);

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

      final DetailPage page = DetailPage(widgetTester);
      if (widgetTester.isUsingDesktopLayout || widgetTester.isLandscape) {
        const expectedTabTitles = <String>[
          'Description',
          'Passives',
          'Constellations',
          'Materials',
          'Builds',
          'Stats',
        ];
        const expectedDescriptions = <String>[
          'Description;Skills',
          'Passives',
          'Constellations',
          'Ascension Materials;Talents Ascension',
          'Builds',
          'Stats',
        ];

        await page.doCheckInLandscape(expectedTabTitles, expectedDescriptions);
      } else {
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
        await page.doCheckInPortrait(expectedDescriptions);
      }
    });
  });
}
