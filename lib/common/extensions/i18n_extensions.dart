import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/enums/item_location_type.dart';
import '../../common/enums/stat_type.dart';
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
}
