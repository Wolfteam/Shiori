import 'dart:math';

import 'package:collection/collection.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/double_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';

class BannerHistoryFileServiceImpl extends BannerHistoryFileService {
  final CharacterFileService _characters;
  final WeaponFileService _weapons;

  late BannerHistoryFile _bannerHistoryFile;

  BannerHistoryFileServiceImpl(this._characters, this._weapons);

  @override
  Future<void> init(String assetPath) async {
    final json = await readJson(assetPath);
    _bannerHistoryFile = BannerHistoryFile.fromJson(json);
  }

  @override
  List<double> getBannerHistoryVersions(SortDirectionType type) {
    final versions = _bannerHistoryFile.banners.map((el) => el.version).toSet().toList();
    switch (type) {
      case SortDirectionType.asc:
        return versions..sort((x, y) => x.compareTo(y));
      case SortDirectionType.desc:
        return versions..sort((x, y) => y.compareTo(x));
    }
  }

  @override
  List<BannerHistoryItemModel> getBannerHistory(BannerHistoryItemType type) {
    final banners = <BannerHistoryItemModel>[];
    final itemVersionsMap = <String, List<double>>{};
    final allVersions = getBannerHistoryVersions(SortDirectionType.asc);
    final filteredBanners = _bannerHistoryFile.banners.where((el) => el.type == type).toList();

    for (final banner in filteredBanners) {
      for (final key in banner.itemKeys) {
        final alreadyAdded = banners.any((el) => el.key == key);
        switch (banner.type) {
          case BannerHistoryItemType.character:
            if (!alreadyAdded) {
              final char = _characters.getCharacterForCard(key);
              final item = BannerHistoryItemModel(
                versions: [],
                image: char.image,
                name: char.name,
                key: key,
                type: banner.type,
                rarity: char.stars,
              );
              banners.add(item);
            }
            break;
          case BannerHistoryItemType.weapon:
            if (!alreadyAdded) {
              final weapon = _weapons.getWeaponForCard(key);
              final bannerItem = BannerHistoryItemModel(
                versions: [],
                image: weapon.image,
                name: weapon.name,
                key: key,
                type: banner.type,
                rarity: weapon.rarity,
              );
              banners.add(bannerItem);
            }
            break;
          default:
            throw Exception('The provided banner type = ${banner.type} is not mapped');
        }

        if (!alreadyAdded) {
          itemVersionsMap[key] = [banner.version];
        } else {
          itemVersionsMap.update(key, (value) => [...value, banner.version]);
        }
      }
    }

    for (var i = 0; i < banners.length; i++) {
      final current = banners[i];
      final values = itemVersionsMap.entries.firstWhere((el) => el.key == current.key).value;
      final updated = current.copyWith.call(versions: _getBannerVersionsForItem(allVersions, values));
      banners.removeAt(i);
      banners.insert(i, updated);
    }

    return banners;
  }

  @override
  List<BannerHistoryPeriodModel> getBanners(double version) {
    if (version < getBannerHistoryVersions(SortDirectionType.asc).first) {
      throw Exception('Version = $version is not valid');
    }
    final banners = _bannerHistoryFile.banners
        .where((el) => el.version == version)
        .map(
          (e) => BannerHistoryPeriodModel(
            from: e.from,
            until: e.until,
            type: e.type,
            version: e.version,
            items: e.itemKeys.map((key) {
              String? imagePath;
              int? rarity;
              ItemType? type;
              switch (e.type) {
                case BannerHistoryItemType.character:
                  final character = _characters.getCharacter(key);
                  rarity = character.rarity;
                  imagePath = character.fullImagePath;
                  type = ItemType.character;
                  break;
                case BannerHistoryItemType.weapon:
                  final weapon = _weapons.getWeapon(key);
                  rarity = weapon.rarity;
                  imagePath = weapon.fullImagePath;
                  type = ItemType.weapon;
                  break;
                default:
                  throw Exception('Banner history item type = ${e.type} is not valid');
              }
              return ItemCommonWithRarityAndType(key, imagePath, rarity, type);
            }).toList(),
          ),
        )
        .toList()
      ..sort((x, y) => x.from.compareTo(y.from));

    return banners;
  }

  @override
  List<ItemReleaseHistoryModel> getItemReleaseHistory(String itemKey) {
    final history = _bannerHistoryFile.banners
        .where((el) => el.itemKeys.contains(itemKey))
        .map((e) => ItemReleaseHistoryModel(version: e.version, dates: [ItemReleaseHistoryDatesModel(from: e.from, until: e.until)]))
        .toList();

    if (history.isEmpty) {
      throw Exception('There is no banner history associated to itemKey = $itemKey');
    }
    return history.groupListsBy((el) => el.version).entries.map((e) {
      //with the multi banners, we need to group the dates to avoid showing up repeated ones
      final dates = e.value
          .expand((el) => el.dates)
          .groupListsBy((d) => '${d.from}__${d.until}')
          .values
          .map((e) => ItemReleaseHistoryDatesModel(from: e.first.from, until: e.first.until))
          .toList();
      return ItemReleaseHistoryModel(version: e.key, dates: dates);
    }).toList()
      ..sort((x, y) => x.version.compareTo(y.version));
  }

  @override
  List<ChartElementItemModel> getElementsForCharts(double fromVersion, double untilVersion) {
    final allVersions = getBannerHistoryVersions(SortDirectionType.asc);
    if (fromVersion < allVersions.first) {
      throw Exception('The fromVersion = $fromVersion is not valid');
    }

    if (untilVersion > allVersions.last) {
      throw Exception('The untilVersion = $untilVersion is not valid');
    }

    if (fromVersion > untilVersion) {
      throw Exception('The fromVersion = $fromVersion cannot be greater than untilVersion = $untilVersion');
    }

    final banners = _bannerHistoryFile.banners
        .where((el) => el.type == BannerHistoryItemType.character && el.version >= fromVersion && el.version <= untilVersion)
        .toList()
      ..sort((x, y) => x.version.compareTo(y.version));
    final charts = <ChartElementItemModel>[];
    final characters = _characters.getCharactersForCard();
    final usedChars = <double, List<String>>{};
    const double incrementY = 1;

    for (final banner in banners) {
      for (final key in banner.itemKeys) {
        final bannerHasAlreadyBeenAdded = usedChars.containsKey(banner.version);
        final characterAlreadyAppearedInThisBanner = usedChars.entries.any((el) => el.key == banner.version && el.value.contains(key));
        if (!bannerHasAlreadyBeenAdded) {
          usedChars.putIfAbsent(banner.version, () => [key]);
        } else if (characterAlreadyAppearedInThisBanner) {
          continue;
        } else {
          usedChars.update(banner.version, (value) => [...value, key]);
        }

        final char = characters.firstWhere((el) => el.key == key);
        final existing = charts.firstWhereOrNull((el) => el.type == char.elementType);
        final points = existing?.points ?? [];
        final existingPoint = points.firstWhereOrNull((el) => el.x == banner.version);
        final newPoint = existingPoint != null
            ? Point<double>(existingPoint.x, (existingPoint.y + incrementY).truncateToDecimalPlaces())
            : Point<double>(banner.version, incrementY);

        if (existing == null) {
          final newItem = ChartElementItemModel(type: char.elementType, points: [newPoint]);
          charts.add(newItem);
          continue;
        }

        if (existingPoint != null) {
          final index = points.indexOf(existingPoint);
          points.removeAt(index);
          points.insert(index, newPoint);
        } else {
          points.add(newPoint);
        }
        final updated = existing.copyWith.call(points: points);
        final index = charts.indexOf(existing);
        charts.removeAt(index);
        charts.insert(index, updated);
      }
    }

    double from = fromVersion;
    while (from <= untilVersion) {
      for (final chart in charts) {
        if (!chart.points.any((el) => el.x == from)) {
          chart.points.add(Point<double>(from, 0));
        }
      }
      from = (from + gameVersionIncrementsBy).truncateToDecimalPlaces();
    }

    for (final chart in charts) {
      chart.points.sort((x, y) => x.x.compareTo(y.x));
    }

    assert(charts.isNotEmpty, 'Element chart items must not be empty');

    return charts..sort((x, y) => x.type.index.compareTo(y.type.index));
  }

  @override
  List<ChartTopItemModel> getTopCharts(bool mostReruns, ChartType type, BannerHistoryItemType bannerType, List<ItemCommonWithName> items) {
    final selected = _bannerHistoryFile.banners
        .where((el) => el.type == bannerType)
        .expand((el) => el.itemKeys)
        .toSet()
        .map((key) {
          final element = items.firstWhereOrNull((el) => el.key == key);
          if (element == null) {
            return null;
          }

          //with the multi banners, we need to group the dates to avoid showing up repeated ones
          final count = _bannerHistoryFile.banners
              .where((el) => el.type == bannerType && el.itemKeys.contains(key))
              .groupListsBy((d) => '${d.from}__${d.until}')
              .length;

          return ItemCommonWithQuantity(key, element.image, count);
        })
        .where((el) => el != null)
        .map((e) => e!)
        .toList();

    if (mostReruns) {
      selected.sort((x, y) => y.quantity.compareTo(x.quantity));
    } else {
      selected.sort((x, y) => x.quantity.compareTo(y.quantity));
    }

    assert(selected.isNotEmpty, 'The selected item list should not be empty');
    assert(selected.length >= 5, 'There should be at least 5 top items');

    final tops = selected.take(5).toList();
    final total = tops.map((e) => e.quantity).sum;

    return tops
        .map(
          (e) => ChartTopItemModel(
            key: e.key,
            name: items.firstWhere((el) => el.key == e.key).name,
            type: type,
            value: e.quantity,
            percentage: (e.quantity * 100 / total).truncateToDecimalPlaces(fractionalDigits: 2),
          ),
        )
        .toList();
  }

  List<BannerHistoryItemVersionModel> _getBannerVersionsForItem(List<double> allVersions, List<double> releasedOn) {
    final history = <BannerHistoryItemVersionModel>[];
    int number = 0;
    for (var i = 0; i < allVersions.length; i++) {
      final current = allVersions[i];
      final released = releasedOn.contains(current);
      final notReleasedYet = releasedOn.every((e) => current < e);
      if (notReleasedYet) {
        history.add(BannerHistoryItemVersionModel(version: current, number: 0, released: false));
      } else if (!released) {
        number++;
        history.add(BannerHistoryItemVersionModel(version: current, number: number, released: false));
      } else {
        history.add(BannerHistoryItemVersionModel(version: current, released: true));
        number = 0;
      }
    }
    return history;
  }
}
