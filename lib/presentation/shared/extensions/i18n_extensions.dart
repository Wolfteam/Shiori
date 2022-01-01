import 'package:shiori/domain/app_constants.dart';

import '../../../domain/enums/enums.dart';
import '../../../generated/l10n.dart';

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
      case AppLanguageType.russian:
        return russian;
      case AppLanguageType.simplifiedChinese:
        return simplifiedChinese;
      case AppLanguageType.portuguese:
        return portuguese;
      case AppLanguageType.italian:
        return '$italian ($unofficial)';
      case AppLanguageType.japanese:
        return japanese;
      case AppLanguageType.vietnamese:
        return vietnamese;
      case AppLanguageType.indonesian:
        return indonesian;
      case AppLanguageType.deutsch:
        return deutsch;
      case AppLanguageType.french:
        return french;
      case AppLanguageType.traditionalChinese:
        return traditionalChinese;
      case AppLanguageType.korean:
        return korean;
      case AppLanguageType.thai:
        return thai;
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
        return na;
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
      case ItemLocationType.quest:
        return quest;
      case ItemLocationType.playstation:
        return playstation;
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
      case StatType.elementalMastery:
        return elementaryMastery(value);
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
      case StatType.hp:
        return hp(value);
      case StatType.electroDmgBonusPercentage:
        return xDmgBonusPercentage(value, translateElementType(ElementType.electro));
      case StatType.cryoDmgBonusPercentage:
        return xDmgBonusPercentage(value, translateElementType(ElementType.cryo));
      case StatType.pyroDmgBonusPercentage:
        return xDmgBonusPercentage(value, translateElementType(ElementType.pyro));
      case StatType.hydroDmgBonusPercentage:
        return xDmgBonusPercentage(value, translateElementType(ElementType.hydro));
      case StatType.geoDmgBonusPercentage:
        return xDmgBonusPercentage(value, translateElementType(ElementType.geo));
      case StatType.anemoDmgBonusPercentage:
        return xDmgBonusPercentage(value, translateElementType(ElementType.anemo));
      case StatType.healingBonusPercentage:
        return healingBonusPercentage(value);
      case StatType.def:
        return def(value);
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
        return anemo;
      case ElementType.cryo:
        return cryo;
      case ElementType.dendro:
        return dendro;
      case ElementType.electro:
        return electro;
      case ElementType.geo:
        return geo;
      case ElementType.hydro:
        return hydro;
      case ElementType.pyro:
        return pyro;
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

  String translateReleasedUnreleasedType(ItemStatusType type) {
    switch (type) {
      case ItemStatusType.released:
        return released;
      case ItemStatusType.comingSoon:
        return comingSoon;
      case ItemStatusType.newItem:
        return brandNew;
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
      case WeaponFilterType.subStat:
        return subStat;
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

  String translateCharacterRoleType(CharacterRoleType type) {
    switch (type) {
      case CharacterRoleType.dps:
        return charRoleDps;
      case CharacterRoleType.subDps:
        return charRoleSubDps;
      case CharacterRoleType.burstSupport:
        return charRoleBurstSupport;
      case CharacterRoleType.support:
        return charRoleSupport;
      case CharacterRoleType.offFieldDps:
        return charRoleOffFieldDps;
      case CharacterRoleType.na:
        return na;
      default:
        throw Exception('Invalid character type = $type');
    }
  }

  String translateCharacterSkillType(CharacterSkillType type) {
    switch (type) {
      case CharacterSkillType.normalAttack:
        return normalAttack;
      case CharacterSkillType.elementalSkill:
        return elementalSkill;
      case CharacterSkillType.elementalBurst:
        return elementalBurst;
      case CharacterSkillType.others:
        return others;
      default:
        throw Exception('Invalid character skill type = $type');
    }
  }

  String translateCharacterSkillAbilityType(CharacterSkillAbilityType type) {
    switch (type) {
      case CharacterSkillAbilityType.normalAttack:
        return normalAttack;
      case CharacterSkillAbilityType.chargedAttack:
        return chargedAttack;
      case CharacterSkillAbilityType.plungingAttack:
        return plungingAttack;
      case CharacterSkillAbilityType.hold:
        return hold;
      case CharacterSkillAbilityType.holdShort:
        return '$hold ($short)';
      case CharacterSkillAbilityType.press:
        return press;
      case CharacterSkillAbilityType.elementalAbsorption:
        return elementalAbsorption;
      default:
        throw Exception('Invalid character skill ability type = $type');
    }
  }

  String translateRegionType(RegionType type) {
    switch (type) {
      case RegionType.anotherWorld:
        return anotherWorld;
      case RegionType.inazuma:
        return inazuma;
      case RegionType.mondstadt:
        return mondstadt;
      case RegionType.liyue:
        return liyue;
      case RegionType.snezhnaya:
        return snezhnaya;
      case RegionType.fontaine:
        return fontaine;
      case RegionType.natlan:
        return natlan;
      case RegionType.sumeru:
        return sumeru;
      default:
        throw Exception('Invalid region type = $type');
    }
  }

  String translateAscensionSummaryType(AscensionMaterialSummaryType type) {
    switch (type) {
      case AscensionMaterialSummaryType.common:
        return common;
      case AscensionMaterialSummaryType.local:
        return localSpecialities;
      case AscensionMaterialSummaryType.worldBoss:
        return boss;
      case AscensionMaterialSummaryType.day:
        return day;
      case AscensionMaterialSummaryType.currency:
        return '$currency ($approximate)';
      case AscensionMaterialSummaryType.others:
        return others;
      case AscensionMaterialSummaryType.exp:
        return '$experience ($approximate)';
      default:
        throw Exception('Invalid ascension material type = $type');
    }
  }

  String translateServerResetTimeType(AppServerResetTimeType type) {
    switch (type) {
      case AppServerResetTimeType.northAmerica:
        return northAmerica;
      case AppServerResetTimeType.europe:
        return europe;
      case AppServerResetTimeType.asia:
        return asia;
      default:
        throw Exception('Invalid server reset time type = $type');
    }
  }

  String translateMaterialFilterType(MaterialFilterType type) {
    switch (type) {
      case MaterialFilterType.name:
        return name;
      case MaterialFilterType.rarity:
        return rarity;
      case MaterialFilterType.grouped:
        return grouped;
      default:
        throw Exception('Invalid material filter type = $type');
    }
  }

  String translateMaterialType(MaterialType type) {
    switch (type) {
      case MaterialType.common:
        return common;
      case MaterialType.elementalStone:
        return elementalStone;
      case MaterialType.jewels:
        return jewel;
      case MaterialType.local:
        return local;
      case MaterialType.talents:
        return talent;
      case MaterialType.weapon:
      case MaterialType.weaponPrimary:
        return weapon;
      case MaterialType.currency:
        return currency;
      case MaterialType.others:
        return others;
      case MaterialType.ingredient:
        return ingredient;
      case MaterialType.expWeapon:
      case MaterialType.expCharacter:
        return experience;
      default:
        throw Exception('Invalid material type = $type');
    }
  }

  String translateMonsterType(MonsterType type) {
    switch (type) {
      case MonsterType.abyssOrder:
        return abyssOrder;
      case MonsterType.elementalLifeForm:
        return elementalLifeForm;
      case MonsterType.human:
        return human;
      case MonsterType.magicalBeast:
        return magicalBeast;
      case MonsterType.boss:
        return boss;
      case MonsterType.hilichurl:
        return hilichurl;
      case MonsterType.fatui:
        return fatui;
      case MonsterType.automaton:
        return automaton;
      case MonsterType.na:
        return na;
      default:
        throw Exception('Invalid monster type = $type');
    }
  }

  String translateMonsterFilterType(MonsterFilterType type) {
    switch (type) {
      case MonsterFilterType.name:
        return name;
      default:
        throw Exception('Invalid monster filter type = $type');
    }
  }

  String translateAppNotificationType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.resin:
        return resin;
      case AppNotificationType.expedition:
        return expedition;
      case AppNotificationType.farmingMaterials:
        return '$farming ($materials)';
      case AppNotificationType.farmingArtifacts:
        return '$farming ($artifacts)';
      case AppNotificationType.gadget:
        return gadget;
      case AppNotificationType.furniture:
        return furnishing;
      case AppNotificationType.realmCurrency:
        return realmCurrency;
      case AppNotificationType.weeklyBoss:
        return boss;
      case AppNotificationType.custom:
        return custom;
      case AppNotificationType.dailyCheckIn:
        return dailyCheckIn;
      default:
        throw Exception('Invalid app notification type = $type');
    }
  }

  String translateExpeditionTimeType(ExpeditionTimeType type) {
    switch (type) {
      case ExpeditionTimeType.fourHours:
        return xHours(4);
      case ExpeditionTimeType.eightHours:
        return xHours(8);
      case ExpeditionTimeType.twelveHours:
        return xHours(12);
      case ExpeditionTimeType.twentyHours:
        return xHours(20);
      default:
        throw Exception('Invalid expedition time type = $type');
    }
  }

  String translateAppNotificationItemType(AppNotificationItemType type) {
    switch (type) {
      case AppNotificationItemType.character:
        return characters;
      case AppNotificationItemType.weapon:
        return weapons;
      case AppNotificationItemType.artifact:
        return artifacts;
      case AppNotificationItemType.monster:
        return monsters;
      case AppNotificationItemType.material:
        return materials;
      default:
        throw Exception('Invalid app notification item type = $type');
    }
  }

  String translateArtifactFarmingTimeType(ArtifactFarmingTimeType type) {
    switch (type) {
      case ArtifactFarmingTimeType.twelveHours:
        return xHours(12);
      case ArtifactFarmingTimeType.twentyFourHours:
        return xHours(24);
      default:
        throw Exception('Invalid artifact farming time type = $type');
    }
  }

  String translateFurnitureCraftingTimeType(FurnitureCraftingTimeType type) {
    switch (type) {
      case FurnitureCraftingTimeType.twelveHours:
        return xHours(12);
      case FurnitureCraftingTimeType.fourteenHours:
        return xHours(14);
      case FurnitureCraftingTimeType.sixteenHours:
        return xHours(16);
      default:
        throw Exception('Invalid furniture crafting time type = $type');
    }
  }

  String translateRealRankType(RealmRankType type, {bool showRatio = false}) {
    var translation = '';
    switch (type) {
      case RealmRankType.bareBones:
        translation = bareBones;
        break;
      case RealmRankType.humbleAbode:
        translation = humbleAbode;
        break;
      case RealmRankType.cozy:
        translation = cozy;
        break;
      case RealmRankType.queenSize:
        translation = queenSize;
        break;
      case RealmRankType.elegant:
        translation = elegant;
        break;
      case RealmRankType.exquisite:
        translation = exquisite;
        break;
      case RealmRankType.extraordinary:
        translation = extraordinary;
        break;
      case RealmRankType.stately:
        translation = stately;
        break;
      case RealmRankType.luxury:
        translation = luxury;
        break;
      case RealmRankType.fitForAKing:
        translation = fitForAKing;
        break;
      default:
        throw Exception('Invalid realm rank type = $type');
    }
    if (!showRatio) {
      return translation;
    }

    final ratioInHours = '+${getRealmIncreaseRatio(type)}';
    return '$translation (${xEachHour(ratioInHours)})';
  }

  String translateCharacterRoleSubType(CharacterRoleSubType type) {
    switch (type) {
      case CharacterRoleSubType.none:
        return none;
      case CharacterRoleSubType.anemo:
        return anemo;
      case CharacterRoleSubType.geo:
        return geo;
      case CharacterRoleSubType.electro:
        return electro;
      case CharacterRoleSubType.dendro:
        return dendro;
      case CharacterRoleSubType.hydro:
        return hydro;
      case CharacterRoleSubType.pyro:
        return pyro;
      case CharacterRoleSubType.cryo:
        return cryo;
      case CharacterRoleSubType.elementalMastery:
        return translateStatTypeWithoutValue(StatType.elementalMastery, removeExtraSigns: true);
      case CharacterRoleSubType.physical:
        return translateStatTypeWithoutValue(StatType.physDmgPercentage, removeExtraSigns: true);
      case CharacterRoleSubType.melt:
        return melt;
      case CharacterRoleSubType.freeze:
        return freeze;
      case CharacterRoleSubType.shield:
        return shield;
    }
  }

  String translateArtifactType(ArtifactType type) {
    switch (type) {
      case ArtifactType.flower:
        return flower;
      case ArtifactType.plume:
        return plume;
      case ArtifactType.clock:
        return clock;
      case ArtifactType.goblet:
        return goblet;
      case ArtifactType.crown:
        return crown;
    }
  }
}
