import 'dart:math';

import 'package:collection/collection.dart';
import 'package:darq/darq.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/extensions/datetime_extensions.dart';
import 'package:shiori/domain/extensions/double_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/wish_banner_constants.dart';

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
  Future<void> init(String assetPath, {bool noResourcesHaveBeenDownloaded = false}) async {
    if (noResourcesHaveBeenDownloaded) {
      _bannerHistoryFile = const BannerHistoryFile(banners: []);
      return;
    }
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
                iconImage: char.iconImage,
                name: char.name,
                key: key,
                type: banner.type,
                rarity: char.stars,
              );
              banners.add(item);
            }
          case BannerHistoryItemType.weapon:
            if (!alreadyAdded) {
              final weapon = _weapons.getWeaponForCard(key);
              final bannerItem = BannerHistoryItemModel(
                versions: [],
                image: weapon.image,
                iconImage: weapon.image,
                name: weapon.name,
                key: key,
                type: banner.type,
                rarity: weapon.rarity,
              );
              banners.add(bannerItem);
            }
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
      throw ArgumentError.value(version, 'version');
    }
    final banners =
        _bannerHistoryFile.banners
            .where((el) => el.version == version)
            .map(
              (e) => BannerHistoryPeriodModel(
                from: e.from,
                until: e.until,
                type: e.type,
                version: e.version,
                items: e.itemKeys.map((key) {
                  String? imagePath;
                  String? iconImagePath;
                  int? rarity;
                  ItemType? type;
                  switch (e.type) {
                    case BannerHistoryItemType.character:
                      final character = _characters.getCharacter(key);
                      rarity = character.rarity;
                      imagePath = _resourceService.getCharacterImagePath(character.image);
                      iconImagePath = _resourceService.getCharacterIconImagePath(character.iconImage);
                      type = ItemType.character;
                    case BannerHistoryItemType.weapon:
                      final weapon = _weapons.getWeapon(key);
                      rarity = weapon.rarity;
                      imagePath = iconImagePath = _resourceService.getWeaponImagePath(weapon.image, weapon.type);
                      type = ItemType.weapon;
                  }
                  return ItemCommonWithRarityAndType(key, imagePath, iconImagePath, rarity, type);
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
        .map(
          (e) => ItemReleaseHistoryModel(
            version: e.version,
            dates: [ItemReleaseHistoryDatesModel(from: e.from, until: e.until)],
          ),
        )
        .toList();

    if (history.isEmpty) {
      throw NotFoundError(itemKey, 'itemKey', 'No banner history found');
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
    }).toList()..sort((x, y) => x.version.compareTo(y.version));
  }

  @override
  List<ChartElementItemModel> getElementsForCharts(double fromVersion, double untilVersion) {
    final allVersions = getBannerHistoryVersions(SortDirectionType.asc);
    if (fromVersion < allVersions.first || fromVersion > allVersions.last) {
      throw ArgumentError.value(fromVersion, 'fromVersion');
    }

    if (untilVersion > allVersions.last || untilVersion < allVersions.first) {
      throw ArgumentError.value(untilVersion, 'untilVersion');
    }

    if (fromVersion > untilVersion) {
      throw RangeError('The fromVersion = $fromVersion cannot be greater than untilVersion = $untilVersion');
    }

    final banners =
        _bannerHistoryFile.banners
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
        final characterAlreadyAppearedInThisBanner = usedChars.entries.any(
          (el) => el.key == banner.version && el.value.contains(key),
        );
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
  List<ChartTopItemModel> getTopCharts(
    bool mostReruns,
    ChartType type,
    BannerHistoryItemType bannerType,
    List<ItemCommonWithName> items,
  ) {
    if (items.isEmpty) {
      throw UnsupportedError('Items cannot be empty');
    }

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

          return ItemCommonWithQuantity(key, element.image, element.image, count);
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
  WishSimulatorBannerItemsPerPeriodModel getWishSimulatorBannerPerPeriod(double version, DateTime from, DateTime until) {
    if (version <= 0) {
      throw RangeError.range(version, 1, null, 'version');
    }

    if (until.difference(from).inDays < 0) {
      throw RangeError('The provided date range, from = $from and until = $until are not valid');
    }

    final otherCharacters = _characters
        .getCharactersForCard()
        .where(
          (el) =>
              !el.isComingSoon &&
                  !el.isNew &&
                  !WishBannerConstants.fourStarStandardBannerCharacterExclusiveKeys.contains(el.key) &&
                  el.stars == 4 ||
              WishBannerConstants.commonFiveStarCharacterKeys.contains(el.key),
        )
        .map((el) {
          final character = _characters.getCharacter(el.key);
          final imagePath = _resourceService.getCharacterImagePath(character.image);
          final iconImgPath = _resourceService.getCharacterImagePath(character.iconImage);
          return WishSimulatorBannerCharacterModel(
            key: el.key,
            image: imagePath,
            iconImage: iconImgPath,
            rarity: character.rarity,
            elementType: character.elementType,
          );
        })
        .toList();
    final otherWeapons = _weapons.getWeaponsForCard().where((el) => WishBannerConstants.commonWeaponKeys.contains(el.key)).map((
      el,
    ) {
      final weapon = _weapons.getWeapon(el.key);
      final imagePath = _resourceService.getWeaponImagePath(weapon.image, weapon.type);
      return WishSimulatorBannerWeaponModel(
        key: el.key,
        rarity: weapon.rarity,
        image: imagePath,
        iconImage: imagePath,
        weaponType: el.type,
      );
    }).toList();

    final banners = <WishSimulatorBannerItemModel>[];
    final bannerPeriods = _bannerHistoryFile.banners.where((el) => el.version == version).toList();
    for (final BannerHistoryPeriodFileModel period in bannerPeriods) {
      final overlap = period.from.isBefore(until) && period.until.isAfter(from);
      if (!overlap) {
        continue;
      }

      final characters = <WishSimulatorBannerCharacterModel>[];
      final weapons = <WishSimulatorBannerWeaponModel>[];
      final featured = <WishSimulatorBannerFeaturedItemModel>[];
      for (final key in period.itemKeys) {
        switch (period.type) {
          case BannerHistoryItemType.character:
            final character = _characters.getCharacter(key);
            final imagePath = _resourceService.getCharacterImagePath(character.image);
            final iconImagePath = _resourceService.getCharacterIconImagePath(character.iconImage);
            characters.add(
              WishSimulatorBannerCharacterModel(
                key: key,
                image: imagePath,
                iconImage: iconImagePath,
                rarity: character.rarity,
                elementType: character.elementType,
              ),
            );
            featured.add(
              WishSimulatorBannerFeaturedItemModel(
                key: key,
                iconImage: iconImagePath,
                rarity: character.rarity,
                type: ItemType.character,
              ),
            );
          case BannerHistoryItemType.weapon:
            final weapon = _weapons.getWeapon(key);
            final imagePath = _resourceService.getWeaponImagePath(weapon.image, weapon.type);
            weapons.add(
              WishSimulatorBannerWeaponModel(
                key: key,
                rarity: weapon.rarity,
                image: imagePath,
                iconImage: imagePath,
                weaponType: weapon.type,
              ),
            );
            featured.add(
              WishSimulatorBannerFeaturedItemModel(key: key, iconImage: imagePath, rarity: weapon.rarity, type: ItemType.weapon),
            );
        }
      }

      final otherCharactersForThisBanner = period.type == BannerHistoryItemType.character
          ? otherCharacters
          : otherCharacters.where((el) => el.rarity != WishBannerConstants.maxObtainableRarity).toList();

      final otherWeaponsForThisBanner = period.type == BannerHistoryItemType.weapon
          ? otherWeapons
          : otherWeapons.where((el) => el.rarity != WishBannerConstants.maxObtainableRarity).toList();

      for (final char in otherCharactersForThisBanner) {
        final alreadyAdded = characters.any((el) => el.key == char.key);
        if (alreadyAdded) {
          continue;
        }
        characters.add(char);
      }

      for (final weapon in otherWeaponsForThisBanner) {
        final alreadyAdded = weapons.any((el) => el.key == weapon.key);
        if (alreadyAdded) {
          continue;
        }

        weapons.add(weapon);
      }

      final bannerItem = WishSimulatorBannerItemModel(
        type: BannerItemType.values[period.type.index],
        image: _resourceService.getWishBannerHistoryImagePath(period.imageFilename),
        characters: characters,
        weapons: weapons,
        featuredItems: featured,
      );
      banners.add(bannerItem);
    }

    if (banners.isEmpty) {
      throw RangeError('Either version = $version, from = $from or until = $until is not valid');
    }

    banners.add(getWishSimulatorStandardBanner());

    return WishSimulatorBannerItemsPerPeriodModel(
      from: from,
      until: until,
      version: version,
      banners: banners..sort((x, y) => x.type.index.compareTo(y.type.index)),
    );
  }

  @override
  List<WishBannerHistoryGroupedPeriodModel> getWishBannersHistoryGroupedByVersion() {
    final possiblePromotedItems = _characters
        .getCharactersForCard()
        .map((e) => ItemCommonWithNameAndRarity(e.key, e.name, e.stars))
        .concat(_weapons.getWeaponsForCard().map((e) => ItemCommonWithNameAndRarity(e.key, e.name, e.rarity)))
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
          final overlap =
              groupedCharPeriod.from.isBefore(groupedWeaponPeriod.until) &&
              groupedCharPeriod.until.isAfter(groupedWeaponPeriod.from);
          if (!overlap) {
            continue;
          }
          final from = groupedCharPeriod.from.isAfterInclusive(groupedWeaponPeriod.from)
              ? groupedCharPeriod.from
              : groupedWeaponPeriod.from;
          final until = groupedCharPeriod.until.isBeforeInclusive(groupedWeaponPeriod.until)
              ? groupedCharPeriod.until
              : groupedWeaponPeriod.until;
          final part = WishBannerHistoryPartItemModel(
            featuredCharacters: groupedChars[i].value
                .map((period) => _getFeaturedItemsFromBannerPeriod(period, possiblePromotedItems).item0)
                .selectMany((el, index) => el)
                .groupBy((el) => el.key)
                .map((e) => e.first)
                .toList(),
            featuredWeapons: groupedWeapons[j].value
                .map((period) => _getFeaturedItemsFromBannerPeriod(period, possiblePromotedItems).item1)
                .selectMany((el, index) => el)
                .groupBy((el) => el.key)
                .map((e) => e.first)
                .toList(),
            bannerImages: groupedChars[i].value
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

      final key = versionGroup.key.toString();
      return WishBannerHistoryGroupedPeriodModel(groupingKey: key, groupingTitle: key, parts: parts);
    }).toList();

    return grouped;
  }

  @override
  WishSimulatorBannerItemModel getWishSimulatorStandardBanner() {
    final characters = _characters
        .getCharactersForCard()
        .where(
          (el) =>
              !el.isComingSoon && !el.isNew && el.stars == 4 || WishBannerConstants.commonFiveStarCharacterKeys.contains(el.key),
        )
        .map(
          (el) => WishSimulatorBannerCharacterModel(
            key: el.key,
            rarity: el.stars,
            image: el.image,
            iconImage: el.iconImage,
            elementType: el.elementType,
          ),
        )
        .toList();
    final weapons = _weapons
        .getWeaponsForCard()
        .where((el) => WishBannerConstants.commonWeaponKeys.contains(el.key))
        .map(
          (el) => WishSimulatorBannerWeaponModel(
            key: el.key,
            rarity: el.rarity,
            image: el.image,
            iconImage: el.image,
            weaponType: el.type,
          ),
        )
        .toList();

    return WishSimulatorBannerItemModel(
      type: BannerItemType.standard,
      image: Assets.wishBannerStandardImgPath,
      featuredItems: [],
      characters: characters,
      weapons: weapons,
    );
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

  Tuple2<List<ItemCommonWithNameAndRarity>, List<ItemCommonWithNameAndRarity>> _getFeaturedItemsFromBannerPeriod(
    BannerHistoryPeriodFileModel period,
    List<ItemCommonWithNameAndRarity> possiblePromotedItems,
  ) {
    final characters = <ItemCommonWithNameAndRarity>[];
    final weapons = <ItemCommonWithNameAndRarity>[];
    for (final key in period.itemKeys) {
      switch (period.type) {
        case BannerHistoryItemType.character:
          final character = possiblePromotedItems.firstWhereOrNull((el) => el.key == key);
          if (character != null && !characters.any((el) => el.key == key)) {
            characters.add(ItemCommonWithNameAndRarity(key, character.name, character.rarity));
          }
        case BannerHistoryItemType.weapon:
          final weapon = possiblePromotedItems.firstWhereOrNull((el) => el.key == key);
          if (weapon != null && !weapons.any((el) => el.key == key)) {
            weapons.add(ItemCommonWithNameAndRarity(key, weapon.name, weapon.rarity));
          }
      }
    }

    return Tuple2<List<ItemCommonWithNameAndRarity>, List<ItemCommonWithNameAndRarity>>(characters, weapons);
  }
}
