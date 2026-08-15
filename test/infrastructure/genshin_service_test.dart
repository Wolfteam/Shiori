import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../common.dart';
import '../mocks.mocks.dart';

//TODO: ADD TEST FOR FAIL CASES (E.G WEAPON NOT FOUND, IMAGE NOT FOUND ETC)

void main() {
  ResourceService getCustomResourceService(AppLanguageType language) {
    final settings = MockSettingsService();
    when(settings.language).thenReturn(language);
    return getResourceService(settings);
  }

  GenshinService getService() {
    final localeService = getLocaleService(AppLanguageType.english);
    final resourceService = getCustomResourceService(AppLanguageType.english);
    final service = GenshinServiceImpl(resourceService, localeService);
    return service;
  }

  test('Initialize all languages', () async {
    final service = getService();

    for (final lang in AppLanguageType.values) {
      await expectLater(service.init(lang), completes);
    }
  });

  group('Charts', () {
    test('check top charts', () async {
      final types = ChartType.values.where((el) => el != ChartType.characterBirthdays).toList();
      final service = getService();
      await service.init(AppLanguageType.english);
      for (final type in types) {
        final tops = service.getTopCharts(type);
        expect(tops.isNotEmpty, isTrue, reason: 'Top charts list is empty for chart type ${type.name}');
        final totalPercentage = tops.map((e) => e.percentage).sum.round();
        expect(totalPercentage, 100, reason: 'Top chart percentages must sum to 100, got $totalPercentage (type=${type.name})');
        for (final item in tops) {
          expect(item.type, type, reason: 'Chart item type mismatch: ${item.type} vs $type (key=${item.key})');
          checkKey(item.key);
          checkTranslation(item.name, canBeNull: false, checkForColor: false, ownerKey: item.key);
          expect(item.value, greaterThan(0), reason: 'Chart item value must be positive, got ${item.value} (key=${item.key})');
          expect(
            item.percentage,
            inExclusiveRange(0, 100),
            reason: 'Chart item percentage must be between 0 and 100 exclusive, got ${item.percentage} (key=${item.key})',
          );

          final expectedStars = type.name.contains('Five') ? 5 : 4;
          switch (type) {
            case ChartType.topFiveStarCharacterMostReruns:
            case ChartType.topFourStarCharacterMostReruns:
            case ChartType.topFiveStarCharacterLeastReruns:
            case ChartType.topFourStarCharacterLeastReruns:
              final char = service.characters.getCharacter(item.key);
              expect(
                char.rarity,
                expectedStars,
                reason: 'Character rarity must be $expectedStars for chart ${type.name}, got ${char.rarity} (key=${item.key})',
              );
            case ChartType.topFiveStarWeaponMostReruns:
            case ChartType.topFourStarWeaponMostReruns:
            case ChartType.topFiveStarWeaponLeastReruns:
            case ChartType.topFourStarWeaponLeastReruns:
              final weapon = service.weapons.getWeapon(item.key);
              expect(
                weapon.rarity,
                expectedStars,
                reason: 'Weapon rarity must be $expectedStars for chart ${type.name}, got ${weapon.rarity} (key=${item.key})',
              );
            default:
              throw Exception('Type = $type is not valid');
          }

          final releaseCount = service.bannerHistory.getItemReleaseHistory(item.key).length;
          expect(
            item.value,
            releaseCount,
            reason: 'Chart item value must equal banner release count $releaseCount, got ${item.value} (key=${item.key})',
          );
        }
      }
    });

    test('check top charts, invalid type', () async {
      final service = getService();
      await service.init(AppLanguageType.english);
      expect(
        () => service.getTopCharts(ChartType.characterBirthdays),
        throwsA(isA<Exception>()),
        reason: 'getTopCharts must throw for unsupported chart type characterBirthdays',
      );
    });

    test('check item ascension stats', () async {
      final service = getService();
      await service.init(AppLanguageType.english);
      const validTypes = [ItemType.character, ItemType.weapon];
      final validForCharacters = getCharacterPossibleAscensionStats();
      final validForWeapons = getWeaponPossibleAscensionStats();
      for (final type in validTypes) {
        final stats = service.getItemAscensionStatsForCharts(type);
        expect(stats.isNotEmpty, isTrue, reason: 'Ascension stats list is empty for item type ${type.name}');

        final statTypes = stats.map((e) => e.type);
        expect(
          statTypes.toSet().length,
          statTypes.length,
          reason: 'Ascension stat types contain duplicates for item type ${type.name}',
        );

        for (final stat in stats) {
          expect(stat.itemType, type, reason: 'Ascension stat itemType mismatch: ${stat.itemType} vs $type');
          expect(
            stat.quantity,
            greaterThan(0),
            reason: 'Ascension stat quantity must be positive, got ${stat.quantity} (statType=${stat.type}, itemType=${type.name})',
          );
          if (type == ItemType.character) {
            expect(
              stat.type,
              isIn(validForCharacters),
              reason: 'Ascension stat ${stat.type} is not a valid character ascension stat',
            );
          } else {
            expect(
              stat.type,
              isIn(validForWeapons),
              reason: 'Ascension stat ${stat.type} is not a valid weapon ascension stat',
            );
          }
        }
      }
    });

    test('check item ascension stats, item type is not valid', () async {
      final service = getService();
      await service.init(AppLanguageType.english);
      final types = ItemType.values.where((el) => el != ItemType.character && el != ItemType.weapon).toList();
      for (final type in types) {
        expect(
          () => service.getItemAscensionStatsForCharts(type),
          throwsA(isA<Exception>()),
          reason: 'getItemAscensionStatsForCharts must throw for unsupported item type ${type.name}',
        );
      }
    });
  });

  group('Common', () {
    test('check items ascension stats', () async {
      final service = getService();
      await service.init(AppLanguageType.english);
      final validForCharacters = getCharacterPossibleAscensionStats();
      final validForWeapons = getWeaponPossibleAscensionStats();
      final characters = service.characters.getCharactersForCard().where((el) => !el.isComingSoon).toList();
      final weapons = service.weapons.getWeaponsForCard().where((el) => !el.isComingSoon).toList();

      for (final stat in validForCharacters) {
        final items = service.getItemsAscensionStats(stat, ItemType.character);
        expect(items.isNotEmpty, isTrue, reason: 'No character items found for ascension stat ${stat.name}');
        expect(
          items.length,
          characters.where((el) => el.subStatType == stat).length,
          reason: 'Character ascension-stat item count mismatch for stat ${stat.name}, got ${items.length}',
        );

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }

      for (final stat in validForWeapons) {
        final items = service.getItemsAscensionStats(stat, ItemType.weapon);
        expect(items.isNotEmpty, isTrue, reason: 'No weapon items found for ascension stat ${stat.name}');
        expect(
          items.length,
          weapons.where((el) => el.subStatType == stat).length,
          reason: 'Weapon ascension-stat item count mismatch for stat ${stat.name}, got ${items.length}',
        );

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });
  });
}
