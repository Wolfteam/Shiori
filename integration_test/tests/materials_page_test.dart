import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/materials/widgets/material_card.dart';
import 'package:shiori/presentation/shared/details/detail_general_card.dart';

import '../extensions/widget_tester_extensions.dart';
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
    await bottomSheet.tapOnRarityStarIcon(2);
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
      expect(finder, findsAtLeastNWidgets(3));
    });

    testWidgets('filter returns 1 result', (widgetTester) async {
      await navigate(widgetTester);
      await filterForStainedMask(widgetTester);

      final Finder finder = find.byType(MaterialCard);
      expect(finder, findsOneWidget);
    });

    testWidgets('filter returns 1 result, tap on it and check its details', (widgetTester) async {
      await navigate(widgetTester);
      await filterForStainedMask(widgetTester);

      final Finder cardFinder = find.byType(MaterialCard);
      await widgetTester.tap(cardFinder);
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(DetailGeneralCard, 'Stained Mask'), findsOneWidget);

      const expectedDescriptions = <String>[
        'Description',
        'Obtained From',
        'Characters',
        'Weapons',
        'Related',
        'Dropped by',
      ];
      final DetailPage page = DetailPage(widgetTester);
      if (widgetTester.isUsingDesktopLayout || widgetTester.isLandscape) {
        await page.doCheckInLandscape(expectedDescriptions, expectedDescriptions);
      } else {
        await page.doCheckInPortrait(expectedDescriptions);
      }
    });
  });
}
