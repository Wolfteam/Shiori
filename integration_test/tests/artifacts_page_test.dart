import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/shared/details/detail_main_card.dart';

import '../extensions/widget_tester_extensions.dart';
import '../views/views.dart';

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
    final CommonBottomSheet bottomSheet = await mainPage.tapFilterIcon();
    await bottomSheet.tapOnRarityStarIcon(rarity);
    await bottomSheet.tapOnButton(onOk: true);
  }

  Future<void> filterForGladiator(WidgetTester widgetTester) {
    return filter('gladiator', 5, widgetTester);
  }

  group('Artifacts page', () {
    testWidgets('filter changes but gets reset', (widgetTester) async {
      await navigateToTab(widgetTester);
      await filterForGladiator(widgetTester);

      final mainPage = MainTabPage(widgetTester);
      await mainPage.enterSearchText('');
      final CommonBottomSheet bottomSheet = await mainPage.tapFilterIcon();
      await bottomSheet.tapOnButton(onReset: true);

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

      expect(find.widgetWithText(DetailMainCard, "Gladiator's Finale"), findsOneWidget);

      final DetailPage page = DetailPage(widgetTester);
      if (widgetTester.isUsingDesktopLayout || widgetTester.isLandscape) {
        const expectedDescriptions = <String>[
          'Bonus',
          'Pieces',
          'Builds',
          'Dropped by',
        ];

        await page.doCheckContent(expectedDescriptions);
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
