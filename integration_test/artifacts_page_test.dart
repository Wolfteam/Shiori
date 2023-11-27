import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
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
    await mainPage.doCheckOnArtifactsTab();
  }

  Future<void> filter(String searchText, int rarity, WidgetTester widgetTester) async {
    final mainPage = MainTabPage(widgetTester);
    await mainPage.enterSearchText(searchText);
    await mainPage.tapFilterIcon();
    await mainPage.tapOnRarityStarIcon(rarity);
    await mainPage.tapOnCommonBottomSheetButton(onOk: true);
  }

  Future<void> filterForGladiator(WidgetTester widgetTester) async {
    return filter('gladiator', 5, widgetTester);
  }

  group('Artifacts page', () {
    testWidgets('filter changes but gets reset', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForGladiator(widgetTester);

      final mainPage = MainTabPage(widgetTester);
      await mainPage.enterSearchText('');
      await mainPage.tapFilterIcon();
      await mainPage.tapOnCommonBottomSheetButton(onReset: true);

      final Finder finder = find.byType(ArtifactCard);
      expect(finder, findsAtLeastNWidgets(2));
    });

    testWidgets('filter returns 1 result', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForGladiator(widgetTester);

      final Finder finder = find.byType(ArtifactCard);
      expect(finder, findsOneWidget);
    });

    testWidgets('filter returns 1 result, tap on it and check its details', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForGladiator(widgetTester);

      final Finder artifactFinder = find.byType(ArtifactCard);
      await widgetTester.tap(artifactFinder);
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(DetailGeneralCard, "Gladiator's Finale"), findsOneWidget);

      final DetailPage page = DetailPage(widgetTester);
      if (widgetTester.isUsingDesktopLayout || widgetTester.isLandscape) {
        const expectedTabTitles = <String>[
          'Description',
          'Builds',
          'Dropped by',
        ];
        const expectedDescriptions = <String>[
          'Bonus;Pieces',
          'Builds',
          'Dropped by',
        ];

        await page.doCheckInLandscape(expectedTabTitles, expectedDescriptions);
      } else {
        const expectedDescriptions = <String>[
          'Bonus',
          'Pieces',
          'Builds',
          'Dropped by',
        ];
        await page.doCheckInPortrait(expectedDescriptions);
      }
    });
  });
}
