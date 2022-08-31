import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  test('Get weapons for card', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getWeaponFileService(lang);
      final weapons = service.getWeaponsForCard();
      checkKeys(weapons.map((e) => e.key).toList());
      for (final weapon in weapons) {
        checkKey(weapon.key);
        checkAsset(weapon.image);
        expect(weapon.name, allOf([isNotEmpty, isNotNull]));
        expect(weapon.rarity, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(5)]));
        expect(weapon.baseAtk, greaterThan(0));
        expect(weapon.subStatValue, greaterThanOrEqualTo(0));
      }
    }
  });

  test('Get weapon', () async {
    final service = await getWeaponFileService(AppLanguageType.english);
    final weapons = service.getWeaponsForCard();
    for (final weapon in weapons) {
      final detail = service.getWeapon(weapon.key);
      checkKey(detail.key);
      checkAsset(detail.fullImagePath);
      expect(detail.type, equals(weapon.type));
      expect(detail.atk, equals(weapon.baseAtk));
      expect(detail.rarity, equals(weapon.rarity));
      expect(detail.secondaryStat, equals(weapon.subStatType));
      expect(detail.secondaryStatValue, equals(weapon.subStatValue));
      expect(detail.location, equals(weapon.locationType));
      expect(detail.ascensionMaterials, isNotEmpty);
      expect(detail.stats, isNotEmpty);

      if (detail.location == ItemLocationType.crafting) {
        expect(detail.craftingMaterials, isNotEmpty);
      } else {
        expect(detail.craftingMaterials, isEmpty);
      }

      for (final ascMaterial in detail.ascensionMaterials) {
        expect(ascMaterial.level, inInclusiveRange(20, 80));
        checkItemAscensionMaterialFileModel(service.materials, ascMaterial.materials);
      }

      final ascensionNumber = detail.stats.where((el) => el.isAnAscension).length;
      switch (detail.rarity) {
        case 1:
        case 2:
          expect(ascensionNumber == 4, isTrue);
          break;
        default:
          expect(ascensionNumber == 6, isTrue);
          break;
      }

      var repetitionCount = 0;
      for (var i = 0; i < detail.stats.length; i++) {
        final stat = detail.stats[i];
        if (detail.rarity >= 3) {
          expect(stat.level, inInclusiveRange(1, 90));
        } else {
          expect(stat.level, inInclusiveRange(1, 70));
        }

        expect(stat.baseAtk, greaterThan(0));
        if (detail.rarity > 2) {
          expect(stat.statValue, greaterThan(0));
        } else {
          expect(stat.statValue, greaterThanOrEqualTo(0));
        }
        if (i > 0 && i < detail.stats.length - 1 && weapon.rarity > 2) {
          final nextStat = detail.stats[i + 1];
          if (nextStat.statValue == stat.statValue) {
            repetitionCount++;
          } else {
            repetitionCount = 0;
          }

          if (stat.level <= 40 && !stat.isAnAscension) {
            expect(repetitionCount, lessThanOrEqualTo(4));
          } else {
            expect(repetitionCount, lessThanOrEqualTo(2));
          }
        }
      }
    }
  });
}
