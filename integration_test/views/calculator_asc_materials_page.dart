import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/add_edit_item_bottom_sheet.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/item_card.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/session_list_item.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/skill_item.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/shared/bottom_sheets/bottom_sheet_title.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

import 'views.dart';

class CalculatorAscMaterialsPage extends BasePage {
  const CalculatorAscMaterialsPage(super.tester);

  Future<void> navigate() async {
    final splashPage = SplashPage(tester);
    await splashPage.initialize(deleteData: true);
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(tester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnCalculatorAscMaterialsCard();
  }

  Future<void> createSession(String name) async {
    //Tap on fab button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    //Create a new session
    await tester.enterText(find.byType(TextField), name);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  Future<void> tapOnSession(String name) async {
    await tester.tap(find.widgetWithText(SessionListItem, name));
    await tester.pumpAndSettle();
  }

  Future<void> deleteAll() async {
    await tester.tap(find.byIcon(Icons.clear_all));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  Future<void> addItem(
    String name,
    bool isCharacter, {
    bool usesMaterialFromInventory = false,
  }) async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(isCharacter ? Icons.people : Shiori.crossed_swords));
    await tester.pumpAndSettle();

    await enterSearchText(name);
    await tester.tap(find.byType(isCharacter ? CharacterCard : WeaponCard));
    await tester.pumpAndSettle();

    if (usesMaterialFromInventory) {
      await tester.dragUntilVisible(
        find.widgetWithIcon(SegmentedButton<bool>, Icons.check),
        find.byType(CustomScrollView).first,
        BasePage.verticalDragOffset,
      );
      await tester.pumpAndSettle();

      final Finder iconFinder = find.descendant(of: find.byType(SegmentedButton<bool>), matching: find.byIcon(Icons.check));
      await tester.tap(iconFinder);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  Future<CalculatorAscMaterialsItemBottomSheet> tapOnItem(String itemName) async {
    await tester.tap(find.widgetWithText(ItemCard, itemName));
    await tester.pumpAndSettle();
    return CalculatorAscMaterialsItemBottomSheet(tester);
  }
}

class CalculatorAscMaterialsItemBottomSheet extends CommonBottomSheet {
  const CalculatorAscMaterialsItemBottomSheet(super.tester);

  Future<void> setItemLevel(int value, {bool updateCurrent = true}) async {
    await tester.tap(find.textContaining(updateCurrent ? 'Current:' : 'Desired:'));
    await tester.pumpAndSettle();
    await selectValueInNumberPickerDialog(value);
  }

  Future<void> setSkillLevel(
    int index,
    int newValue, {
    bool updateCurrent = true,
    bool increase = true,
    int skillCount = 3,
  }) async {
    final Finder skillsFinder = find.byType(SkillItem);
    expect(skillsFinder, findsNWidgets(skillCount));

    final Finder skillItemFinder = skillsFinder.at(index);
    final IconData icon = increase ? Icons.add : Icons.remove;
    final SkillItem skillItem = tester.widget<SkillItem>(skillItemFinder);

    final int currentValue = updateCurrent ? skillItem.currentLevel : skillItem.desiredLevel;

    if (currentValue == newValue) {
      return;
    }

    final int steps = (newValue - currentValue).abs();
    for (int i = 0; i <= steps; i++) {
      final Finder iconFinder = find.descendant(of: skillItemFinder, matching: find.byIcon(icon));
      await tester.tap(updateCurrent ? iconFinder.first : iconFinder.last);
      await tester.pumpAndSettle();
    }
  }

  Future<void> deleteItem(String itemName) async {
    expect(find.descendant(of: find.byType(BottomSheetTitle), matching: find.textContaining(itemName)), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
  }

  Future<void> markItemAsInactive(String itemName) async {
    expect(find.descendant(of: find.byType(BottomSheetTitle), matching: find.textContaining(itemName)), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Inactive'));
    await tester.pumpAndSettle();
  }

  Future<void> closeAddEditItemBottomSheet() async {
    await tester.tap(find.descendant(of: find.byType(AddEditItemBottomSheet), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
  }
}
