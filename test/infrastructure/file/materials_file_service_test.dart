import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  group('Get materials for card', () {
    for (final lang in AppLanguageType.values) {
      test('language = ${lang.name}', () async {
        final service = await getMaterialFileService(lang);
        final materials = service.getAllMaterialsForCard();
        checkKeys(materials.map((e) => e.key).toList());
        for (final material in materials) {
          checkKey(material.key);
          checkAsset(material.image);
          expect(material.name, allOf([isNotEmpty, isNotNull]), reason: 'Should not be empty (property=name, key=${material.key})');
          expect(material.rarity, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(5)]), reason: 'Should be greater than expected (property=rarity, key=${material.key})');
          expect(material.level, greaterThanOrEqualTo(0), reason: 'Should be greater than expected (property=level, key=${material.key})');
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getMaterialFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final materials = service.getAllMaterialsForCard();
      expect(materials.isEmpty, isTrue, reason: 'Should be true');
    });
  });

  test('Get material', () async {
    final service = await getMaterialFileService(AppLanguageType.english);
    final characterFileService = await getCharacterFileService(AppLanguageType.english);
    final weaponFileService = await getWeaponFileService(AppLanguageType.english);
    final monsterFileService = await getMonsterFileService(AppLanguageType.english);
    final materials = service.getAllMaterialsForCard();

    final checkedPartOfRecipesKeys = <String>[];
    final checkedNeedsKeys = <String>[];
    for (final material in materials) {
      final detail = service.getMaterial(material.key);
      checkKey(detail.key);
      checkAsset(service.resources.getMaterialImagePath(detail.image, detail.type));
      expect(detail.rarity, equals(material.rarity), reason: 'Should equal expected value (property=rarity, key=${material.key})');
      expect(detail.type, equals(material.type), reason: 'Should equal expected value (property=type, key=${material.key})');

      switch (detail.type) {
        case MaterialType.common:
          expect(detail.hasSiblings, isTrue, reason: 'Should be true (property=hasSiblings, key=${material.key})');
          expect(detail.rarity, inInclusiveRange(1, 4), reason: 'Should be within expected range (property=rarity, key=${material.key})');
          expect(detail.level, inInclusiveRange(0, 3), reason: 'Should be within expected range (property=level, key=${material.key})');
        case MaterialType.elementalStone:
          expect(detail.rarity, equals(4), reason: 'Should equal expected value (property=rarity, key=${material.key})');
          expect(detail.level, equals(0), reason: 'Should equal expected value (property=level, key=${material.key})');
        case MaterialType.jewels:
          expect(detail.hasSiblings, isTrue, reason: 'Should be true (property=hasSiblings, key=${material.key})');
          expect(detail.rarity, inInclusiveRange(2, 5), reason: 'Should be within expected range (property=rarity, key=${material.key})');
          expect(detail.level, inInclusiveRange(0, 3), reason: 'Should be within expected range (property=level, key=${material.key})');
        case MaterialType.local:
          expect(detail.attributes, allOf([isNotNull, isNotEmpty]), reason: 'Should not be empty (property=attributes, key=${material.key})');
        case MaterialType.talents:
          if (detail.rarity >= 5) {
            continue;
          }

          expect(detail.days, isNotEmpty, reason: 'Should not be empty (property=days, key=${material.key})');
          for (final day in detail.days) {
            expect(day, isIn([1, 2, 3, 4, 5, 6, 7]), reason: 'Should match expected value (key=${material.key})');
          }

          expect(detail.hasSiblings, isTrue, reason: 'Should be true (property=hasSiblings, key=${material.key})');
          expect(detail.rarity, inInclusiveRange(2, 4), reason: 'Should be within expected range (property=rarity, key=${material.key})');
          expect(detail.level, inInclusiveRange(0, 2), reason: 'Should be within expected range (property=level, key=${material.key})');
        case MaterialType.weapon:
          expect(detail.hasSiblings, isTrue, reason: 'Should be true (property=hasSiblings, key=${material.key})');
          expect(detail.rarity, inInclusiveRange(1, 4), reason: 'Should be within expected range (property=rarity, key=${material.key})');
          expect(detail.level, inInclusiveRange(0, 3), reason: 'Should be within expected range (property=level, key=${material.key})');
        case MaterialType.weaponPrimary:
          expect(detail.days, isNotEmpty, reason: 'Should not be empty (property=days, key=${material.key})');
          for (final day in detail.days) {
            expect(day, isIn([1, 2, 3, 4, 5, 6, 7]), reason: 'Should match expected value (key=${material.key})');
          }
          expect(detail.hasSiblings, isTrue, reason: 'Should be true (property=hasSiblings, key=${material.key})');
          expect(detail.rarity, inInclusiveRange(2, 5), reason: 'Should be within expected range (property=rarity, key=${material.key})');
          expect(detail.level, inInclusiveRange(0, 3), reason: 'Should be within expected range (property=level, key=${material.key})');
        case MaterialType.currency:
          break;
        case MaterialType.others:
          break;
        case MaterialType.ingredient:
          break;
        case MaterialType.expWeapon:
        case MaterialType.expCharacter:
          expect(detail.attributes, allOf([isNotNull, isNotEmpty]), reason: 'Should not be empty (property=attributes, key=${material.key})');
          expect(detail.experienceAttributes, isNotNull, reason: 'Should not be null (property=experienceAttributes, key=${material.key})');
          expect(detail.isAnExperienceMaterial, isTrue, reason: 'Should be true (property=isAnExperienceMaterial, key=${material.key})');
      }

      final partOfRecipes = detail.recipes + detail.obtainedFrom;

      for (final part in partOfRecipes) {
        checkKey(part.createsMaterialKey);
        if (!checkedPartOfRecipesKeys.contains(part.createsMaterialKey)) {
          expect(() => service.getMaterial(part.createsMaterialKey), returnsNormally, reason: 'Should execute without throwing');
          checkedPartOfRecipesKeys.add(part.createsMaterialKey);
        }

        for (final needs in part.needs) {
          expect(needs.quantity, greaterThanOrEqualTo(1), reason: 'Should be greater than expected (property=quantity, key=${material.key})');
          if (!checkedNeedsKeys.contains(needs.key)) {
            expect(() => service.getMaterial(needs.key), returnsNormally, reason: 'Should execute without throwing (key=${needs.key})');
            checkedNeedsKeys.add(needs.key);
          }
        }
      }

      final characters = characterFileService.getCharacterForItemsUsingMaterial(material.key);
      expect(characters.map((e) => e.key).toSet().length == characters.length, isTrue, reason: 'Should be true (property=length, isTrue, key=${material.key})');

      final weapons = weaponFileService.getWeaponForItemsUsingMaterial(material.key);
      expect(weapons.map((e) => e.key).toSet().length == weapons.length, isTrue, reason: 'Should be true (property=length, isTrue, key=${material.key})');

      final droppedBy = monsterFileService.getRelatedMonsterToMaterialForItems(detail.key);
      expect(droppedBy.map((e) => e.key).toSet().length == droppedBy.length, isTrue, reason: 'Should be true (property=length, isTrue, key=${material.key})');
    }
  });
}
