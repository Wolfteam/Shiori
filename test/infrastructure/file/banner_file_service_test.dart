import 'package:darq/darq.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
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

  void checkWishBannerItemModel(WishSimulatorBannerItemModel banner, List<String> featuredItemKeys) {
    switch (banner.type) {
      case BannerItemType.character:
      case BannerItemType.weapon:
        expect(banner.featuredItems, isNotEmpty, reason: 'Should not be empty (property=featuredItems)');
      case BannerItemType.standard:
        expect(banner.featuredItems, isEmpty, reason: 'Should be empty (property=featuredItems)');
    }

    expect(banner.featuredItems.map((e) => e.key).toSet().length, banner.featuredItems.length, reason: 'Should match expected value (property=featuredItems)');
    expect(banner.characters, isNotEmpty, reason: 'Should not be empty (property=characters)');
    expect(banner.characters.map((e) => e.key).toSet().length, banner.characters.length, reason: 'Should match expected value (property=characters)');
    expect(banner.weapons, isNotEmpty, reason: 'Should not be empty (property=weapons)');
    expect(banner.weapons.map((e) => e.key).toSet().length, banner.weapons.length, reason: 'Should match expected value (property=weapons)');
    checkAsset(banner.image);

    for (final item in banner.featuredItems) {
      checkItemKeyAndImage(item.key, item.iconImage);
      checkBannerRarity(item.rarity);

      if (featuredItemKeys.isNotEmpty) {
        expect(featuredItemKeys.contains(item.key), isTrue, reason: 'Should be true (property=key))');
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

  group('Get banner history version', () {
    for (final type in SortDirectionType.values) {
      test('data gets retrieved and sorted by ${type.name}', () {
        final versions = service.getBannerHistoryVersions(type);
        expect(versions, isNotEmpty, reason: 'Should not be empty');
        expect(versions.toSet().length, versions.length, reason: 'Should match expected value (property=toSet())');
        switch (type) {
          case SortDirectionType.asc:
            expect(versions.first < versions.last, isTrue, reason: 'Should be true (property=last, isTrue)');
          case SortDirectionType.desc:
            expect(versions.first > versions.last, isTrue, reason: 'Should be true (property=last, isTrue)');
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getBannerHistoryFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final versions = service.getBannerHistoryVersions(SortDirectionType.asc);
      expect(versions.isEmpty, isTrue, reason: 'Should be true');
    });
  });

  test('Get banner history', () {
    for (final type in BannerHistoryItemType.values) {
      final banners = service.getBannerHistory(type);
      expect(banners.length, banners.where((el) => el.type == type).length, reason: 'Should match expected value');
      for (final banner in banners) {
        checkItemKeyAndImage(banner.key, banner.image);
        checkTranslation(banner.name, canBeNull: false);
        expect(banner.versions.isNotEmpty, isTrue, reason: 'Should be true (property=versions)');
        expect(banner.rarity >= 4, isTrue, reason: 'Should be true (property=rarity >= 4, isTrue)');
        expect(banner.versions.any((el) => el.released), isTrue, reason: 'Should be true (property=released), isTrue)');
        for (final version in banner.versions) {
          if (version.released) {
            expect(version.number, isNull, reason: 'Should be null (property=number)');
            expect(version.version >= 1, isTrue, reason: 'Should be true (property=version >= 1, isTrue)');
          } else if (version.number == 0) {
            expect(version.released, isFalse, reason: 'Should be false (property=released)');
          } else {
            expect(version.released, isFalse, reason: 'Should be false (property=released)');
            expect(version.number, isNotNull, reason: 'Should not be null (property=number)');
            expect(version.number! >= 1, isTrue, reason: 'Should be true (property=number! >= 1, isTrue)');
          }
        }
      }
    }
  });

  group('Get banners', () {
    test('valid versions', () {
      final versions = service.getBannerHistoryVersions(SortDirectionType.asc);
      expect(versions.length, versions.toSet().length, reason: 'Should match expected value');

      final validItemTypes = [ItemType.character, ItemType.weapon];
      for (final version in versions) {
        final banners = service.getBanners(version);
        expect(banners.isNotEmpty, isTrue, reason: 'Should be true');
        for (final banner in banners) {
          expect(banner.version, version, reason: 'Should match expected value (property=version)');
          expect(banner.until.isAfter(banner.from), isTrue, reason: 'Should be true (property=from))');
          expect(banner.items.isNotEmpty, isTrue, reason: 'Should be true (property=items)');

          final keys = banner.items.map((e) => e.key).toList();
          expect(keys.toSet().length == keys.length, isTrue, reason: 'Should be true (property=length == keys)');

          for (final item in banner.items) {
            checkItemKeyAndImage(item.key, item.image);
            expect(item.rarity >= 4, isTrue, reason: 'Should be true (property=rarity >= 4, isTrue)');
            expect(validItemTypes.contains(item.type), isTrue, reason: 'Should be true (property=type))');
          }
        }
      }
    });

    test('version does not have any banner', () {
      final banners = service.getBanners(1.7);
      expect(banners.isEmpty, isTrue, reason: 'Should be true');
    });

    test('invalid version', () {
      expect(
        () => service.getBanners(0.1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'version')), reason: 'Should throw expected exception');
    });
  });

  group('Get item release history', () {
    test('item exists', () {
      final history = service.getItemReleaseHistory('keqing');
      expect(history.isNotEmpty, isTrue, reason: 'Should be true');

      for (final item in history) {
        expect(item.dates.isNotEmpty, isTrue, reason: 'Should be true (property=dates)');
        expect(item.version >= 1, isTrue, reason: 'Should be true (property=version >= 1, isTrue)');
      }
    });

    test('item does not exist', () {
      expect(() => service.getItemReleaseHistory('the-item'), throwsA(isA<NotFoundError>()), reason: 'Should be of expected type');
    });
  });

  group('Get elements for charts', () {
    test('valid versions', () {
      final versions = service.getBannerHistoryVersions(SortDirectionType.asc);
      final expectedLength = ElementType.values.length;

      final elements = service.getElementsForCharts(versions.first, versions.last);
      expect(elements.length, expectedLength, reason: 'Should match expected value');
      expect(elements.map((el) => el.type).toSet().length, expectedLength, reason: 'Should match expected value (property=length, expectedLength)');

      for (final element in elements) {
        expect(element.points.isNotEmpty, isTrue, reason: 'Should be true (property=points)');

        for (final point in element.points) {
          expect(point.y >= 0, isTrue, reason: 'Should be true (property=y >= 0, isTrue)');
        }
      }
    });

    test('invalid from version', () {
      expect(
        () => service.getElementsForCharts(-1, 2.1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'fromVersion')), reason: 'Should throw expected exception');
    });

    test('invalid until version', () {
      expect(
        () => service.getElementsForCharts(1, -1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'untilVersion')), reason: 'Should throw expected exception');
    });
  });

  group('Get top charts', () {
    test('no items were provided', () {
      expect(
        () => service.getTopCharts(true, ChartType.characterBirthdays, BannerHistoryItemType.character, []),
        throwsA(isA<UnsupportedError>()), reason: 'Should be of expected type');
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
          }

          final charts = service.getTopCharts(mostReruns, chartType, bannerItemType, data);
          expect(charts, isNotEmpty, reason: 'Should not be empty');
          for (final chart in charts) {
            checkKey(chart.key);
            checkTranslation(chart.name);
            expect(data.any((el) => el.key == chart.key), isTrue, reason: 'Should be true (property=key), isTrue)');
            expect(chart.value > 0, isTrue, reason: 'Should be true (property=value > 0, isTrue)');
            expect(chart.percentage > 0 && chart.percentage < 100, isTrue, reason: 'Should be true (property=percentage < 100)');
            expect(chart.type, chartType, reason: 'Should match expected value (property=type)');
          }
        });
      }
    }
  });

  group('Get wish simulator banner per period', () {
    test('invalid version', () {
      expect(
        () => service.getWishSimulatorBannerPerPeriod(0, DateTime.now(), DateTime.now()),
        throwsA(predicate<ArgumentError>((e) => e.name == 'version')), reason: 'Should throw expected exception');
    });

    test('invalid date range', () {
      expect(
        () => service.getWishSimulatorBannerPerPeriod(0, DateTime.now().add(const Duration(days: 1)), DateTime.now()),
        throwsA(predicate<ArgumentError>((e) => e.name == 'version')), reason: 'Should throw expected exception');
    });

    test('no data exist', () {
      expect(
        () => service.getWishSimulatorBannerPerPeriod(
          0.5,
          DateTime.now(),
          DateTime.now().add(const Duration(days: 30)),
        ),
        throwsA(predicate<RangeError>((e) => e.toString().toLowerCase().contains('is not valid'))), reason: 'Should contain expected value');
    });

    test('data exists', () {
      const double version = 1.3;
      final bannersOnVersion = service.getBanners(version);
      final featuredItemKeys = bannersOnVersion.selectMany((el, index) => el.items).map((e) => e.key).distinct().toList();

      final banner = bannersOnVersion.first;
      final from = banner.from;
      final until = banner.until;
      final bannersPerPeriod = service.getWishSimulatorBannerPerPeriod(version, from, until);

      expect(bannersPerPeriod.from == from, isTrue, reason: 'Should be true (property=from == from)');
      expect(bannersPerPeriod.until == until, isTrue, reason: 'Should be true (property=until == until)');
      expect(bannersPerPeriod.version == version, isTrue, reason: 'Should be true (property=version == version)');
      expect(bannersPerPeriod.banners, isNotEmpty, reason: 'Should not be empty (property=banners)');
      for (final b in bannersPerPeriod.banners) {
        checkWishBannerItemModel(b, featuredItemKeys);
      }
    });
  });

  test('Get wish banners history grouped by version', () {
    final grouped = service.getWishBannersHistoryGroupedByVersion();
    for (final g in grouped) {
      expect(g.parts, isNotEmpty, reason: 'Should not be empty (property=parts)');
      expect(g.groupingKey == g.groupingTitle, isTrue, reason: 'Should be true (property=groupingTitle)');

      final version = g.parts.first.version;
      for (final part in g.parts) {
        checkAssets(part.bannerImages);
        expect(part.version == version, isTrue, reason: 'Should be true (property=version == version)');

        expect(part.featuredCharacters.map((e) => e.key).toSet().length, part.featuredCharacters.length, reason: 'Should match expected value (property=featuredCharacters)');
        expect(part.featuredCharacters.length >= 4, isTrue, reason: 'Should be true (property=length >= 4, isTrue)');
        for (final char in part.featuredCharacters) {
          checkItemKeyAndName(char.key, char.name);
        }

        expect(part.featuredWeapons.map((e) => e.key).toSet().length, part.featuredWeapons.length, reason: 'Should match expected value (property=featuredWeapons)');
        expect(part.featuredWeapons.length >= 4, isTrue, reason: 'Should be true (property=length >= 4, isTrue)');
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
