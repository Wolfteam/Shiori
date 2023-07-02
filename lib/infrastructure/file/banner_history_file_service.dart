import 'dart:math';

import 'package:collection/collection.dart';
import 'package:darq/darq.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/datetime_extensions.dart';
import 'package:shiori/domain/extensions/double_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/domain/services/resources_service.dart';

const int promotedRarity = 5;

class BannerHistoryFileServiceImpl extends BannerHistoryFileService {
  final ResourceService _resourceService;
  final CharacterFileService _characters;
  final WeaponFileService _weapons;

  late BannerHistoryFile _bannerHistoryFile;

  @override
  ResourceService get resources => _resourceService;

  @override
  TranslationFileService get translations => throw UnimplementedError('Translations are not required in this file');

  BannerHistoryFileServiceImpl(this._resourceService, this._characters, this._weapons);

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
                  imagePath = _resourceService.getCharacterImagePath(character.image);
                  type = ItemType.character;
                  break;
                case BannerHistoryItemType.weapon:
                  final weapon = _weapons.getWeapon(key);
                  rarity = weapon.rarity;
                  imagePath = _resourceService.getWeaponImagePath(weapon.image, weapon.type);
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

    final elements = ElementType.values.toList()..sort((x, y) => x.index.compareTo(y.index));
    double from = fromVersion;
    for (final element in elements) {
      final points = <Point<double>>[];
      while (from <= untilVersion) {
        final point = Point<double>(from, 0);
        points.add(point);
        from = (from + gameVersionIncrementsBy).truncateToDecimalPlaces();
      }
      final item = ChartElementItemModel(type: element, points: points);
      charts.add(item);
      from = fromVersion;
    }

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
        final existing = charts.firstWhere((el) => el.type == char.elementType);
        final points = [...existing.points];
        final existingPoint = points.firstWhereOrNull((el) => el.x == banner.version);
        final newPoint = existingPoint != null
            ? Point<double>(existingPoint.x, (existingPoint.y + incrementY).truncateToDecimalPlaces())
            : Point<double>(banner.version, incrementY);

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

    assert(charts.isNotEmpty, 'Element chart items must not be empty');
    return charts;
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

  @override
  WishBannerItemsPerPeriodModel getWishBannerPerPeriod(double version, DateTime from, DateTime until) {
    final banners = _bannerHistoryFile.banners
        .where((el) => el.version == version && el.from.isAfterInclusive(from) && el.until.isBeforeInclusive(until))
        .mapIndexed((index, e) {
      final characters = <WishBannerCharacterModel>[];
      final weapons = <WishBannerWeaponModel>[];
      final promoted = <ItemCommon>[];
      for (final key in e.itemKeys) {
        switch (e.type) {
          case BannerHistoryItemType.character:
            final character = _characters.getCharacter(key);
            final imagePath = _resourceService.getCharacterIconImagePath(character.iconImage);
            characters.add(WishBannerCharacterModel(key: key, image: imagePath, elementType: character.elementType, rarity: character.rarity));
            if (character.rarity == promotedRarity) {
              promoted.add(ItemCommon(key, imagePath));
            }
            break;
          case BannerHistoryItemType.weapon:
            final weapon = _weapons.getWeapon(key);
            final imagePath = _resourceService.getWeaponImagePath(weapon.image, weapon.type);
            weapons.add(WishBannerWeaponModel(key: key, rarity: weapon.rarity, image: imagePath));
            if (weapon.rarity == promotedRarity) {
              promoted.add(ItemCommon(key, imagePath));
            }
            break;
        }
      }

      return WishBannerItemModel(
        type: BannerItemType.values[e.type.index],
        image: _resourceService.getWishBannerHistoryImagePath(e.imageFilename),
        characters: characters,
        weapons: weapons,
        promotedItems: promoted,
      );
    }).toList();

    return WishBannerItemsPerPeriodModel(
      from: from,
      until: until,
      version: version,
      banners: banners..sort((x, y) => x.type.index.compareTo(y.type.index)),
    );
  }

  Tuple2<List<ItemCommonWithNameOnly>, List<ItemCommonWithNameOnly>> _getPromotedItemsFromBannerPeriod(
    BannerHistoryPeriodFileModel period,
    List<ItemCommonWithName> promotedItems,
  ) {
    final promotedCharacters = <ItemCommonWithNameOnly>[];
    final promotedWeapons = <ItemCommonWithNameOnly>[];
    for (final key in period.itemKeys) {
      switch (period.type) {
        case BannerHistoryItemType.character:
          final character = promotedItems.firstWhereOrNull((el) => el.key == key);
          if (character != null) {
            promotedCharacters.add(ItemCommonWithNameOnly(key, character.name));
          }
          break;
        case BannerHistoryItemType.weapon:
          final weapon = promotedItems.firstWhereOrNull((el) => el.key == key);
          if (weapon != null) {
            promotedWeapons.add(ItemCommonWithNameOnly(key, weapon.name));
          }
          break;
      }
    }

    return Tuple2<List<ItemCommonWithNameOnly>, List<ItemCommonWithNameOnly>>(promotedCharacters, promotedWeapons);
  }

  @override
  List<WishBannerHistoryGroupedPeriodModel> getWishBannersHistoryGroupedByVersion() {
    final possiblePromotedItems = _characters
        .getItemCommonWithNameByRarity(promotedRarity)
        .concat(
          _weapons.getItemCommonWithNameByRarity(promotedRarity),
        )
        .toList();
    final grouped = _bannerHistoryFile.banners.groupListsBy((el) => el.version).entries.map((versionGroup) {
      final parts = <WishBannerHistoryPartItemModel>[];
      final groupedChars = versionGroup.value
          .where((el) => el.type == BannerHistoryItemType.character)
          .orderBy((el) => el.from)
          .groupListsBy((el) => '${el.from}_${el.until}')
          .entries
          .toList();
      final groupedWeapons = versionGroup.value
          .where((el) => el.type == BannerHistoryItemType.weapon)
          .orderBy((el) => el.from)
          .groupListsBy((el) => '${el.from}_${el.until}')
          .entries
          .toList();
      for (int i = 0; i < groupedChars.length; i++) {
        final groupedCharPeriod = groupedChars[i].value.first;
        for (int j = 0; j < groupedWeapons.length; j++) {
          final groupedWeaponPeriod = groupedWeapons[j].value.first;
          final overlap = groupedCharPeriod.from.isBefore(groupedWeaponPeriod.until) && groupedCharPeriod.until.isAfter(groupedWeaponPeriod.from);
          if (!overlap) {
            continue;
          }
          final from = groupedCharPeriod.from.isAfterInclusive(groupedWeaponPeriod.from) ? groupedCharPeriod.from : groupedWeaponPeriod.from;
          final until = groupedCharPeriod.until.isBeforeInclusive(groupedWeaponPeriod.until) ? groupedCharPeriod.until : groupedWeaponPeriod.until;
          final part = WishBannerHistoryPartItemModel(
            promotedCharacters: groupedChars[i]
                .value
                .map((period) => _getPromotedItemsFromBannerPeriod(period, possiblePromotedItems).item0)
                .selectMany((element, index) => element)
                .toList(),
            promotedWeapons: groupedWeapons[j]
                .value
                .map((period) => _getPromotedItemsFromBannerPeriod(period, possiblePromotedItems).item1)
                .selectMany((element, index) => element)
                .toList(),
            bannerImages: groupedChars[i]
                .value
                .map((e) => _resourceService.getWishBannerHistoryImagePath(e.imageFilename))
                .concat(groupedWeapons[j].value.map((e) => _resourceService.getWishBannerHistoryImagePath(e.imageFilename)))
                .toList(),
            from: from,
            until: until,
            version: versionGroup.key,
          );
          parts.add(part);
        }
      }

      return WishBannerHistoryGroupedPeriodModel(groupingTitle: versionGroup.key.toString(), parts: parts);
    }).toList();

    return grouped;
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
