import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/materials/widgets/material_card.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

import '../game_data.dart';
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
    expect(tabFinder, findsOneWidget, reason: 'The ${tabType.name} inventory tab must be present to switch to it');
    await widgetTester.tap(tabFinder);
    await widgetTester.pumpAndSettle();

    //Clean all existing items
    for (int i = 0; i < _TabType.values.length; i++) {
      await widgetTester.tap(find.byIcon(Icons.clear_all));
      await widgetTester.pumpAndSettle();

      final Finder items = find.byType(ListTile);
      await widgetTester.tap(items.at(i));
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(FilledButton));
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

    expect(
      find.widgetWithText(expectedType, name),
      findsOneWidget,
      reason: 'Adding $name from the picker should place its card in the inventory',
    );
  }

  group('Inventory', () {
    testWidgets('add character to inventory', (widgetTester) async {
      await navigate(widgetTester, _TabType.characters);
      await addCharacterOrWeapon(GameData.keqing.name, true, widgetTester);

      final Finder cardFinder = find.widgetWithText(CharacterCard, GameData.keqing.name);
      expect(
        cardFinder,
        findsOneWidget,
        reason: '${GameData.keqing.name} should appear once in the character inventory after being added',
      );
      final CharacterCard card = widgetTester.widget<CharacterCard>(cardFinder);
      expect(
        card.keyName,
        GameData.keqing.key,
        reason: 'The inventory card must be ${GameData.keqing.name} (key ${GameData.keqing.key})',
      );
      expect(
        card.rarity,
        GameData.keqing.rarity,
        reason: '${GameData.keqing.name} must render as a ${GameData.keqing.rarity}★ card in the inventory',
      );
      expect(
        card.elementType,
        GameData.keqing.element,
        reason: '${GameData.keqing.name} inventory card must show element ${GameData.keqing.element.name}',
      );
    });

    testWidgets('add weapon to inventory', (widgetTester) async {
      await navigate(widgetTester, _TabType.weapons);
      await addCharacterOrWeapon(GameData.messenger.name, false, widgetTester);

      final Finder cardFinder = find.widgetWithText(WeaponCard, GameData.messenger.name);
      expect(
        cardFinder,
        findsOneWidget,
        reason: '${GameData.messenger.name} should appear once in the weapon inventory after being added',
      );
      final WeaponCard card = widgetTester.widget<WeaponCard>(cardFinder);
      expect(
        card.keyName,
        GameData.messenger.key,
        reason: 'The inventory card must be ${GameData.messenger.name} (key ${GameData.messenger.key})',
      );
      expect(
        card.rarity,
        GameData.messenger.rarity,
        reason: '${GameData.messenger.name} must render as a ${GameData.messenger.rarity}★ weapon in the inventory',
      );
      expect(
        card.type,
        GameData.messenger.type,
        reason: '${GameData.messenger.name} inventory card must be a ${GameData.messenger.type.name} weapon',
      );
    });

    testWidgets('add material to inventory', (widgetTester) async {
      await navigate(widgetTester, _TabType.materials);

      const String quantity = '666';
      final Finder materialCardFinder = find.byType(MaterialCard).at(2);
      await widgetTester.tap(materialCardFinder);
      await widgetTester.pumpAndSettle();

      await widgetTester.sendKeyDownEvent(LogicalKeyboardKey.delete);
      await widgetTester.enterText(find.byType(TextField), quantity);
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(FilledButton));
      await widgetTester.pumpAndSettle();

      expect(
        find.descendant(of: materialCardFinder, matching: find.text(quantity)),
        findsOneWidget,
        reason: 'The saved quantity ($quantity) should be shown on the material card',
      );
    });
  });
}
