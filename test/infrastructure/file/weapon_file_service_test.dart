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
        checkKeys(weapons.map((e) => e.key).toList());
        for (final weapon in weapons) {
          checkKey(weapon.key);
          checkAsset(weapon.image);
          expect(weapon.name, allOf([isNotEmpty, isNotNull]), reason: 'Should not be empty (property=name, key=${weapon.key})');
          expect(weapon.rarity, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(5)]), reason: 'Should be greater than expected (property=rarity, key=${weapon.key})');
          expect(weapon.baseAtk, greaterThan(0), reason: 'Should be greater than expected (property=baseAtk, key=${weapon.key})');
          expect(weapon.subStatValue, greaterThanOrEqualTo(0), reason: 'Should be greater than expected (property=subStatValue, key=${weapon.key})');
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getWeaponFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final weapons = service.getWeaponsForCard();
      expect(weapons.isEmpty, isTrue, reason: 'Should be true');
    });
  });

  test('Get weapon', () async {
    final service = await getWeaponFileService(AppLanguageType.english);
    final weapons = service.getWeaponsForCard();
    for (final weapon in weapons) {
      final detail = service.getWeapon(weapon.key);
      checkKey(detail.key);
      checkAsset(service.resources.getWeaponImagePath(detail.image, detail.type));
      expect(detail.type, equals(weapon.type), reason: 'Should equal expected value (property=type, key=${weapon.key})');
      expect(detail.atk, equals(weapon.baseAtk), reason: 'Should equal expected value (property=atk, key=${weapon.key})');
      expect(detail.rarity, equals(weapon.rarity), reason: 'Should equal expected value (property=rarity, key=${weapon.key})');
      expect(detail.secondaryStat, equals(weapon.subStatType), reason: 'Should equal expected value (property=secondaryStat, key=${weapon.key})');
      expect(detail.secondaryStatValue, equals(weapon.subStatValue), reason: 'Should equal expected value (property=secondaryStatValue, key=${weapon.key})');
      expect(detail.location, equals(weapon.locationType), reason: 'Should equal expected value (property=location, key=${weapon.key})');
      expect(detail.ascensionMaterials, isNotEmpty, reason: 'Should not be empty (property=ascensionMaterials, key=${weapon.key})');
      expect(detail.stats, isNotEmpty, reason: 'Should not be empty (property=stats, key=${weapon.key})');

      if (detail.location == ItemLocationType.crafting) {
        expect(detail.craftingMaterials, isNotEmpty, reason: 'Should not be empty (property=craftingMaterials, key=${weapon.key})');
      } else {
        expect(detail.craftingMaterials, isEmpty, reason: 'Should be empty (property=craftingMaterials, key=${weapon.key})');
      }

      for (int i = 0; i < detail.ascensionMaterials.length; i++) {
        final ascMaterial = detail.ascensionMaterials[i];
        expect(ascMaterial.level, inInclusiveRange(20, 80), reason: 'Should be within expected range (property=level, key=${weapon.key})');
        checkItemAscensionMaterialFileModel(service.materials, ascMaterial.materials);
        final expectedLength = i == 0 && detail.rarity == 1 ? 3 : 4;
        expect(ascMaterial.materials.length, expectedLength, reason: 'Should match expected value (property=materials, key=${weapon.key})');
        expect(ascMaterial.materials.where((el) => el.type == MaterialType.weaponPrimary).length, 1, reason: 'Should match expected value (property=length, 1, key=${weapon.key})');
        expect(ascMaterial.materials.where((el) => el.type == MaterialType.weapon).length, 1, reason: 'Should match expected value (property=length, 1, key=${weapon.key})');
        expect(ascMaterial.materials.where((el) => el.type == MaterialType.common).length, 1, reason: 'Should match expected value (property=length, 1, key=${weapon.key})');
        if (expectedLength > 3) {
          expect(ascMaterial.materials.where((el) => el.type == MaterialType.currency).length, 1, reason: 'Should match expected value (property=length, 1, key=${weapon.key})');
        }
      }

      final ascensionNumber = detail.stats.where((el) => el.isAnAscension).length;
      switch (detail.rarity) {
        case 1:
        case 2:
          expect(ascensionNumber == 4, isTrue, reason: 'Should be true (key=${weapon.key})');
        default:
          expect(ascensionNumber == 6, isTrue, reason: 'Should be true (key=${weapon.key})');
      }

      var repetitionCount = 0;
      for (var i = 0; i < detail.stats.length; i++) {
        final stat = detail.stats[i];
        if (detail.rarity >= 3) {
          expect(stat.level, inInclusiveRange(1, 90), reason: 'Should be within expected range (property=level, key=${weapon.key})');
        } else {
          expect(stat.level, inInclusiveRange(1, 70), reason: 'Should be within expected range (property=level, key=${weapon.key})');
        }

        expect(stat.baseAtk, greaterThan(0), reason: 'Should be greater than expected (property=baseAtk, key=${weapon.key})');
        if (detail.rarity > 2) {
          expect(stat.statValue, greaterThan(0), reason: 'Should be greater than expected (property=statValue, key=${weapon.key})');
        } else {
          expect(stat.statValue, greaterThanOrEqualTo(0), reason: 'Should be greater than expected (property=statValue, key=${weapon.key})');
        }
        if (i > 0 && i < detail.stats.length - 1 && weapon.rarity > 2) {
          final nextStat = detail.stats[i + 1];
          if (nextStat.statValue == stat.statValue) {
            repetitionCount++;
          } else {
            repetitionCount = 0;
          }

          if (stat.level <= 40 && !stat.isAnAscension) {
            expect(repetitionCount, lessThanOrEqualTo(4), reason: 'Should be less than expected (key=${weapon.key})');
          } else {
            expect(repetitionCount, lessThanOrEqualTo(2), reason: 'Should be less than expected (key=${weapon.key})');
          }
        }
      }
    }
  });
}
