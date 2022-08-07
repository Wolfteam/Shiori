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
  ResourceService _getResourceService(AppLanguageType language) {
    final settings = MockSettingsService();
    when(settings.language).thenReturn(language);
    return getResourceService(settings);
  }

  GenshinService _getService() {
    final localeService = getLocaleService(AppLanguageType.english);
    final resourceService = _getResourceService(AppLanguageType.english);
    final service = GenshinServiceImpl(resourceService, localeService);
    return service;
  }

  test('Initialize all languages', () async {
    final service = _getService();

    for (final lang in AppLanguageType.values) {
      await expectLater(service.init(lang), completes);
    }
  });

  group('Charts', () {
    test('check top charts', () async {
      final types = ChartType.values.where((el) => el != ChartType.characterBirthdays).toList();
      final service = _getService();
      await service.init(AppLanguageType.english);
      for (final type in types) {
        final tops = service.getTopCharts(type);
        expect(tops.isNotEmpty, isTrue);
        final totalPercentage = tops.map((e) => e.percentage).sum.round();
        expect(totalPercentage, 100);
        for (final item in tops) {
          expect(item.type == type, isTrue);
          checkKey(item.key);
          checkTranslation(item.name, canBeNull: false, checkForColor: false);
          expect(item.value > 0, isTrue);
          expect(item.percentage > 0 && item.percentage < 100, isTrue);

          final expectedStars = type.name.contains('Five') ? 5 : 4;
          switch (type) {
            case ChartType.topFiveStarCharacterMostReruns:
            case ChartType.topFourStarCharacterMostReruns:
            case ChartType.topFiveStarCharacterLeastReruns:
            case ChartType.topFourStarCharacterLeastReruns:
              final char = service.characters.getCharacter(item.key);
              expect(char.rarity == expectedStars, isTrue);
              break;
            case ChartType.topFiveStarWeaponMostReruns:
            case ChartType.topFourStarWeaponMostReruns:
            case ChartType.topFiveStarWeaponLeastReruns:
            case ChartType.topFourStarWeaponLeastReruns:
              final weapon = service.weapons.getWeapon(item.key);
              expect(weapon.rarity == expectedStars, isTrue);
              break;
            default:
              throw Exception('Type = $type is not valid');
          }

          final releaseCount = service.bannerHistory.getItemReleaseHistory(item.key).length;
          expect(item.value == releaseCount, isTrue);
        }
      }
    });

    test('check top charts, invalid type', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      expect(() => service.getTopCharts(ChartType.characterBirthdays), throwsA(isA<Exception>()));
    });

    test('check item ascension stats', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      const validTypes = [ItemType.character, ItemType.weapon];
      final validForCharacters = getCharacterPossibleAscensionStats();
      final validForWeapons = getWeaponPossibleAscensionStats();
      for (final type in validTypes) {
        final stats = service.getItemAscensionStatsForCharts(type);
        expect(stats.isNotEmpty, isTrue);

        final statTypes = stats.map((e) => e.type);
        expect(statTypes.toSet().length, statTypes.length);

        for (final stat in stats) {
          expect(stat.itemType, type);
          expect(stat.quantity > 0, isTrue);
          if (type == ItemType.character) {
            expect(stat.type, isIn(validForCharacters));
          } else {
            expect(stat.type, isIn(validForWeapons));
          }
        }
      }
    });

    test('check item ascension stats, item type is not valid', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final types = ItemType.values.where((el) => el != ItemType.character && el != ItemType.weapon).toList();
      for (final type in types) {
        expect(() => service.getItemAscensionStatsForCharts(type), throwsA(isA<Exception>()));
      }
    });
  });

  group('Common', () {
    test('check items ascension stats', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final validForCharacters = getCharacterPossibleAscensionStats();
      final validForWeapons = getWeaponPossibleAscensionStats();
      final characters = service.characters.getCharactersForCard().where((el) => !el.isComingSoon).toList();
      final weapons = service.weapons.getWeaponsForCard().where((el) => !el.isComingSoon).toList();

      for (final stat in validForCharacters) {
        final items = service.getItemsAscensionStats(stat, ItemType.character);
        expect(items.isNotEmpty, isTrue);
        expect(items.length, characters.where((el) => el.subStatType == stat).length);

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }

      for (final stat in validForWeapons) {
        final items = service.getItemsAscensionStats(stat, ItemType.weapon);
        expect(items.isNotEmpty, isTrue);
        expect(items.length, weapons.where((el) => el.subStatType == stat).length);

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });
  });
}
