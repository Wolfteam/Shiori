import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/shared/gradient_card.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

import '../views/views.dart';

enum _TabType {
  characters,
  weapons,
  materials,
}

void main() {
  Future<void> navigate(WidgetTester widgetTester, _TabType tabType) async {
    final splashPage = SplashPage(widgetTester);
    await splashPage.initialize(deleteData: true);
    await splashPage.applyResourceUpdates();

    final mainPage = MainTabPage(widgetTester);
    await mainPage.closeChangelogDialog();
    await mainPage.tapOnMyInventoryCard();

    final icon = switch (tabType) {
      _TabType.characters => Icons.people,
      _TabType.weapons => Shiori.crossed_swords,
      _TabType.materials => Shiori.cubes,
    };

    final Finder tabFinder = find.widgetWithIcon(Tab, icon);
    expect(tabFinder, findsOneWidget);
    await widgetTester.tap(tabFinder);
    await widgetTester.pumpAndSettle();

    //Clean all existing items
    for (int i = 0; i < _TabType.values.length; i++) {
      await widgetTester.tap(find.byIcon(Icons.clear_all));
      await widgetTester.pumpAndSettle();

      final Finder items = find.byType(ListTile);
      await widgetTester.tap(items.at(i));
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(ElevatedButton));
      await widgetTester.pumpAndSettle();
    }
  }

  Future<void> addCharacterOrWeapon(String name, bool isCharacter, WidgetTester widgetTester) async {
    final Finder fabFinder = find.byType(FloatingActionButton);
    await widgetTester.tap(fabFinder);
    await widgetTester.pumpAndSettle();

    final DetailPage page = DetailPage(widgetTester);
    await page.enterSearchText(name);
    await widgetTester.pumpAndSettle();

    final expectedType = isCharacter ? CharacterCard : WeaponCard;
    await widgetTester.tap(find.widgetWithText(expectedType, name));
    await widgetTester.pumpAndSettle();

    expect(find.widgetWithText(expectedType, name), findsOneWidget);
  }

  group('Inventory', () {
    testWidgets('add character to inventory', (widgetTester) async {
      await navigate(widgetTester, _TabType.characters);
      await addCharacterOrWeapon('Keqing', true, widgetTester);
    });

    testWidgets('add weapon to inventory', (widgetTester) async {
      await navigate(widgetTester, _TabType.weapons);
      await addCharacterOrWeapon('Messenger', false, widgetTester);
    });

    testWidgets('add material to inventory', (widgetTester) async {
      await navigate(widgetTester, _TabType.materials);

      const String quantity = '666';
      final Finder materialCardFinder = find.byType(GradientCard).last;
      await widgetTester.tap(materialCardFinder);
      await widgetTester.pumpAndSettle();

      await widgetTester.sendKeyDownEvent(LogicalKeyboardKey.delete);
      await widgetTester.enterText(find.byType(TextField), quantity);
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(ElevatedButton));
      await widgetTester.pumpAndSettle();

      expect(find.descendant(of: materialCardFinder, matching: find.text(quantity)), findsOneWidget);
    });
  });
}
