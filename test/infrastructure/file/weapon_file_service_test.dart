import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  group('Get weapons for card', () {
    for (final lang in AppLanguageType.values) {
      test('language = ${lang.name}', () async {
        final service = await getWeaponFileService(lang);
        final weapons = service.getWeaponsForCard();
        checkKeys(weapons.map((e) => e.key).toList(), entity: 'weapon');
        for (final weapon in weapons) {
          checkKey(weapon.key, ownerKey: weapon.key);
          checkAsset(weapon.image, ownerKey: weapon.key);
          expect(
            weapon.name,
            allOf([isNotEmpty, isNotNull]),
            reason: 'Weapon name is empty or null (key=${weapon.key}, lang=${lang.name})',
          );
          expect(
            weapon.rarity,
            allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(5)]),
            reason: 'Weapon rarity must be 1–5, got ${weapon.rarity} (key=${weapon.key})',
          );
          expect(
            weapon.baseAtk,
            greaterThan(0),
            reason: 'Weapon base ATK must be > 0, got ${weapon.baseAtk} (key=${weapon.key})',
          );
          expect(
            weapon.subStatValue,
            greaterThanOrEqualTo(0),
            reason: 'Weapon sub-stat value must be >= 0, got ${weapon.subStatValue} (key=${weapon.key})',
          );
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getWeaponFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final weapons = service.getWeaponsForCard();
      expect(
        weapons.isEmpty,
        isTrue,
        reason: 'With no resources downloaded, weapons-for-card must be empty, got ${weapons.length}',
      );
    });
  });

  test('Get weapon', () async {
    final service = await getWeaponFileService(AppLanguageType.english);
    final weapons = service.getWeaponsForCard();
    for (final weapon in weapons) {
      final detail = service.getWeapon(weapon.key);
      checkKey(detail.key, ownerKey: weapon.key);
      checkAsset(service.resources.getWeaponImagePath(detail.image, detail.type), ownerKey: weapon.key);
      expect(
        detail.type,
        equals(weapon.type),
        reason: 'Weapon detail type ${detail.type} != card type ${weapon.type} (key=${weapon.key})',
      );
      expect(
        detail.atk,
        equals(weapon.baseAtk),
        reason: 'Weapon detail ATK ${detail.atk} != card base ATK ${weapon.baseAtk} (key=${weapon.key})',
      );
      expect(
        detail.rarity,
        equals(weapon.rarity),
        reason: 'Weapon detail rarity ${detail.rarity} != card rarity ${weapon.rarity} (key=${weapon.key})',
      );
      expect(
        detail.secondaryStat,
        equals(weapon.subStatType),
        reason: 'Weapon secondary stat ${detail.secondaryStat} != card sub-stat ${weapon.subStatType} (key=${weapon.key})',
      );
      expect(
        detail.secondaryStatValue,
        equals(weapon.subStatValue),
        reason: 'Weapon secondary stat value ${detail.secondaryStatValue} != card ${weapon.subStatValue} (key=${weapon.key})',
      );
      expect(
        detail.location,
        equals(weapon.locationType),
        reason: 'Weapon location ${detail.location} != card location ${weapon.locationType} (key=${weapon.key})',
      );
      expect(
        detail.ascensionMaterials,
        isNotEmpty,
        reason: 'Weapon must list ascension materials (key=${weapon.key})',
      );
      expect(detail.stats, isNotEmpty, reason: 'Weapon must list level stats (key=${weapon.key})');

      if (detail.location == ItemLocationType.crafting) {
        expect(
          detail.craftingMaterials,
          isNotEmpty,
          reason: 'Craftable weapon must list crafting materials (key=${weapon.key})',
        );
      } else {
        expect(
          detail.craftingMaterials,
          isEmpty,
          reason: 'Non-craftable weapon must not have crafting materials (key=${weapon.key})',
        );
      }

      for (int i = 0; i < detail.ascensionMaterials.length; i++) {
        final ascMaterial = detail.ascensionMaterials[i];
        expect(
          ascMaterial.level,
          inInclusiveRange(20, 80),
          reason: 'Weapon ascension level must be 20–80, got ${ascMaterial.level} (key=${weapon.key})',
        );
        checkItemAscensionMaterialFileModel(service.materials, ascMaterial.materials);
        final expectedLength = i == 0 && detail.rarity == 1 ? 3 : 4;
        expect(
          ascMaterial.materials.length,
          expectedLength,
          reason: 'Weapon ascension must require $expectedLength materials, got ${ascMaterial.materials.length} (key=${weapon.key})',
        );
        expect(
          ascMaterial.materials.where((el) => el.type == MaterialType.weaponPrimary).length,
          1,
          reason: 'Weapon ascension must require exactly 1 weaponPrimary material (key=${weapon.key})',
        );
        expect(
          ascMaterial.materials.where((el) => el.type == MaterialType.weapon).length,
          1,
          reason: 'Weapon ascension must require exactly 1 weapon material (key=${weapon.key})',
        );
        expect(
          ascMaterial.materials.where((el) => el.type == MaterialType.common).length,
          1,
          reason: 'Weapon ascension must require exactly 1 common material (key=${weapon.key})',
        );
        if (expectedLength > 3) {
          expect(
            ascMaterial.materials.where((el) => el.type == MaterialType.currency).length,
            1,
            reason: 'Weapon ascension must require exactly 1 currency material (Mora) (key=${weapon.key})',
          );
        }
      }

      final ascensionNumber = detail.stats.where((el) => el.isAnAscension).length;
      switch (detail.rarity) {
        case 1:
        case 2:
          expect(
            ascensionNumber,
            4,
            reason: 'Rarity ${detail.rarity} weapon must have 4 ascension stat rows, got $ascensionNumber (key=${weapon.key})',
          );
        default:
          expect(
            ascensionNumber,
            6,
            reason: 'Rarity ${detail.rarity} weapon must have 6 ascension stat rows, got $ascensionNumber (key=${weapon.key})',
          );
      }

      var repetitionCount = 0;
      for (var i = 0; i < detail.stats.length; i++) {
        final stat = detail.stats[i];
        if (detail.rarity >= 3) {
          expect(
            stat.level,
            inInclusiveRange(1, 90),
            reason: 'Weapon stat level must be 1–90, got ${stat.level} (key=${weapon.key})',
          );
        } else {
          expect(
            stat.level,
            inInclusiveRange(1, 70),
            reason: 'Low-rarity weapon stat level must be 1–70, got ${stat.level} (key=${weapon.key})',
          );
        }

        expect(
          stat.baseAtk,
          greaterThan(0),
          reason: 'Weapon stat base ATK must be > 0, got ${stat.baseAtk} (key=${weapon.key})',
        );
        if (detail.rarity > 2) {
          expect(
            stat.statValue,
            greaterThan(0),
            reason: 'Weapon stat value must be > 0, got ${stat.statValue} (key=${weapon.key})',
          );
        } else {
          expect(
            stat.statValue,
            greaterThanOrEqualTo(0),
            reason: 'Weapon stat value must be >= 0, got ${stat.statValue} (key=${weapon.key})',
          );
        }
        if (i > 0 && i < detail.stats.length - 1 && weapon.rarity > 2) {
          final nextStat = detail.stats[i + 1];
          if (nextStat.statValue == stat.statValue) {
            repetitionCount++;
          } else {
            repetitionCount = 0;
          }

          if (stat.level <= 40 && !stat.isAnAscension) {
            expect(
              repetitionCount,
              lessThanOrEqualTo(4),
              reason: 'Weapon sub-stat repeats more than 4 times at or below level 40 (got $repetitionCount, key=${weapon.key})',
            );
          } else {
            expect(
              repetitionCount,
              lessThanOrEqualTo(2),
              reason: 'Weapon sub-stat repeats more than twice (got $repetitionCount, key=${weapon.key})',
            );
          }
        }
      }
    }
  });
}
