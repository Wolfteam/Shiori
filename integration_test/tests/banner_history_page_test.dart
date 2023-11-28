import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../views/views.dart';

void main() {
  const String character = 'Nahida';
  const String version = '3.2';
  const String weapon = 'A Thousand Floating Dreams';

  Future<void> navigate(WidgetTester widgetTester) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize();
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnBannerHistoryCard();
  }

  Future<void> filter(String name, String version, bool isCharacter, WidgetTester widgetTester) async {
    final DetailPage page = DetailPage(widgetTester);

    //Select the type
    await page.tapOnPopupMenuButtonIcon(Icons.swap_horiz, isCharacter ? 0 : 1);

    //Sort by version desc
    await page.tapOnPopupMenuButtonIcon(Icons.sort, 3);

    //Scroll to version
    final Finder horizontalListViewFinder = find.ancestor(of: find.byIcon(Icons.check_circle), matching: find.byType(ListView)).first;
    await widgetTester.dragUntilVisible(find.text(version), horizontalListViewFinder, BasePage.horizontalDragOffset);
    await widgetTester.pumpAndSettle();

    //Tap on version button
    final Finder versionButton = find.text(version);
    expect(versionButton, findsOneWidget);

    await widgetTester.tap(versionButton);
    await widgetTester.pumpAndSettle();

    //Scroll down until we found item
    final Finder verticalListViewFinder = find.ancestor(of: horizontalListViewFinder, matching: find.byType(ListView));
    await widgetTester.dragUntilVisible(find.text(name), verticalListViewFinder, BasePage.verticalDragOffset);
    await widgetTester.pumpAndSettle();

    //Tap search icon
    await widgetTester.tap(find.byIcon(Icons.search));
    await widgetTester.pumpAndSettle();

    //Filter by item name
    await widgetTester.enterText(find.byType(TextField), name);
    await widgetTester.pumpAndSettle();

    //Select it
    await widgetTester.tap(find.widgetWithText(ListTile, name));
    await widgetTester.pumpAndSettle();

    //Apply search filter
    await widgetTester.tap(find.widgetWithIcon(IconButton, Icons.check));
    await widgetTester.pumpAndSettle();
  }

  Future<void> openCardItemDialog(String name, WidgetTester widgetTester) async {
    final Finder cardFinder = find.widgetWithText(Card, name);
    expect(cardFinder, findsOneWidget);

    await widgetTester.tap(cardFinder);
    await widgetTester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  }

  Future<void> tapOnDetailItemDialogOption(bool details, WidgetTester widgetTester) async {
    final Finder dialogItemsFinder = find.byType(ListTile);
    expect(dialogItemsFinder, findsNWidgets(2));

    //Tap on Details or Release history
    await widgetTester.tap(details ? dialogItemsFinder.first : dialogItemsFinder.last);
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(find.byType(details ? BackButton : ElevatedButton).first);
    await widgetTester.pumpAndSettle();
  }

  group('Banner history page', () {
    testWidgets('filters for $character on version $version', (widgetTester) async {
      await navigate(widgetTester);
      await filter(character, version, true, widgetTester);

      await openCardItemDialog(character, widgetTester);
      await tapOnDetailItemDialogOption(true, widgetTester);

      await openCardItemDialog(character, widgetTester);
      await tapOnDetailItemDialogOption(false, widgetTester);
    });

    testWidgets('filters for $weapon on version $version', (widgetTester) async {
      await navigate(widgetTester);
      await filter(weapon, version, false, widgetTester);

      await openCardItemDialog(weapon, widgetTester);
      await tapOnDetailItemDialogOption(true, widgetTester);

      await openCardItemDialog(weapon, widgetTester);
      await tapOnDetailItemDialogOption(false, widgetTester);
    });
  });
}
