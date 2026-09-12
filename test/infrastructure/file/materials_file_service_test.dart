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
        checkKeys(materials.map((e) => e.key).toList(), entity: 'material');
        for (final material in materials) {
          checkKey(material.key, ownerKey: material.key);
          checkAsset(material.image, ownerKey: material.key);
          expect(
            material.name,
            allOf([isNotEmpty, isNotNull]),
            reason: 'Material name is empty or null (key=${material.key}, lang=${lang.name})',
          );
          expect(
            material.rarity,
            allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(5)]),
            reason: 'Material rarity must be 1–5, got ${material.rarity} (key=${material.key})',
          );
          expect(
            material.level,
            greaterThanOrEqualTo(0),
            reason: 'Material level must be >= 0, got ${material.level} (key=${material.key})',
          );
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getMaterialFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final materials = service.getAllMaterialsForCard();
      expect(
        materials.isEmpty,
        isTrue,
        reason: 'With no resources downloaded, materials-for-card must be empty, got ${materials.length}',
      );
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
      checkKey(detail.key, ownerKey: material.key);
      checkAsset(service.resources.getMaterialImagePath(detail.image, detail.type), ownerKey: material.key);
      expect(
        detail.rarity,
        equals(material.rarity),
        reason: 'Material detail rarity ${detail.rarity} != card rarity ${material.rarity} (key=${material.key})',
      );
      expect(
        detail.type,
        equals(material.type),
        reason: 'Material detail type ${detail.type} != card type ${material.type} (key=${material.key})',
      );

      switch (detail.type) {
        case MaterialType.common:
          expect(
            detail.hasSiblings,
            isTrue,
            reason: 'Common material must have upgrade siblings (key=${material.key})',
          );
          expect(
            detail.rarity,
            inInclusiveRange(1, 4),
            reason: 'Common material rarity must be 1–4, got ${detail.rarity} (key=${material.key})',
          );
          expect(
            detail.level,
            inInclusiveRange(0, 3),
            reason: 'Common material level must be 0–3, got ${detail.level} (key=${material.key})',
          );
        case MaterialType.elementalStone:
          expect(
            detail.rarity,
            equals(4),
            reason: 'Elemental stone rarity must be 4, got ${detail.rarity} (key=${material.key})',
          );
          expect(
            detail.level,
            equals(0),
            reason: 'Elemental stone level must be 0, got ${detail.level} (key=${material.key})',
          );
        case MaterialType.jewels:
          expect(
            detail.hasSiblings,
            isTrue,
            reason: 'Jewel material must have upgrade siblings (key=${material.key})',
          );
          expect(
            detail.rarity,
            inInclusiveRange(2, 5),
            reason: 'Jewel material rarity must be 2–5, got ${detail.rarity} (key=${material.key})',
          );
          expect(
            detail.level,
            inInclusiveRange(0, 3),
            reason: 'Jewel material level must be 0–3, got ${detail.level} (key=${material.key})',
          );
        case MaterialType.local:
          expect(
            detail.attributes,
            allOf([isNotNull, isNotEmpty]),
            reason: 'Local specialty must have attributes (key=${material.key})',
          );
        case MaterialType.talents:
          if (detail.rarity >= 5) {
            continue;
          }

          expect(
            detail.days,
            isNotEmpty,
            reason: 'Talent-book material must list farmable days (key=${material.key})',
          );
          for (final day in detail.days) {
            expect(day, isIn([1, 2, 3, 4, 5, 6, 7]), reason: 'Talent-book farmable day must be 1–7, got $day (key=${material.key})');
          }

          expect(
            detail.hasSiblings,
            isTrue,
            reason: 'Talent-book material must have upgrade siblings (key=${material.key})',
          );
          expect(
            detail.rarity,
            inInclusiveRange(2, 4),
            reason: 'Talent-book material rarity must be 2–4, got ${detail.rarity} (key=${material.key})',
          );
          expect(
            detail.level,
            inInclusiveRange(0, 2),
            reason: 'Talent-book material level must be 0–2, got ${detail.level} (key=${material.key})',
          );
        case MaterialType.weapon:
          expect(
            detail.hasSiblings,
            isTrue,
            reason: 'Weapon-ascension material must have upgrade siblings (key=${material.key})',
          );
          expect(
            detail.rarity,
            inInclusiveRange(1, 4),
            reason: 'Weapon-ascension material rarity must be 1–4, got ${detail.rarity} (key=${material.key})',
          );
          expect(
            detail.level,
            inInclusiveRange(0, 3),
            reason: 'Weapon-ascension material level must be 0–3, got ${detail.level} (key=${material.key})',
          );
        case MaterialType.weaponPrimary:
          expect(
            detail.days,
            isNotEmpty,
            reason: 'Weapon-primary material must list farmable days (key=${material.key})',
          );
          for (final day in detail.days) {
            expect(day, isIn([1, 2, 3, 4, 5, 6, 7]), reason: 'Weapon-primary farmable day must be 1–7, got $day (key=${material.key})');
          }
          expect(
            detail.hasSiblings,
            isTrue,
            reason: 'Weapon-primary material must have upgrade siblings (key=${material.key})',
          );
          expect(
            detail.rarity,
            inInclusiveRange(2, 5),
            reason: 'Weapon-primary material rarity must be 2–5, got ${detail.rarity} (key=${material.key})',
          );
          expect(
            detail.level,
            inInclusiveRange(0, 3),
            reason: 'Weapon-primary material level must be 0–3, got ${detail.level} (key=${material.key})',
          );
        case MaterialType.currency:
          break;
        case MaterialType.others:
          break;
        case MaterialType.ingredient:
          break;
        case MaterialType.expWeapon:
        case MaterialType.expCharacter:
          expect(
            detail.attributes,
            allOf([isNotNull, isNotEmpty]),
            reason: 'Experience material must have attributes (key=${material.key})',
          );
          expect(
            detail.experienceAttributes,
            isNotNull,
            reason: 'Experience material must have experienceAttributes (key=${material.key})',
          );
          expect(
            detail.isAnExperienceMaterial,
            isTrue,
            reason: 'Material of type ${detail.type} must be flagged isAnExperienceMaterial (key=${material.key})',
          );
      }

      final partOfRecipes = detail.recipes + detail.obtainedFrom;

      for (final part in partOfRecipes) {
        checkKey(part.createsMaterialKey, ownerKey: material.key);
        if (!checkedPartOfRecipesKeys.contains(part.createsMaterialKey)) {
          expect(
            () => service.getMaterial(part.createsMaterialKey),
            returnsNormally,
            reason: 'Recipe references material "${part.createsMaterialKey}" that must resolve via getMaterial (key=${material.key})',
          );
          checkedPartOfRecipesKeys.add(part.createsMaterialKey);
        }

        for (final needs in part.needs) {
          expect(
            needs.quantity,
            greaterThanOrEqualTo(1),
            reason: 'Recipe need quantity must be >= 1, got ${needs.quantity} (key=${material.key})',
          );
          if (!checkedNeedsKeys.contains(needs.key)) {
            expect(
              () => service.getMaterial(needs.key),
              returnsNormally,
              reason: 'Recipe need references material "${needs.key}" that must resolve via getMaterial (key=${material.key})',
            );
            checkedNeedsKeys.add(needs.key);
          }
        }
      }

      final characters = characterFileService.getCharacterForItemsUsingMaterial(material.key);
      expect(
        characters.map((e) => e.key).toSet().length == characters.length,
        isTrue,
        reason: 'Characters using material "${material.key}" contain duplicate keys',
      );

      final weapons = weaponFileService.getWeaponForItemsUsingMaterial(material.key);
      expect(
        weapons.map((e) => e.key).toSet().length == weapons.length,
        isTrue,
        reason: 'Weapons using material "${material.key}" contain duplicate keys',
      );

      final droppedBy = monsterFileService.getRelatedMonsterToMaterialForItems(detail.key);
      expect(
        droppedBy.map((e) => e.key).toSet().length == droppedBy.length,
        isTrue,
        reason: 'Monsters dropping material "${material.key}" contain duplicate keys',
      );
    }
  });
}
