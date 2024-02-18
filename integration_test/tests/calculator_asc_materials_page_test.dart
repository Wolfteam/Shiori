import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/ascension_materials_summary.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/item_card.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/material_item.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/session_list_item.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';

import '../extensions/widget_tester_extensions.dart';
import '../views/views.dart';

void main() {
  group('Calculator ascension materials page', () {
    testWidgets('creates a session and deletes it', (widgetTester) async {
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      await page.createSession('Will be deleted');

      //Swipe to show the delete button
      await widgetTester.drag(find.byType(SessionListItem), Offset(BasePage.horizontalDragOffset.dx.abs(), 0));
      await widgetTester.pumpAndSettle();

      //Press the delete button
      await widgetTester.tap(find.byIcon(Icons.delete));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byType(FilledButton));
      await widgetTester.pumpAndSettle();
      expect(find.byType(SessionListItem), findsNothing);
    });

    testWidgets('creates a session and edits it', (widgetTester) async {
      const String name = 'Will be updated';
      const String newName = 'xxxx';
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      await page.createSession(name);

      //Swipe to show the edit button
      await widgetTester.drag(find.byType(SessionListItem), BasePage.horizontalDragOffset);
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byIcon(Icons.edit));
      await widgetTester.pumpAndSettle();

      //Change the session's name
      await widgetTester.enterText(find.byType(TextField), newName);
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byType(FilledButton));
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(SessionListItem, newName), findsOneWidget);
    });

    testWidgets('creates 2 sessions and deletes them all', (widgetTester) async {
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      await page.createSession('A');
      await page.createSession('B');

      await page.deleteAll();

      expect(find.byType(SessionListItem), findsNothing);
    });

    testWidgets('creates 2 sessions which gets reordered', (widgetTester) async {
      const String sessionA = 'Session A';
      const String sessionB = 'Session B';
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      //Create sessions so that the order is B,A
      await page.createSession(sessionB);
      await page.createSession(sessionA);

      //Tap the reorder icon
      await widgetTester.tap(find.byIcon(Icons.unfold_more));
      await widgetTester.pumpAndSettle();

      //Drag A to B position
      await widgetTester.doAppDragFromBottomRight(find.textContaining('#2'), find.textContaining('#1'));

      //Apply changes
      await widgetTester.tap(find.byType(FilledButton));
      await widgetTester.pumpAndSettle();

      //Check that the new order is A,B
      final expected = <String>[
        sessionA,
        sessionB,
      ];

      final Finder sessionsFinder = find.byType(SessionListItem);
      for (int i = 0; i < expected.length; i++) {
        final String name = expected[i];
        expect(find.descendant(of: sessionsFinder.at(i), matching: find.text(name)), findsOneWidget);
      }
    });

    testWidgets('create session, add a character and a weapon', (widgetTester) async {
      const String sessionName = 'Character&Weapon';
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      await page.createSession(sessionName);
      await page.tapOnSession(sessionName);

      await page.addItem('Nahida', true);
      await page.addItem('Sacrificial Sword', false);

      expect(find.byType(ItemCard), findsNWidgets(2));
      expect(find.byType(AscensionMaterialsSummaryWidget), findsAtLeastNWidgets(1));
    });

    testWidgets('create session, add a character, a weapon and clear items', (widgetTester) async {
      const String sessionName = 'Clear items';
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      await page.createSession(sessionName);
      await page.tapOnSession(sessionName);

      await page.addItem('Nahida', true);
      await page.addItem('Sacrificial Sword', false);

      await page.deleteAll();

      expect(find.byType(ItemCard), findsNothing);
      expect(find.byType(AscensionMaterialsSummaryWidget), findsNothing);
    });

    testWidgets('create session, add 2 items and reorder them', (widgetTester) async {
      const String sessionName = 'Reorder items';
      const String charNameA = 'Keqing';
      const String charNameB = 'Nahida';
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      await page.createSession(sessionName);
      await page.tapOnSession(sessionName);

      //Create items
      await page.addItem(charNameA, true);
      await page.addItem(charNameB, true);

      //Tap the reorder icon
      await widgetTester.tap(find.byIcon(Icons.unfold_more));
      await widgetTester.pumpAndSettle();

      //Drag Nahida to Keqing's position
      await widgetTester.doAppDragFromBottomRight(find.textContaining('#2'), find.textContaining('#1'));

      //Apply changes
      await widgetTester.tap(find.byType(FilledButton));
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(DetailSection, 'Summary'), findsOneWidget);

      //Check that the new order is Nahida,Keqing
      final expected = <String>[
        charNameB,
        charNameA,
      ];

      final Finder itemsFinder = find.byType(ItemCard);
      for (int i = 0; i < expected.length; i++) {
        final String name = expected[i];
        expect(find.descendant(of: itemsFinder.at(i), matching: find.text(name)), findsOneWidget);
        // await widgetTester.tap(itemsFinder.at(i));
        // await widgetTester.pumpAndSettle();
        // expect(find.descendant(of: find.byType(BottomSheetTitle), matching: find.textContaining(name)), findsOneWidget);
        // await widgetTester.tap(find.byType(FilledButton));
        // await widgetTester.pumpAndSettle();
      }
    });

    testWidgets('create session, add 2 items and mark them as inactive them', (widgetTester) async {
      const String sessionName = 'Mark items as inactive';
      const String charNameA = 'Keqing';
      const String charNameB = 'Nahida';
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      await page.createSession(sessionName);
      await page.tapOnSession(sessionName);

      await page.addItem(charNameA, true);
      await page.addItem(charNameB, true);

      final expected = <String>[
        charNameA,
        charNameB,
      ];

      for (int i = 0; i < expected.length; i++) {
        final String name = expected[i];
        final CalculatorAscMaterialsItemBottomSheet sheet = await page.tapOnItem(name);
        await sheet.markItemAsInactive(name);
      }

      expect(find.byType(AscensionMaterialsSummaryWidget), findsNothing);
    });

    testWidgets('create session, add 2 items and delete them one by one', (widgetTester) async {
      const String sessionName = 'Delete items one by one';
      const String charNameA = 'Keqing';
      const String charNameB = 'Nahida';
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      await page.createSession(sessionName);
      await page.tapOnSession(sessionName);

      await page.addItem(charNameA, true);
      await page.addItem(charNameB, true);

      final expected = <String>[
        charNameA,
        charNameB,
      ];

      for (int i = 0; i < expected.length; i++) {
        final String name = expected[i];
        final CalculatorAscMaterialsItemBottomSheet sheet = await page.tapOnItem(name);
        await sheet.deleteItem(name);
      }

      expect(find.byType(ItemCard), findsNothing);
      expect(find.byType(AscensionMaterialsSummaryWidget), findsNothing);
    });

    testWidgets('create session, add 2 items, mark one as inactive thus only materials from the first one should be shown', (widgetTester) async {
      const String sessionName = 'Updates 1 item';
      const String charNameA = 'Keqing';
      const String charNameB = 'Nahida';
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      await page.createSession(sessionName);
      await page.tapOnSession(sessionName);

      await page.addItem(charNameA, true);
      await page.addItem(charNameB, true);

      //Mark the last one as inactive
      final CalculatorAscMaterialsItemBottomSheet sheetB = await page.tapOnItem(charNameB);
      await sheetB.markItemAsInactive(charNameB);

      //Update the first one with expected values
      final CalculatorAscMaterialsItemBottomSheet sheetA = await page.tapOnItem(charNameA);
      await sheetA.setItemLevel(80);
      await sheetA.setSkillLevel(0, 8);
      await sheetA.setSkillLevel(1, 8);
      await sheetA.setSkillLevel(2, 8);
      await sheetA.closeAddEditItemBottomSheet();

      //Check the obtained materials
      final Finder summaryDescriptionFinder = find.widgetWithText(DetailSection, 'Summary');
      expect(summaryDescriptionFinder, findsOneWidget);

      final expected = [
        AscensionMaterialSummaryType.worldBoss,
        AscensionMaterialSummaryType.common,
        AscensionMaterialSummaryType.currency,
        AscensionMaterialSummaryType.day,
        AscensionMaterialSummaryType.exp,
        AscensionMaterialSummaryType.local,
        AscensionMaterialSummaryType.others,
      ];

      int count = 0;
      for (final AscensionMaterialSummaryType type in expected) {
        await widgetTester.dragUntilVisible(
          find.byWidgetPredicate((widget) => widget is AscensionMaterialsSummaryWidget && widget.summary.type == type),
          summaryDescriptionFinder,
          BasePage.verticalDragOffset,
        );

        final expectedMaterialCount = switch (type) {
          AscensionMaterialSummaryType.worldBoss => 3,
          AscensionMaterialSummaryType.exp => 2,
          _ => 1,
        };

        final Finder materialsFinder = find.descendant(
          of: find.byWidgetPredicate((widget) => widget is AscensionMaterialsSummaryWidget && widget.summary.type == type),
          matching: find.byType(MaterialItem),
        );

        expect(materialsFinder, findsNWidgets(expectedMaterialCount));
        count++;
      }

      expect(count, equals(expected.length));
    });

    testWidgets('create session, add item using materials from inventory and update inventory quantity', (widgetTester) async {
      const String sessionName = 'Uses mat. from inv.';
      const String charNameA = 'Keqing';
      const String requiredQuantity = '7.005.900';
      const String newInventoryQuantity = '1.000.000';
      final page = CalculatorAscMaterialsPage(widgetTester);
      await page.navigate();

      await page.createSession(sessionName);
      await page.tapOnSession(sessionName);

      await page.addItem(charNameA, true, usesMaterialFromInventory: true);

      final Finder summaryDescriptionFinder = find.widgetWithText(DetailSection, 'Summary');
      expect(summaryDescriptionFinder, findsOneWidget);
      await widgetTester.dragUntilVisible(
        find.byWidgetPredicate((widget) => widget is AscensionMaterialsSummaryWidget && widget.summary.type == AscensionMaterialSummaryType.currency),
        summaryDescriptionFinder,
        BasePage.verticalDragOffset,
      );

      //Tap on the Mora item
      expect(find.widgetWithText(MaterialItem, '0 / $requiredQuantity'), findsOneWidget);
      final Finder moraFinder = find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is AscensionMaterialsSummaryWidget && widget.summary.type == AscensionMaterialSummaryType.currency,
        ),
        matching: find.byType(MaterialItem),
      );
      await widgetTester.tap(moraFinder);
      await widgetTester.pumpAndSettle();

      //Tap on the Update button
      await widgetTester.tap(find.byType(ListTile).last);
      await widgetTester.pumpAndSettle();

      //Enter the new quantity
      await widgetTester.enterText(find.byType(TextField), newInventoryQuantity.replaceAll('.', ''));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byType(FilledButton));
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(MaterialItem, '$newInventoryQuantity / $requiredQuantity'), findsOneWidget);
    });
  });
}
