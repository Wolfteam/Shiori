import 'package:darq/darq.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';

import '../../common.dart';
import 'common_file.dart';

//TODO: ADD TEST FOR FAIL CASES (E.G WEAPON NOT FOUND, IMAGE NOT FOUND ETC)

void main() {
  late final BannerHistoryFileService service;
  late final CharacterFileService characterFileService;
  late final WeaponFileService weaponFileService;

  setUpAll(() {
    return Future(() async {
      const lang = AppLanguageType.english;
      service = await getBannerHistoryFileService(lang);
      characterFileService = await getCharacterFileService(lang);
      weaponFileService = await getWeaponFileService(lang);
    });
  });

  void checkWishBannerItemModel(WishBannerItemModel banner, List<String> featuredItemKeys) {
    switch (banner.type) {
      case BannerItemType.character:
      case BannerItemType.weapon:
        expect(banner.featuredItems, isNotEmpty);
      case BannerItemType.standard:
        expect(banner.featuredItems, isEmpty);
    }

    expect(banner.featuredItems.map((e) => e.key).toSet().length, banner.featuredItems.length);
    expect(banner.characters, isNotEmpty);
    expect(banner.characters.map((e) => e.key).toSet().length, banner.characters.length);
    expect(banner.weapons, isNotEmpty);
    expect(banner.weapons.map((e) => e.key).toSet().length, banner.weapons.length);
    checkAsset(banner.image);

    for (final item in banner.featuredItems) {
      checkItemKeyAndImage(item.key, item.iconImage);
      checkBannerRarity(item.rarity);

      if (featuredItemKeys.isNotEmpty) {
        expect(featuredItemKeys.contains(item.key), isTrue);
      }
    }

    for (final item in banner.characters) {
      checkKey(item.key);
      checkAssets([item.iconImage, item.image]);
      checkBannerRarity(item.rarity);
    }

    for (final item in banner.weapons) {
      checkKey(item.key);
      checkAssets([item.iconImage, item.image]);
      checkBannerRarity(item.rarity);
    }
  }

  test('Get banner history version, data gets retrieved and sorted', () async {
    for (final type in SortDirectionType.values) {
      final versions = service.getBannerHistoryVersions(type);
      expect(versions, isNotEmpty);
      expect(versions.toSet().length, versions.length);
      switch (type) {
        case SortDirectionType.asc:
          expect(versions.first < versions.last, isTrue);
        case SortDirectionType.desc:
          expect(versions.first > versions.last, isTrue);
      }
    }
  });

  test('Get banner history', () async {
    for (final type in BannerHistoryItemType.values) {
      final banners = service.getBannerHistory(type);
      expect(banners.length, banners.where((el) => el.type == type).length);
      for (final banner in banners) {
        checkItemKeyAndImage(banner.key, banner.image);
        checkTranslation(banner.name, canBeNull: false);
        expect(banner.versions.isNotEmpty, isTrue);
        expect(banner.rarity >= 4, isTrue);
        expect(banner.versions.any((el) => el.released), isTrue);
        for (final version in banner.versions) {
          if (version.released) {
            expect(version.number, isNull);
            expect(version.version >= 1, isTrue);
          } else if (version.number == 0) {
            expect(version.released, isFalse);
          } else {
            expect(version.released, isFalse);
            expect(version.number, isNotNull);
            expect(version.number! >= 1, isTrue);
          }
        }
      }
    }
  });

  group('Get banners', () {
    test('valid versions', () async {
      final versions = service.getBannerHistoryVersions(SortDirectionType.asc);
      expect(versions.length, versions.toSet().length);

      final validItemTypes = [ItemType.character, ItemType.weapon];
      for (final version in versions) {
        final banners = service.getBanners(version);
        expect(banners.isNotEmpty, isTrue);
        for (final banner in banners) {
          expect(banner.version, version);
          expect(banner.until.isAfter(banner.from), isTrue);
          expect(banner.items.isNotEmpty, isTrue);

          final keys = banner.items.map((e) => e.key).toList();
          expect(keys.toSet().length == keys.length, isTrue);

          for (final item in banner.items) {
            checkItemKeyAndImage(item.key, item.image);
            expect(item.rarity >= 4, isTrue);
            expect(validItemTypes.contains(item.type), isTrue);
          }
        }
      }
    });

    test('version does not have any banner', () async {
      final banners = service.getBanners(1.7);
      expect(banners.isEmpty, isTrue);
    });

    test('invalid version', () async {
      expect(() => service.getBanners(0.1), throwsA(isA<Exception>()));
    });
  });

  group('Get item release history', () {
    test('item exists', () async {
      final history = service.getItemReleaseHistory('keqing');
      expect(history.isNotEmpty, isTrue);

      for (final item in history) {
        expect(item.dates.isNotEmpty, isTrue);
        expect(item.version >= 1, isTrue);
      }
    });

    test('item does not exist', () async {
      expect(() => service.getItemReleaseHistory('the-item'), throwsA(isA<Exception>()));
    });
  });

  group('Get elements for charts', () {
    test('valid versions', () async {
      final versions = service.getBannerHistoryVersions(SortDirectionType.asc);
      final expectedLength = ElementType.values.length;

      final elements = service.getElementsForCharts(versions.first, versions.last);
      expect(elements.length, expectedLength);
      expect(elements.map((el) => el.type).toSet().length, expectedLength);

      for (final element in elements) {
        expect(element.points.isNotEmpty, isTrue);

        for (final point in element.points) {
          expect(point.y >= 0, isTrue);
        }
      }
    });

    test('invalid from version', () async {
      expect(() => service.getElementsForCharts(-1, 2.1), throwsA(isA<Exception>()));
    });

    test('invalid until version', () async {
      expect(() => service.getElementsForCharts(1, -1), throwsA(isA<Exception>()));
    });
  });

  group('Get top charts', () {
    test('no items were provided', () {
      expect(
        () => service.getTopCharts(true, ChartType.characterBirthdays, BannerHistoryItemType.character, []),
        throwsA(isA<Exception>()),
      );
    });

    for (final bannerItemType in BannerHistoryItemType.values) {
      for (final chartType in ChartType.values) {
        test('data exists for bannerItemType = ${bannerItemType.name} and chartType = ${chartType.name}', () {
          final mostReruns = '$chartType'.toLowerCase().contains('most');
          final rarity = '$chartType'.toLowerCase().contains('four') ? 4 : 5;
          final data = <ItemCommonWithName>[];
          switch (bannerItemType) {
            case BannerHistoryItemType.character:
              final chars = characterFileService.getItemCommonWithNameByRarity(rarity);
              data.addAll(chars);
            case BannerHistoryItemType.weapon:
              final weapons = weaponFileService.getItemCommonWithNameByRarity(rarity);
              data.addAll(weapons);
            default:
              throw Exception('Invalid type');
          }

          final charts = service.getTopCharts(mostReruns, chartType, bannerItemType, data);
          expect(charts, isNotEmpty);
          for (final chart in charts) {
            checkKey(chart.key);
            checkTranslation(chart.name);
            expect(data.any((el) => el.key == chart.key), isTrue);
            expect(chart.value > 0, isTrue);
            expect(chart.percentage > 0 && chart.percentage < 100, isTrue);
            expect(chart.type, chartType);
          }
        });
      }
    }
  });

  group('Get wish simulator banner per period', () {
    test('invalid version', () {
      expect(
        () => service.getWishSimulatorBannerPerPeriod(0, DateTime.now(), DateTime.now()),
        throwsA(isA<Exception>()),
      );
    });

    test('invalid date range', () {
      expect(
        () => service.getWishSimulatorBannerPerPeriod(0, DateTime.now().add(const Duration(days: 1)), DateTime.now()),
        throwsA(isA<Exception>()),
      );
    });

    test('no data exist', () {
      expect(
        () => service.getWishSimulatorBannerPerPeriod(
          0.5,
          DateTime.now(),
          DateTime.now().add(const Duration(days: 30)),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('data exists', () {
      const double version = 1.3;
      final bannersOnVersion = service.getBanners(version);
      final featuredItemKeys = bannersOnVersion.selectMany((el, index) => el.items).map((e) => e.key).distinct().toList();

      final banner = bannersOnVersion.first;
      final from = banner.from;
      final until = banner.until;
      final bannersPerPeriod = service.getWishSimulatorBannerPerPeriod(version, from, until);

      expect(bannersPerPeriod.from == from, isTrue);
      expect(bannersPerPeriod.until == until, isTrue);
      expect(bannersPerPeriod.version == version, isTrue);
      expect(bannersPerPeriod.banners, isNotEmpty);
      for (final b in bannersPerPeriod.banners) {
        checkWishBannerItemModel(b, featuredItemKeys);
      }
    });
  });

  test('Get wish banners history grouped by version', () {
    final grouped = service.getWishBannersHistoryGroupedByVersion();
    for (final g in grouped) {
      expect(g.parts, isNotEmpty);
      expect(g.groupingKey == g.groupingTitle, isTrue);

      final version = g.parts.first.version;
      for (final part in g.parts) {
        checkAssets(part.bannerImages);
        expect(part.version == version, isTrue);

        expect(part.featuredCharacters.map((e) => e.key).toSet().length, part.featuredCharacters.length);
        expect(part.featuredCharacters.length >= 4, isTrue);
        for (final char in part.featuredCharacters) {
          checkItemKeyAndName(char.key, char.name);
        }

        expect(part.featuredWeapons.map((e) => e.key).toSet().length, part.featuredWeapons.length);
        expect(part.featuredWeapons.length >= 4, isTrue);
        for (final weapon in part.featuredWeapons) {
          checkItemKeyAndName(weapon.key, weapon.name);
        }
      }
    }
  });

  test('Get wish simulator standard banner', () {
    final banner = service.getWishSimulatorStandardBanner();
    checkWishBannerItemModel(banner, []);
  });
}
