import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/shared/gradient_card.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../extensions/widget_tester_extensions.dart';
import '../views/views.dart';

void main() {
  const String character = 'Nahida';
  const double version = 3.2;
  const String weapon = 'A Thousand Floating Dreams';

  Future<void> navigate(WidgetTester widgetTester) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize();
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnBannerHistoryCard();
  }

  Future<void> filter(String name, double version, bool isCharacter, WidgetTester widgetTester) async {
    final DetailPage page = DetailPage(widgetTester);
    //Select the type
    await page.tapOnPopupMenuButtonIcon(Icons.swap_horiz, isCharacter ? 0 : 1);

    //Sort by version desc
    await page.tapOnPopupMenuButtonIcon(Icons.sort, 7);

    //Scroll to version
    final versionString = version.toStringAsFixed(1);
    final Finder table = find.byType(TableView);
    final double horizontalScrollDelta = -min(BasePage.horizontalScrollDelta, widgetTester.getWidth(3));
    final Offset horizontalOffset = Offset(horizontalScrollDelta, 0);
    await widgetTester.doAppDragUntilVisible(find.text(versionString), table, horizontalOffset);
    await widgetTester.pumpAndSettle();

    //Kinda hack, for some reason the drag ends up being in a weird position, so we have to go back
    await widgetTester.drag(table, Offset(horizontalScrollDelta.abs(), 0));
    await widgetTester.pumpAndSettle();

    //Tap on version button
    final Finder versionButton = find.text(versionString);
    expect(versionButton, findsOneWidget);

    await widgetTester.tap(versionButton);
    await widgetTester.pumpAndSettle();

    //Scroll down until we found item
    await widgetTester.doAppDragUntilVisible(find.text(name), table, BasePage.verticalDragOffset);
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
    final Finder cardFinder = find.widgetWithText(GradientCard, name);
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
    await widgetTester.tap(find.byType(details ? BackButton : FilledButton).first);
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
