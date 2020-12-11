import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/enums/artifact_filter_type.dart';
import '../../common/enums/character_filter_type.dart';
import '../../common/enums/element_type.dart';
import '../../common/enums/item_location_type.dart';
import '../../common/enums/released_unreleased_type.dart';
import '../../common/enums/sort_direction_type.dart';
import '../../common/enums/stat_type.dart';
import '../../common/enums/weapon_filter_type.dart';
import '../../common/enums/weapon_type.dart';
import '../../generated/l10n.dart';

extension I18nExtensions on S {
  String translateAppThemeType(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.dark:
        return dark;
      case AppThemeType.light:
        return light;
      default:
        throw Exception('The provided app theme = $theme is not valid');
    }
  }

  String translateAppLanguageType(AppLanguageType lang) {
    switch (lang) {
      case AppLanguageType.english:
        return english;
      case AppLanguageType.spanish:
        return spanish;
      default:
        throw Exception('The provided app lang = $lang is not valid');
    }
  }

  String translateWeaponType(WeaponType type) {
    switch (type) {
      case WeaponType.bow:
        return bow;
      case WeaponType.catalyst:
        return catalyst;
      case WeaponType.claymore:
        return claymore;
      case WeaponType.polearm:
        return polearm;
      case WeaponType.sword:
        return sword;
      default:
        throw Exception('The provided weapon type = $type is not valid');
    }
  }

  String translateItemLocationType(ItemLocationType type) {
    switch (type) {
      case ItemLocationType.na:
        return 'N/A';
      case ItemLocationType.gacha:
        return gacha;
      case ItemLocationType.crafting:
        return crafting;
      case ItemLocationType.starglitterExchange:
        return starglitterExchange;
      case ItemLocationType.chest:
        return chest;
      case ItemLocationType.bpBounty:
        return bpBounty;
      default:
        throw Exception('The provided location type = $type is not valid');
    }
  }

  String translateStatTypeWithoutValue(
    StatType type, {
    bool removeExtraSigns = false,
  }) {
    final translated = translateStatType(type, 0);
    final value = translated.replaceFirst('0.0', '').trim();
    if (removeExtraSigns) {
      return value.replaceAll('%', '').trim();
    }
    return value;
  }

  String translateStatType(StatType type, double value) {
    switch (type) {
      case StatType.atk:
        return atk(value);
      case StatType.atkPercentage:
        return atkPercentage(value);
      case StatType.critAtk:
        return critAtk(value);
      case StatType.critRate:
        return critRate(value);
      case StatType.critDmgPercentage:
        return critDmgPercentage(value);
      case StatType.critRatePercentage:
        return critRatePercentage(value);
      case StatType.defPercentage:
        return defPercentage(value);
      case StatType.elementaryMaster:
        return elementaryMaster(value);
      case StatType.energyRechargePercentage:
        return energyRechargePercentage(value);
      case StatType.hpPercentage:
        return hpPercentage(value);
      case StatType.none:
        return none;
      case StatType.physDmgBonus:
        return physDmgBonus(value);
      case StatType.physDmgPercentage:
        return physDmgPercentage(value);
      default:
        throw Exception('The provided stat type = $type is not valid');
    }
  }

  String translateDays(List<int> days) {
    return days.map((e) => translateDay(e)).join(', ');
  }

  String translateDay(int day) {
    switch (day) {
      case 1:
        return monday;
      case 2:
        return tuesday;
      case 3:
        return wednesday;
      case 4:
        return thursday;
      case 5:
        return friday;
      case 6:
        return saturday;
      case 7:
        return sunday;
      default:
        throw Exception('Invalid day = $day');
    }
  }

  String translateElementType(ElementType type) {
    switch (type) {
      case ElementType.anemo:
        return 'Anemo';
      case ElementType.cryo:
        return 'Cryo';
      case ElementType.dendro:
        return 'Dendro';
      case ElementType.electro:
        return 'Electro';
      case ElementType.geo:
        return 'Geo';
      case ElementType.hydro:
        return 'Hydro';
      case ElementType.pyro:
        return 'Pyro';
      default:
        throw Exception('Invalid element type = $type');
    }
  }

  String translateSortDirectionType(SortDirectionType type) {
    switch (type) {
      case SortDirectionType.asc:
        return asc;
      case SortDirectionType.desc:
        return desc;
      default:
        throw Exception('Invalid sort direction type = $type');
    }
  }

  String translateReleasedUnreleasedType(ReleasedUnreleasedType type) {
    switch (type) {
      case ReleasedUnreleasedType.all:
        return all;
      case ReleasedUnreleasedType.released:
        return released;
      case ReleasedUnreleasedType.unreleased:
        return unreleased;
      default:
        throw Exception('Invalid released-unreleased type = $type');
    }
  }

  String translateCharacterFilterType(CharacterFilterType type) {
    switch (type) {
      case CharacterFilterType.name:
        return name;
      case CharacterFilterType.rarity:
        return rarity;
      default:
        throw Exception('Invalid character filter type = $type');
    }
  }

  String translateWeaponFilterType(WeaponFilterType type) {
    switch (type) {
      case WeaponFilterType.atk:
        return translateStatTypeWithoutValue(StatType.atk);
      case WeaponFilterType.name:
        return name;
      case WeaponFilterType.rarity:
        return rarity;
      case WeaponFilterType.type:
        return this.type;
      default:
        throw Exception('Invalid weapon filter type = $type');
    }
  }

  String translateArtifactFilterType(ArtifactFilterType type) {
    switch (type) {
      case ArtifactFilterType.name:
        return name;
      case ArtifactFilterType.rarity:
        return rarity;
      default:
        throw Exception('Invalid artifact filter type = $type');
    }
  }
}
