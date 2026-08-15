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
        expect(
          banner.featuredItems,
          isNotEmpty,
          reason: 'Character/weapon banner must have featured items, but featuredItems is empty (type=${banner.type.name})',
        );
      case BannerItemType.standard:
        expect(
          banner.featuredItems,
          isEmpty,
          reason: 'Standard banner must not have featured items, but featuredItems is non-empty (type=${banner.type.name})',
        );
    }

    expect(
      banner.featuredItems.map((e) => e.key).toSet().length,
      banner.featuredItems.length,
      reason: 'Banner featuredItems contain duplicate keys (count=${banner.featuredItems.length})',
    );
    expect(banner.characters, isNotEmpty, reason: 'Banner pool has no characters — every banner must list its characters');
    expect(
      banner.characters.map((e) => e.key).toSet().length,
      banner.characters.length,
      reason: 'Banner characters contain duplicate keys (count=${banner.characters.length})',
    );
    expect(banner.weapons, isNotEmpty, reason: 'Banner pool has no weapons — every banner must list its weapons');
    expect(
      banner.weapons.map((e) => e.key).toSet().length,
      banner.weapons.length,
      reason: 'Banner weapons contain duplicate keys (count=${banner.weapons.length})',
    );
    checkAsset(banner.image);

    for (final item in banner.featuredItems) {
      checkItemKeyAndImage(item.key, item.iconImage);
      checkBannerRarity(item.rarity, ownerKey: item.key);

      if (featuredItemKeys.isNotEmpty) {
        expect(
          featuredItemKeys.contains(item.key),
          isTrue,
          reason: 'Featured item "${item.key}" is not in the expected featured keys for this banner',
        );
      }
    }

    for (final item in banner.characters) {
      checkKey(item.key, ownerKey: item.key);
      checkAssets([item.iconImage, item.image], ownerKey: item.key);
      checkBannerRarity(item.rarity, ownerKey: item.key);
    }

    for (final item in banner.weapons) {
      checkKey(item.key, ownerKey: item.key);
      checkAssets([item.iconImage, item.image], ownerKey: item.key);
      checkBannerRarity(item.rarity, ownerKey: item.key);
    }
  }

  group('Get banner history version', () {
    for (final type in SortDirectionType.values) {
      test('data gets retrieved and sorted by ${type.name}', () {
        final versions = service.getBannerHistoryVersions(type);
        expect(versions, isNotEmpty, reason: 'No banner-history versions were retrieved (sort=${type.name})');
        expect(
          versions.toSet().length,
          versions.length,
          reason: 'Banner-history versions contain duplicates (sort=${type.name})',
        );
        switch (type) {
          case SortDirectionType.asc:
            expect(
              versions.first < versions.last,
              isTrue,
              reason: 'Ascending sort failed: first ${versions.first} is not < last ${versions.last}',
            );
          case SortDirectionType.desc:
            expect(
              versions.first > versions.last,
              isTrue,
              reason: 'Descending sort failed: first ${versions.first} is not > last ${versions.last}',
            );
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getBannerHistoryFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final versions = service.getBannerHistoryVersions(SortDirectionType.asc);
      expect(
        versions.isEmpty,
        isTrue,
        reason: 'With no resources downloaded, banner-history versions must be empty, got ${versions.length}',
      );
    });
  });

  test('Get banner history', () {
    for (final type in BannerHistoryItemType.values) {
      final banners = service.getBannerHistory(type);
      expect(
        banners.length,
        banners.where((el) => el.type == type).length,
        reason: 'Banner history for ${type.name} returned entries whose type != ${type.name}',
      );
      for (final banner in banners) {
        checkItemKeyAndImage(banner.key, banner.image);
        checkTranslation(banner.name, canBeNull: false, ownerKey: banner.key);
        expect(banner.versions.isNotEmpty, isTrue, reason: 'Banner "${banner.key}" has no versions listed');
        expect(
          banner.rarity,
          greaterThanOrEqualTo(4),
          reason: 'Banner "${banner.key}" rarity must be >= 4, got ${banner.rarity}',
        );
        expect(
          banner.versions.any((el) => el.released),
          isTrue,
          reason: 'Banner "${banner.key}" has no released version',
        );
        for (final version in banner.versions) {
          if (version.released) {
            expect(version.number, isNull, reason: 'Released banner version must have a null number, got ${version.number} (key=${banner.key})');
            expect(
              version.version,
              greaterThanOrEqualTo(1),
              reason: 'Released banner version must be >= 1, got ${version.version} (key=${banner.key})',
            );
          } else if (version.number == 0) {
            expect(version.released, isFalse, reason: 'Banner version with number 0 must not be released (key=${banner.key})');
          } else {
            expect(version.released, isFalse, reason: 'Upcoming banner version must not be released (key=${banner.key})');
            expect(version.number, isNotNull, reason: 'Upcoming banner version must have a non-null number (key=${banner.key})');
            expect(
              version.number,
              greaterThanOrEqualTo(1),
              reason: 'Upcoming banner version number must be >= 1, got ${version.number} (key=${banner.key})',
            );
          }
        }
      }
    }
  });

  group('Get banners', () {
    test('valid versions', () {
      final versions = service.getBannerHistoryVersions(SortDirectionType.asc);
      expect(versions.length, versions.toSet().length, reason: 'Banner-history versions contain duplicates (count=${versions.length})');

      final validItemTypes = [ItemType.character, ItemType.weapon];
      for (final version in versions) {
        final banners = service.getBanners(version);
        expect(banners.isNotEmpty, isTrue, reason: 'No banners found for version $version');
        for (final banner in banners) {
          expect(banner.version, version, reason: 'Banner version mismatch: ${banner.version} vs requested $version');
          expect(
            banner.until.isAfter(banner.from),
            isTrue,
            reason: 'Banner "until" ${banner.until} is not after "from" ${banner.from} (version=$version)',
          );
          expect(banner.items.isNotEmpty, isTrue, reason: 'Banner on version $version has no items');

          final keys = banner.items.map((e) => e.key).toList();
          expect(keys.toSet().length == keys.length, isTrue, reason: 'Banner items contain duplicate keys (version=$version)');

          for (final item in banner.items) {
            checkItemKeyAndImage(item.key, item.image);
            expect(
              item.rarity,
              greaterThanOrEqualTo(4),
              reason: 'Banner item "${item.key}" rarity must be >= 4, got ${item.rarity}',
            );
            expect(
              validItemTypes.contains(item.type),
              isTrue,
              reason: 'Banner item "${item.key}" has unexpected type ${item.type} (only character/weapon allowed)',
            );
          }
        }
      }
    });

    test('version does not have any banner', () {
      final banners = service.getBanners(1.7);
      expect(banners.isEmpty, isTrue, reason: 'Version 1.7 must have no banners, got ${banners.length}');
    });

    test('invalid version', () {
      expect(
        () => service.getBanners(0.1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'version')),
        reason: 'getBanners(0.1) must throw ArgumentError(name: version) for an out-of-range version',
      );
    });
  });

  group('Get item release history', () {
    test('item exists', () {
      final history = service.getItemReleaseHistory('keqing');
      expect(history.isNotEmpty, isTrue, reason: 'No release history found for keqing');

      for (final item in history) {
        expect(item.dates.isNotEmpty, isTrue, reason: 'Release-history entry has no dates (version=${item.version})');
        expect(
          item.version,
          greaterThanOrEqualTo(1),
          reason: 'Release-history version must be >= 1, got ${item.version}',
        );
      }
    });

    test('item does not exist', () {
      expect(
        () => service.getItemReleaseHistory('the-item'),
        throwsA(isA<NotFoundError>()),
        reason: 'getItemReleaseHistory for unknown key "the-item" must throw NotFoundError',
      );
    });
  });

  group('Get elements for charts', () {
    test('valid versions', () {
      final versions = service.getBannerHistoryVersions(SortDirectionType.asc);
      final expectedLength = ElementType.values.length;

      final elements = service.getElementsForCharts(versions.first, versions.last);
      expect(
        elements.length,
        expectedLength,
        reason: 'Elements-for-charts must return one series per ElementType ($expectedLength), got ${elements.length}',
      );
      expect(
        elements.map((el) => el.type).toSet().length,
        expectedLength,
        reason: 'Elements-for-charts contain duplicate element types (expected $expectedLength distinct)',
      );

      for (final element in elements) {
        expect(element.points.isNotEmpty, isTrue, reason: 'Element ${element.type} chart series has no points');

        for (final point in element.points) {
          expect(
            point.y,
            greaterThanOrEqualTo(0),
            reason: 'Chart point y must be >= 0, got ${point.y} (element=${element.type})',
          );
        }
      }
    });

    test('invalid from version', () {
      expect(
        () => service.getElementsForCharts(-1, 2.1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'fromVersion')),
        reason: 'getElementsForCharts with negative from must throw ArgumentError(name: fromVersion)',
      );
    });

    test('invalid until version', () {
      expect(
        () => service.getElementsForCharts(1, -1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'untilVersion')),
        reason: 'getElementsForCharts with negative until must throw ArgumentError(name: untilVersion)',
      );
    });
  });

  group('Get top charts', () {
    test('no items were provided', () {
      expect(
        () => service.getTopCharts(true, ChartType.characterBirthdays, BannerHistoryItemType.character, []),
        throwsA(isA<UnsupportedError>()),
        reason: 'getTopCharts with an empty item list must throw UnsupportedError',
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
          }

          final charts = service.getTopCharts(mostReruns, chartType, bannerItemType, data);
          expect(
            charts,
            isNotEmpty,
            reason: 'No top-chart data for bannerItemType=${bannerItemType.name}, chartType=${chartType.name}',
          );
          for (final chart in charts) {
            checkKey(chart.key, ownerKey: chart.key);
            checkTranslation(chart.name, ownerKey: chart.key);
            expect(
              data.any((el) => el.key == chart.key),
              isTrue,
              reason: 'Top-chart entry "${chart.key}" is not present in the source data set',
            );
            expect(chart.value, greaterThan(0), reason: 'Top-chart value must be > 0, got ${chart.value} (key=${chart.key})');
            expect(
              chart.percentage,
              inExclusiveRange(0, 100),
              reason: 'Top-chart percentage must be between 0 and 100 (exclusive), got ${chart.percentage} (key=${chart.key})',
            );
            expect(
              chart.type,
              chartType,
              reason: 'Top-chart entry type ${chart.type} != requested ${chartType.name} (key=${chart.key})',
            );
          }
        });
      }
    }
  });

  group('Get wish simulator banner per period', () {
    test('invalid version', () {
      expect(
        () => service.getWishSimulatorBannerPerPeriod(0, DateTime.now(), DateTime.now()),
        throwsA(predicate<ArgumentError>((e) => e.name == 'version')),
        reason: 'getWishSimulatorBannerPerPeriod(0, ...) must throw ArgumentError(name: version)',
      );
    });

    test('invalid date range', () {
      expect(
        () => service.getWishSimulatorBannerPerPeriod(0, DateTime.now().add(const Duration(days: 1)), DateTime.now()),
        throwsA(predicate<ArgumentError>((e) => e.name == 'version')),
        reason: 'getWishSimulatorBannerPerPeriod with from after until must throw ArgumentError(name: version)',
      );
    });

    test('no data exist', () {
      expect(
        () => service.getWishSimulatorBannerPerPeriod(
          0.5,
          DateTime.now(),
          DateTime.now().add(const Duration(days: 30)),
        ),
        throwsA(predicate<RangeError>((e) => e.toString().toLowerCase().contains('is not valid'))),
        reason: 'getWishSimulatorBannerPerPeriod for version 0.5 with no data must throw RangeError ("is not valid")',
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

      expect(bannersPerPeriod.from == from, isTrue, reason: 'Returned banner period "from" ${bannersPerPeriod.from} != requested $from');
      expect(bannersPerPeriod.until == until, isTrue, reason: 'Returned banner period "until" ${bannersPerPeriod.until} != requested $until');
      expect(
        bannersPerPeriod.version == version,
        isTrue,
        reason: 'Returned banner period version ${bannersPerPeriod.version} != requested $version',
      );
      expect(bannersPerPeriod.banners, isNotEmpty, reason: 'Banner period for version $version has no banners');
      for (final b in bannersPerPeriod.banners) {
        checkWishBannerItemModel(b, featuredItemKeys);
      }
    });
  });

  test('Get wish banners history grouped by version', () {
    final grouped = service.getWishBannersHistoryGroupedByVersion();
    for (final g in grouped) {
      expect(g.parts, isNotEmpty, reason: 'Grouped wish-banner version "${g.groupingKey}" has no parts');
      expect(
        g.groupingKey == g.groupingTitle,
        isTrue,
        reason: 'Grouping key "${g.groupingKey}" != grouping title "${g.groupingTitle}"',
      );

      final version = g.parts.first.version;
      for (final part in g.parts) {
        checkAssets(part.bannerImages);
        expect(part.version == version, isTrue, reason: 'Part version ${part.version} != group version $version');

        expect(
          part.featuredCharacters.map((e) => e.key).toSet().length,
          part.featuredCharacters.length,
          reason: 'Featured characters contain duplicate keys (version=$version)',
        );
        expect(
          part.featuredCharacters.length,
          greaterThanOrEqualTo(4),
          reason: 'Version $version must feature >= 4 characters, got ${part.featuredCharacters.length}',
        );
        for (final char in part.featuredCharacters) {
          checkItemKeyAndName(char.key, char.name);
        }

        expect(
          part.featuredWeapons.map((e) => e.key).toSet().length,
          part.featuredWeapons.length,
          reason: 'Featured weapons contain duplicate keys (version=$version)',
        );
        expect(
          part.featuredWeapons.length,
          greaterThanOrEqualTo(4),
          reason: 'Version $version must feature >= 4 weapons, got ${part.featuredWeapons.length}',
        );
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
