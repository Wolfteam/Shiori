import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/add_edit_item_bottom_sheet.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/ascension_materials_summary.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/item_card.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/material_item.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/session_list_item.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/skill_item.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/shared/bottom_sheets/bottom_sheet_title.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

import '../extensions/widget_tester_extensions.dart';
import '../views/views.dart';

void main() {
  Future<void> navigate(WidgetTester widgetTester) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize(deleteData: true);
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnCalculatorAscMaterialsCard();
  }

  Future<void> createSession(String name, WidgetTester widgetTester) async {
    //Tap on fab button
    await widgetTester.tap(find.byType(FloatingActionButton));
    await widgetTester.pumpAndSettle();

    //Create a new session
    await widgetTester.enterText(find.byType(TextField), name);
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(find.byType(ElevatedButton));
    await widgetTester.pumpAndSettle();
  }

  Future<void> deleteAll(WidgetTester widgetTester) async {
    await widgetTester.tap(find.byIcon(Icons.clear_all));
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(find.byType(ElevatedButton));
    await widgetTester.pumpAndSettle();
  }

  Future<void> addItem(String name, bool isCharacter, WidgetTester widgetTester) async {
    await widgetTester.tap(find.byType(FloatingActionButton));
    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.byIcon(isCharacter ? Icons.people : Shiori.crossed_swords));
    await widgetTester.pumpAndSettle();

    final DetailPage page = DetailPage(widgetTester);
    await page.enterSearchText(name);
    await widgetTester.tap(find.byType(isCharacter ? CharacterCard : WeaponCard));
    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.byType(ElevatedButton));
    await widgetTester.pumpAndSettle();
  }

  group('Calculator ascension materials page', () {
    testWidgets('creates a session and deletes it', (widgetTester) async {
      await navigate(widgetTester);

      await createSession('Will be deleted', widgetTester);

      //Swipe to show the delete button
      await widgetTester.drag(find.byType(SessionListItem), Offset(BasePage.horizontalDragOffset.dx.abs(), 0));
      await widgetTester.pumpAndSettle();

      //Press the delete button
      await widgetTester.tap(find.byIcon(Icons.delete));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byType(ElevatedButton));
      await widgetTester.pumpAndSettle();
      expect(find.byType(SessionListItem), findsNothing);
    });

    testWidgets('creates a session and edits it', (widgetTester) async {
      const String name = 'Will be updated';
      const String newName = 'xxxx';
      await navigate(widgetTester);

      await createSession(name, widgetTester);

      //Swipe to show the edit button
      await widgetTester.drag(find.byType(SessionListItem), BasePage.horizontalDragOffset);
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byIcon(Icons.edit));
      await widgetTester.pumpAndSettle();

      await widgetTester.enterText(find.byType(TextField), newName);
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byType(ElevatedButton));
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(SessionListItem, newName), findsOneWidget);
    });

    testWidgets('creates 2 sessions and deletes them all', (widgetTester) async {
      await navigate(widgetTester);

      await createSession('A', widgetTester);
      await createSession('B', widgetTester);

      await deleteAll(widgetTester);

      expect(find.byType(SessionListItem), findsNothing);
    });

    testWidgets('creates 2 sessions which gets reordered', (widgetTester) async {
      const String sessionA = 'Session A';
      const String sessionB = 'Session B';
      await navigate(widgetTester);

      //Create sessions so that the order is B,A
      await createSession(sessionB, widgetTester);
      await createSession(sessionA, widgetTester);

      //Tap the reorder icon
      await widgetTester.tap(find.byIcon(Icons.unfold_more));
      await widgetTester.pumpAndSettle();

      //Drag A to B position
      await widgetTester.doAppDrag(find.textContaining('#2'), find.textContaining('#1'));

      //Apply changes
      await widgetTester.tap(find.byType(ElevatedButton));
      await widgetTester.pumpAndSettle();

      //Check that the new order is A,B
      final expected = <String>[
        sessionA,
        sessionB,
      ];

      final Finder sessionsFinder = find.byType(SessionListItem);
      for (int i = 0; i < expected.length; i++) {
        final String name = expected[i];
        await widgetTester.longPress(sessionsFinder.at(i));
        await widgetTester.pumpAndSettle();
        expect(find.widgetWithText(TextField, name), findsOneWidget);
        await widgetTester.tap(find.byType(OutlinedButton));
        await widgetTester.pumpAndSettle();
      }
    });

    testWidgets('create session, add a character and a weapon', (widgetTester) async {
      const String sessionName = 'Character&Weapon';
      await navigate(widgetTester);

      await createSession(sessionName, widgetTester);

      await widgetTester.tap(find.text(sessionName));
      await widgetTester.pumpAndSettle();

      await addItem('Nahida', true, widgetTester);
      await addItem('Sacrificial Sword', false, widgetTester);

      expect(find.byType(ItemCard), findsNWidgets(2));
      expect(find.byType(AscensionMaterialsSummaryWidget), findsAtLeastNWidgets(1));
    });

    testWidgets('create session, add a character, a weapon and clear items', (widgetTester) async {
      const String sessionName = 'Clear items';
      await navigate(widgetTester);

      await createSession(sessionName, widgetTester);

      await widgetTester.tap(find.text(sessionName));
      await widgetTester.pumpAndSettle();

      await addItem('Nahida', true, widgetTester);
      await addItem('Sacrificial Sword', false, widgetTester);

      await deleteAll(widgetTester);

      expect(find.byType(ItemCard), findsNothing);
      expect(find.byType(AscensionMaterialsSummaryWidget), findsNothing);
    });

    testWidgets('create session, add 2 items and reorder them', (widgetTester) async {
      const String sessionName = 'Reorder items';
      const String charNameA = 'Keqing';
      const String charNameB = 'Nahida';
      await navigate(widgetTester);

      await createSession(sessionName, widgetTester);

      await widgetTester.tap(find.text(sessionName));
      await widgetTester.pumpAndSettle();

      //Create items
      await addItem(charNameA, true, widgetTester);
      await addItem(charNameB, true, widgetTester);

      //Tap the reorder icon
      await widgetTester.tap(find.byIcon(Icons.unfold_more));
      await widgetTester.pumpAndSettle();

      //Drag Nahida to Keqing's position
      await widgetTester.doAppDrag(find.textContaining('#2'), find.textContaining('#1'));

      //Apply changes
      await widgetTester.tap(find.byType(ElevatedButton));
      await widgetTester.pumpAndSettle();

      expect(find.widgetWithText(ItemDescriptionDetail, 'Summary'), findsOneWidget);

      //Check that the new order is Nahida,Keqing
      final expected = <String>[
        charNameB,
        charNameA,
      ];

      final Finder itemsFinder = find.byType(ItemCard);
      for (int i = 0; i < expected.length; i++) {
        final String name = expected[i];
        await widgetTester.tap(itemsFinder.at(i));
        await widgetTester.pumpAndSettle();
        expect(find.descendant(of: find.byType(BottomSheetTitle), matching: find.textContaining(name)), findsOneWidget);
        await widgetTester.tap(find.byType(ElevatedButton));
        await widgetTester.pumpAndSettle();
      }
    });

    testWidgets('create session, add 2 items and mark them as inactive them', (widgetTester) async {
      const String sessionName = 'Mark items as inactive';
      const String charNameA = 'Keqing';
      const String charNameB = 'Nahida';
      await navigate(widgetTester);

      await createSession(sessionName, widgetTester);

      await widgetTester.tap(find.text(sessionName));
      await widgetTester.pumpAndSettle();

      await addItem(charNameA, true, widgetTester);
      await addItem(charNameB, true, widgetTester);

      final expected = <String>[
        charNameA,
        charNameB,
      ];

      final Finder itemsFinder = find.byType(ItemCard);
      for (int i = 0; i < expected.length; i++) {
        final String name = expected[i];
        await widgetTester.tap(itemsFinder.at(i));
        await widgetTester.pumpAndSettle();
        expect(find.descendant(of: find.byType(BottomSheetTitle), matching: find.textContaining(name)), findsOneWidget);
        await widgetTester.tap(find.widgetWithText(OutlinedButton, 'Inactive'));
        await widgetTester.pumpAndSettle();
      }

      expect(find.byType(AscensionMaterialsSummaryWidget), findsNothing);
    });

    testWidgets('create session, add 2 items and delete them one by one', (widgetTester) async {
      const String sessionName = 'Delete items one by one';
      const String charNameA = 'Keqing';
      const String charNameB = 'Nahida';
      await navigate(widgetTester);

      await createSession(sessionName, widgetTester);

      await widgetTester.tap(find.text(sessionName));
      await widgetTester.pumpAndSettle();

      await addItem(charNameA, true, widgetTester);
      await addItem(charNameB, true, widgetTester);

      final expected = <String>[
        charNameA,
        charNameB,
      ];

      for (int i = 0; i < expected.length; i++) {
        final String name = expected[i];
        await widgetTester.tap(find.widgetWithText(ItemCard, name).first);
        await widgetTester.pumpAndSettle();
        expect(find.descendant(of: find.byType(BottomSheetTitle), matching: find.textContaining(name)), findsOneWidget);
        await widgetTester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
        await widgetTester.pumpAndSettle();
      }

      expect(find.byType(ItemCard), findsNothing);
      expect(find.byType(AscensionMaterialsSummaryWidget), findsNothing);
    });

    testWidgets('create session, add 2 items, mark one as inactive thus only materials from the first one should be shown', (widgetTester) async {
      const String sessionName = 'Updates 1 item';
      const String charNameA = 'Keqing';
      const String charNameB = 'Nahida';
      await navigate(widgetTester);

      await createSession(sessionName, widgetTester);

      await widgetTester.tap(find.text(sessionName));
      await widgetTester.pumpAndSettle();

      await addItem(charNameA, true, widgetTester);
      await addItem(charNameB, true, widgetTester);

      //Mark the last one as inactive
      await widgetTester.tap(find.widgetWithText(ItemCard, charNameB));
      await widgetTester.pumpAndSettle();
      expect(find.descendant(of: find.byType(BottomSheetTitle), matching: find.textContaining(charNameB)), findsOneWidget);
      await widgetTester.tap(find.widgetWithText(OutlinedButton, 'Inactive'));
      await widgetTester.pumpAndSettle();

      //Update the first one with expected values
      await widgetTester.tap(find.widgetWithText(ItemCard, charNameA));
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.text('Current: 20'));
      await widgetTester.pumpAndSettle();

      final DetailPage page = DetailPage(widgetTester);
      await page.selectValueInNumberPickerDialog(80);

      final Finder skillsFinder = find.byType(SkillItem);
      expect(skillsFinder, findsNWidgets(3));

      for (int i = 0; i < 3; i++) {
        final Finder skillItemFinder = skillsFinder.at(i);
        for (int j = 0; j < 8; j++) {
          await widgetTester.tap(find.descendant(of: skillItemFinder, matching: find.byIcon(Icons.add)).first);
          await widgetTester.pumpAndSettle();
        }
      }

      await widgetTester.tap(find.descendant(of: find.byType(AddEditItemBottomSheet), matching: find.byType(ElevatedButton)));
      await widgetTester.pumpAndSettle();

      //Check the obtained materials
      final Finder summaryDescriptionFinder = find.widgetWithText(ItemDescriptionDetail, 'Summary');
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
  });
}
