import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';

import '../../common.dart';
import 'common_file.dart';

//TODO: ADD TEST FOR FAIL CASES (E.G WEAPON NOT FOUND, IMAGE NOT FOUND ETC)

void main() {
  late final BannerHistoryFileService _service;

  setUpAll(() {
    return Future(() async {
      _service = await getBannerHistoryFileService(AppLanguageType.english);
    });
  });

  test('Get banner history', () async {
    for (final type in BannerHistoryItemType.values) {
      final banners = _service.getBannerHistory(type);
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
      final versions = _service.getBannerHistoryVersions(SortDirectionType.asc);
      expect(versions.length, versions.toSet().length);

      final validItemTypes = [ItemType.character, ItemType.weapon];
      for (final version in versions) {
        final banners = _service.getBanners(version);
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
      final banners = _service.getBanners(1.7);
      expect(banners.isEmpty, isTrue);
    });

    test('invalid version', () async {
      expect(() => _service.getBanners(0.1), throwsA(isA<Exception>()));
    });
  });

  group('Get item release history', () {
    test('item exists', () async {
      final history = _service.getItemReleaseHistory('keqing');
      expect(history.isNotEmpty, isTrue);

      for (final item in history) {
        expect(item.dates.isNotEmpty, isTrue);
        expect(item.version >= 1, isTrue);
      }
    });

    test('item does not exist', () async {
      expect(() => _service.getItemReleaseHistory('the-item'), throwsA(isA<Exception>()));
    });
  });

  group('Get elements for charts', () {
    test('valid versions', () async {
      final versions = _service.getBannerHistoryVersions(SortDirectionType.asc);
      final expectedLength = ElementType.values.length - 1;

      final elements = _service.getElementsForCharts(versions.first, versions.last);
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
      expect(() => _service.getElementsForCharts(-1, 2.1), throwsA(isA<Exception>()));
    });

    test('invalid until version', () async {
      expect(() => _service.getElementsForCharts(1, -1), throwsA(isA<Exception>()));
    });
  });
}
