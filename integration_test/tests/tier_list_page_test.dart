import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/images/character_icon_image.dart';
import 'package:shiori/presentation/tierlist/widgets/tierlist_row.dart';

import '../views/views.dart';

void main() {
  group('Tier list builder page', () {
    testWidgets('clears all data', (widgetTester) async {
      final page = TierListPage(widgetTester);

      await page.navigate();

      await page.tapClearAllButton();

      expect(find.byType(Draggable<ItemCommon>), findsAtLeastNWidgets(3));
    });

    testWidgets('clears all data and restores it', (widgetTester) async {
      final page = TierListPage(widgetTester);

      await page.navigate();

      await page.tapClearAllButton();
      await page.tapRestoreButton();

      expect(find.byType(Draggable<ItemCommon>), findsNothing);
    });

    testWidgets('drags 3 items to the empty tier list', (widgetTester) async {
      final page = TierListPage(widgetTester);

      await page.navigate();

      await page.tapClearAllButton();

      for (int i = 0; i < 3; i++) {
        await page.dragFirstItemToRow('SS');
      }

      final Finder charactersFinder = find.descendant(of: find.byType(TierListRow), matching: find.byType(CharacterIconImage));
      expect(charactersFinder, findsNWidgets(3));
    });

    testWidgets('drags 3 items to the empty tier list and changes its order', (widgetTester) async {
      final page = TierListPage(widgetTester);

      await page.navigate();

      await page.tapClearAllButton();

      for (int i = 0; i < 3; i++) {
        final String row = 'S' * (i + 1);
        await page.dragFirstItemToRow(row);
      }

      final Finder charactersFinder = find.descendant(of: find.byType(TierListRow), matching: find.byType(CharacterIconImage));
      expect(charactersFinder, findsNWidgets(3));

      //Move SSS 2 rows below
      for (int i = 0; i < 2; i++) {
        await page.tapRowUpDownButton(i);
      }
      //Move S 1 row above
      await page.tapRowUpDownButton(1, down: false);

      for (int i = 0; i < 3; i++) {
        final String row = 'S' * (i + 1);
        final Finder rowFinder = find.byType(TierListRow).at(i);
        expect(find.descendant(of: rowFinder, matching: find.text(row)), findsOneWidget);
      }
    });

    testWidgets('drags 3 items to different rows, and clears one of them', (widgetTester) async {
      final page = TierListPage(widgetTester);

      await page.navigate();

      await page.tapClearAllButton();

      for (int i = 0; i < 3; i++) {
        final String row = 'S' * (i + 1);
        await page.dragFirstItemToRow(row);
      }

      const int rowIndex = 1;
      expect(
        find.descendant(of: find.byType(TierListRow).at(rowIndex), matching: find.byType(CharacterIconImage)),
        findsOneWidget,
      );

      await page.tapOnSettingPopupMenuItem(rowIndex, 4);

      expect(find.descendant(of: find.byType(TierListRow).at(rowIndex), matching: find.byType(CharacterIconImage)), findsNothing);
    });

    testWidgets('adds row above SSS', (widgetTester) async {
      final page = TierListPage(widgetTester);

      await page.navigate();

      await page.tapClearAllButton();

      const String row = 'SSS';
      expect(
        find.byWidgetPredicate((widget) => widget is TierListRow && widget.index == 0 && widget.title == row),
        findsOneWidget,
      );
      await page.tapOnSettingPopupMenuItem(0, 0);
      expect(
        find.byWidgetPredicate((widget) => widget is TierListRow && widget.index == 1 && widget.title == row),
        findsOneWidget,
      );
    });

    testWidgets('adds row below SSS', (widgetTester) async {
      final page = TierListPage(widgetTester);

      await page.navigate();

      await page.tapClearAllButton();

      const String row = 'SS';
      expect(
        find.byWidgetPredicate((widget) => widget is TierListRow && widget.index == 1 && widget.title == row),
        findsOneWidget,
      );
      await page.tapOnSettingPopupMenuItem(0, 1);
      expect(
        find.byWidgetPredicate((widget) => widget is TierListRow && widget.index == 2 && widget.title == row),
        findsOneWidget,
      );
    });

    testWidgets('renames SSS row', (widgetTester) async {
      final page = TierListPage(widgetTester);

      await page.navigate();

      await page.tapClearAllButton();

      const String row = 'SSS';
      const String newName = '$row - Updated';
      expect(
        find.byWidgetPredicate((widget) => widget is TierListRow && widget.index == 0 && widget.title == row),
        findsOneWidget,
      );
      await page.tapOnSettingPopupMenuItem(0, 2);

      await widgetTester.enterText(find.byType(TextField), newName);
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(FilledButton));
      await widgetTester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) => widget is TierListRow && widget.index == 0 && widget.title == newName),
        findsOneWidget,
      );
    });

    testWidgets('deletes SSS row', (widgetTester) async {
      final page = TierListPage(widgetTester);

      await page.navigate();

      await page.tapClearAllButton();

      const String row = 'SSS';
      expect(
        find.byWidgetPredicate((widget) => widget is TierListRow && widget.index == 0 && widget.title == row),
        findsOneWidget,
      );
      await page.tapOnSettingPopupMenuItem(0, 3);
      expect(find.byWidgetPredicate((widget) => widget is TierListRow && widget.index == 0 && widget.title == row), findsNothing);
    });

    testWidgets('changes SSS row color', (widgetTester) async {
      final page = TierListPage(widgetTester);

      await page.navigate();

      await page.tapClearAllButton();

      const String row = 'SSS';
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is TierListRow &&
              widget.index == 0 &&
              widget.title == row &&
              widget.color.toARGB32() == Colors.red.toARGB32(),
        ),
        findsOneWidget,
      );
      await page.tapOnSettingPopupMenuItem(0, 4);

      final Finder colorGridViewFinder = find.byType(GridView);
      final Finder colorsFinder = find.descendant(
        of: colorGridViewFinder,
        matching: find.byWidgetPredicate((widget) => widget is Container && widget.decoration != null),
      );

      await widgetTester.tap(colorsFinder.at(3));
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(FilledButton));
      await widgetTester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is TierListRow &&
              widget.index == 0 &&
              widget.title == row &&
              widget.color.toARGB32() == Colors.red.toARGB32(),
        ),
        findsNothing,
      );
    });
  });
}
