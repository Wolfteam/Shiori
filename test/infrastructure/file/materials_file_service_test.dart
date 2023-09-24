import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  test('Get materials for card', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getMaterialFileService(lang);
      final materials = service.getAllMaterialsForCard();
      checkKeys(materials.map((e) => e.key).toList());
      for (final material in materials) {
        checkKey(material.key);
        checkAsset(material.image);
        expect(material.name, allOf([isNotEmpty, isNotNull]));
        expect(material.rarity, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(5)]));
        expect(material.level, greaterThanOrEqualTo(0));
      }
    }
  });

  test('Get material', () async {
    final service = await getMaterialFileService(AppLanguageType.english);
    final characterFileService = await getCharacterFileService(AppLanguageType.english);
    final weaponFileService = await getWeaponFileService(AppLanguageType.english);
    final monsterFileService = await getMonsterFileService(AppLanguageType.english);

    final materials = service.getAllMaterialsForCard();
    for (final material in materials) {
      final detail = service.getMaterial(material.key);
      checkKey(detail.key);
      checkAsset(service.resources.getMaterialImagePath(detail.image, detail.type));
      expect(detail.rarity, equals(material.rarity));
      expect(detail.type, equals(material.type));

      switch (detail.type) {
        case MaterialType.common:
          expect(detail.hasSiblings, isTrue);
          expect(detail.rarity, inInclusiveRange(1, 4));
          expect(detail.level, inInclusiveRange(0, 3));
        case MaterialType.elementalStone:
          expect(detail.rarity, equals(4));
          expect(detail.level, equals(0));
        case MaterialType.jewels:
          expect(detail.hasSiblings, isTrue);
          expect(detail.rarity, inInclusiveRange(2, 5));
          expect(detail.level, inInclusiveRange(0, 3));
        case MaterialType.local:
          expect(detail.attributes, allOf([isNotNull, isNotEmpty]));
        case MaterialType.talents:
          if (detail.rarity >= 5) {
            continue;
          }

          expect(detail.days, isNotEmpty);
          for (final day in detail.days) {
            expect(day, isIn([1, 2, 3, 4, 5, 6, 7]));
          }

          expect(detail.hasSiblings, isTrue);
          expect(detail.rarity, inInclusiveRange(2, 4));
          expect(detail.level, inInclusiveRange(0, 2));
        case MaterialType.weapon:
          expect(detail.hasSiblings, isTrue);
          expect(detail.rarity, inInclusiveRange(1, 4));
          expect(detail.level, inInclusiveRange(0, 3));
        case MaterialType.weaponPrimary:
          expect(detail.days, isNotEmpty);
          for (final day in detail.days) {
            expect(day, isIn([1, 2, 3, 4, 5, 6, 7]));
          }
          expect(detail.hasSiblings, isTrue);
          expect(detail.rarity, inInclusiveRange(2, 5));
          expect(detail.level, inInclusiveRange(0, 3));
        case MaterialType.currency:
          break;
        case MaterialType.others:
          break;
        case MaterialType.ingredient:
          break;
        case MaterialType.expWeapon:
        case MaterialType.expCharacter:
          expect(detail.attributes, allOf([isNotNull, isNotEmpty]));
          expect(detail.experienceAttributes, isNotNull);
          expect(detail.isAnExperienceMaterial, isTrue);
      }

      final partOfRecipes = detail.recipes + detail.obtainedFrom;

      for (final part in partOfRecipes) {
        checkKey(part.createsMaterialKey);
        expect(() => service.getMaterial(part.createsMaterialKey), returnsNormally);
        for (final needs in part.needs) {
          expect(needs.quantity, greaterThanOrEqualTo(1));
          expect(() => service.getMaterial(needs.key), returnsNormally);
        }
      }

      final characters = characterFileService.getCharacterForItemsUsingMaterial(material.key);
      expect(characters.map((e) => e.key).toSet().length == characters.length, isTrue);

      final weapons = weaponFileService.getWeaponForItemsUsingMaterial(material.key);
      expect(weapons.map((e) => e.key).toSet().length == weapons.length, isTrue);

      final droppedBy = monsterFileService.getRelatedMonsterToMaterialForItems(detail.key);
      expect(droppedBy.map((e) => e.key).toSet().length == droppedBy.length, isTrue);
    }
  });
}
