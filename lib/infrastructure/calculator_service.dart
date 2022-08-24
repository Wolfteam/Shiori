import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:tuple/tuple.dart';

class CalculatorServiceImpl implements CalculatorService {
  final GenshinService _genshinService;

  CalculatorServiceImpl(this._genshinService);

  @override
  List<AscensionMaterialsSummary> generateSummary(List<ItemAscensionMaterialModel> current) {
    final flattened = _flatMaterialsList(current);

    final summary = <AscensionMaterialSummaryType, List<MaterialSummary>>{};
    for (var i = 0; i < flattened.length; i++) {
      final item = flattened[i];
      final material = _genshinService.materials.getMaterial(item.key);

      MaterialSummary newValue;
      AscensionMaterialSummaryType key;

      if (material.isFromBoss) {
        key = AscensionMaterialSummaryType.worldBoss;
        newValue = MaterialSummary(
          key: material.key,
          type: material.type,
          rarity: material.rarity,
          position: material.position,
          level: material.level,
          hasSiblings: material.hasSiblings,
          fullImagePath: material.fullImagePath,
          quantity: item.quantity,
          days: [],
        );
      } else if (material.days.isNotEmpty) {
        key = AscensionMaterialSummaryType.day;
        newValue = MaterialSummary(
          key: material.key,
          type: material.type,
          rarity: material.rarity,
          position: material.position,
          level: material.level,
          hasSiblings: material.hasSiblings,
          fullImagePath: material.fullImagePath,
          quantity: item.quantity,
          days: material.days,
        );
      } else {
        switch (material.type) {
          case MaterialType.common:
            key = AscensionMaterialSummaryType.common;
            break;
          //some characters use ingredient / local specialities, so we label them all as local
          case MaterialType.local:
          case MaterialType.ingredient:
            key = AscensionMaterialSummaryType.local;
            break;
          case MaterialType.currency:
            key = AscensionMaterialSummaryType.currency;
            break;
          //there are some weapon secondary materials used by some characters, so I pretty much group them as common
          case MaterialType.weapon:
          case MaterialType.weaponPrimary:
            key = AscensionMaterialSummaryType.common;
            break;
          //this case shouldn't be common except for the traveler, since the elementalStone they use is no dropped from boss
          case MaterialType.elementalStone:
          case MaterialType.jewels:
          case MaterialType.talents:
          case MaterialType.others:
            key = AscensionMaterialSummaryType.others;
            break;
          case MaterialType.expWeapon:
          case MaterialType.expCharacter:
            key = AscensionMaterialSummaryType.exp;
            break;
        }
        newValue = MaterialSummary(
          key: material.key,
          type: material.type,
          rarity: material.rarity,
          position: material.position,
          level: material.level,
          hasSiblings: material.hasSiblings,
          fullImagePath: material.fullImagePath,
          quantity: item.quantity,
          days: [],
        );
      }

      if (summary.containsKey(key)) {
        summary[key]!.add(newValue);
      } else {
        summary.putIfAbsent(key, () => [newValue]);
      }

      summary[key]!.sort((x, y) => x.key.compareTo(y.key));
    }

    return summary.entries
        .map((entry) => AscensionMaterialsSummary(type: entry.key, materials: sortMaterialsByGrouping(entry.value, SortDirectionType.desc)))
        .toList();
  }

  @override
  List<ItemAscensionMaterialModel> getCharacterMaterialsToUse(
    CharacterFileModel char,
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
    List<CharacterSkill> skills,
  ) {
    final expMaterials = _getItemExperienceMaterials(currentLevel, desiredLevel, char.rarity, true);

    final ascensionMaterials = char.ascensionMaterials
        .where((m) => m.rank > currentAscensionLevel && m.rank <= desiredAscensionLevel)
        .expand((e) => e.materials)
        .map((e) => ItemAscensionMaterialModel.fromFile(e, _genshinService.materials.getMaterialImg(e.key)))
        .toList();

    final skillMaterials = <ItemAscensionMaterialModel>[];

    if (char.talentAscensionMaterials.isNotEmpty) {
      for (final skill in skills) {
        final materials = char.talentAscensionMaterials
            .where((m) => m.level > skill.currentLevel && m.level <= skill.desiredLevel)
            .expand((m) => m.materials)
            .map((e) => ItemAscensionMaterialModel.fromFile(e, _genshinService.materials.getMaterialImg(e.key)))
            .toList();

        skillMaterials.addAll(materials);
      }
    } else if (char.multiTalentAscensionMaterials != null && char.multiTalentAscensionMaterials!.isNotEmpty) {
      //The traveler has different materials depending on the skill, that's why we need to retrieve the right amount for the provided skill
      //Also, we are assuming that the skill's order are fixed
      var talentNumber = 1;
      for (final skill in skills) {
        final materials = char.multiTalentAscensionMaterials!
            .where((mt) => mt.number == talentNumber)
            .expand((mt) => mt.materials)
            .where((m) => m.level > skill.currentLevel && m.level <= skill.desiredLevel)
            .expand((m) => m.materials)
            .map((e) => ItemAscensionMaterialModel.fromFile(e, _genshinService.materials.getMaterialImg(e.key)))
            .toList();

        skillMaterials.addAll(materials);

        talentNumber++;
      }
    }

    return _flatMaterialsList(expMaterials + ascensionMaterials + skillMaterials);
  }

  @override
  List<ItemAscensionMaterialModel> getWeaponMaterialsToUse(
    WeaponFileModel weapon,
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
  ) {
    final expMaterials = _getItemExperienceMaterials(currentLevel, desiredLevel, weapon.rarity, false);
    final materials = weapon.ascensionMaterials
        .where((m) => m.level > _mapToWeaponLevel(currentAscensionLevel) && m.level <= _mapToWeaponLevel(desiredAscensionLevel))
        .expand((m) => m.materials)
        .map((e) => ItemAscensionMaterialModel.fromFile(e, _genshinService.materials.getMaterialImg(e.key)))
        .toList();

    return _flatMaterialsList(expMaterials + materials);
  }

  @override
  int getClosestAscensionLevelFor(int toItemLevel, int ascensionLevel) {
    final isValid = isLevelValidForAscensionLevel(toItemLevel, ascensionLevel);
    return getClosestAscensionLevel(toItemLevel, isValid);
  }

  @override
  int getClosestAscensionLevel(int toItemLevel, bool isAscended) {
    if (toItemLevel <= 0) {
      throw Exception('The provided itemLevel = $toItemLevel is not valid');
    }

    int ascensionLevel = -1;
    for (final kvp in itemAscensionLevelMap.entries) {
      final temp = kvp.value;
      if (temp >= toItemLevel && ascensionLevel == -1) {
        ascensionLevel = kvp.key;
        break;
      }
      continue;
    }

    //if we end up here, that means the provided level is higher than the one in the
    //map, so we simple return the highest one available
    if (ascensionLevel == -1) {
      return itemAscensionLevelMap.entries.last.key;
    }

    if (toItemLevel == itemAscensionLevelMap.entries.firstWhere((kvp) => kvp.key == ascensionLevel).value) {
      return isAscended ? ascensionLevel : ascensionLevel - 1;
    }

    return ascensionLevel - 1;
  }

  @override
  int getItemLevelToUse(int currentAscensionLevel, int currentItemLevel) {
    if (currentItemLevel <= 0) {
      throw Exception('The provided itemLevel = $currentItemLevel is not valid');
    }
    if (currentAscensionLevel < 0) {
      throw Exception('The provided ascension level = $currentAscensionLevel is not valid');
    }

    if (currentAscensionLevel == 0) {
      return itemAscensionLevelMap.entries.first.value;
    }

    final currentKvp = itemAscensionLevelMap.entries.firstWhere((kvp) => kvp.key == currentAscensionLevel);
    final suggestedAscLevel = getClosestAscensionLevel(currentItemLevel, false);

    if (currentKvp.key != suggestedAscLevel) {
      return currentKvp.value;
    }

    return currentItemLevel;
  }

  @override
  int getSkillLevelToUse(int forAscensionLevel, int currentSkillLevel) {
    if (forAscensionLevel < 0) {
      throw Exception('The provided ascension level = $forAscensionLevel is not valid');
    }

    if (forAscensionLevel == 0) {
      return skillAscensionMap.entries.first.value.first;
    }

    if (!skillAscensionMap.entries.any((kvp) => kvp.value.contains(currentSkillLevel))) {
      throw Exception('The provided skill level = $currentSkillLevel is not valid');
    }

    final currentKvp = skillAscensionMap.entries.firstWhere((kvp) => kvp.value.contains(currentSkillLevel));
    final newKvp = skillAscensionMap.entries.firstWhere((kvp) => kvp.key == forAscensionLevel);

    if (newKvp.key >= currentKvp.key) {
      return currentSkillLevel;
    }

    return newKvp.value.first;
  }

  @override
  bool isLevelValidForAscensionLevel(int currentLevel, int ascensionLevel) {
    if (ascensionLevel == 0) {
      return itemAscensionLevelMap.entries.first.value >= currentLevel;
    }

    if (ascensionLevel == itemAscensionLevelMap.entries.last.key) {
      return currentLevel >= itemAscensionLevelMap.entries.last.value;
    }

    final entry = itemAscensionLevelMap.entries.firstWhere((kvp) => kvp.key == ascensionLevel);
    final nextEntry = itemAscensionLevelMap.entries.firstWhere((kvp) => kvp.key == ascensionLevel + 1);
    return entry.value >= currentLevel && currentLevel <= nextEntry.value;
  }

  /// Checks if a skill can be increased.
  ///
  /// Keep in mind that the values provided  must be already validated
  bool _canSkillBeIncreased(
    int skillLevel,
    int maxAscensionLevel,
    int minSkillLevel,
    int maxSkillLevel,
  ) {
    if (maxAscensionLevel < 0) {
      throw Exception('The provided ascension level = $maxAscensionLevel is not valid');
    }

    if (maxAscensionLevel == 0 && skillLevel > minSkillLevel) {
      return true;
    } else if (maxAscensionLevel == 0 && skillLevel == minSkillLevel) {
      return false;
    }

    final currentSkillEntry = skillAscensionMap.entries.firstWhere((kvp) => kvp.value.contains(skillLevel));
    final ascensionEntry = skillAscensionMap.entries.firstWhere((kvp) => kvp.key == maxAscensionLevel);

    //If the ascension level are different, just return true, since we don't need to make any validation in this method
    if (ascensionEntry.key != currentSkillEntry.key) {
      return true;
    }

    //otherwise, return true only if this skill is not the last in the map
    final isNotTheLast = currentSkillEntry.value.last != skillLevel;
    return isNotTheLast;
  }

  @override
  Tuple4<bool, bool, bool, bool> isSkillEnabled(
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
    int minSkillLevel,
    int maxSkillLevel,
  ) {
    final currentDecEnabled = currentLevel != minSkillLevel;
    final currentIncEnabled = currentLevel != maxSkillLevel &&
        _canSkillBeIncreased(
          currentLevel,
          currentAscensionLevel,
          minSkillLevel,
          maxSkillLevel,
        );

    final desiredDecEnabled = desiredLevel != minSkillLevel;
    final desiredIncEnabled = desiredLevel != maxSkillLevel &&
        _canSkillBeIncreased(
          desiredLevel,
          desiredAscensionLevel,
          minSkillLevel,
          maxSkillLevel,
        );

    return Tuple4<bool, bool, bool, bool>(currentDecEnabled, currentIncEnabled, desiredDecEnabled, desiredIncEnabled);
  }

  List<ItemAscensionMaterialModel> _flatMaterialsList(List<ItemAscensionMaterialModel> current) {
    final materials = <ItemAscensionMaterialModel>[];
    for (final key in current.map((e) => e.key).toSet().toList()) {
      final item = current.firstWhere((m) => m.key == key);
      final int quantity = current.where((m) => m.key == key).map((e) => e.quantity).fold(0, (previous, current) => previous + current);

      materials.add(item.copyWith.call(quantity: quantity));
    }

    return materials;
  }

  int _mapToWeaponLevel(int val) {
    switch (val) {
      //Here we consider the 0, because otherwise we will always start from a current level of 1, and sometimes, we want to know the whole thing
      //(from 1 to 10 with 1 inclusive)
      case 0:
        return 0;
      default:
        final entry = itemAscensionLevelMap.entries.firstWhere((kvp) => kvp.key == val);
        return entry.value;
    }
  }

  List<ItemAscensionMaterialModel> _getItemExperienceMaterials(int currentLevel, int desiredLevel, int rarity, bool forCharacters) {
    final materials = <ItemAscensionMaterialModel>[];
    //Here we order the exp materials in a way that the one that gives more exp is first and so on
    final expMaterials = _genshinService.materials.getMaterials(forCharacters ? MaterialType.expCharacter : MaterialType.expWeapon)
      ..sort((x, y) => (y.experienceAttributes!.experience - x.experienceAttributes!.experience).round());
    var requiredExp = getItemTotalExp(currentLevel, desiredLevel, rarity, forCharacters);
    final moraMaterial = _genshinService.materials.getMoraMaterial();

    for (final material in expMaterials) {
      if (requiredExp <= 0) {
        break;
      }

      final matExp = material.experienceAttributes!.experience;
      final quantity = (requiredExp / matExp).floor();
      if (quantity == 0) {
        continue;
      }
      materials.add(
        ItemAscensionMaterialModel(
          key: material.key,
          type: material.type,
          image: material.fullImagePath,
          quantity: quantity,
        ),
      );
      requiredExp -= quantity * matExp;

      final requiredMora = quantity * material.experienceAttributes!.pricePerUsage;
      materials.add(
        ItemAscensionMaterialModel(
          key: moraMaterial.key,
          type: moraMaterial.type,
          image: moraMaterial.fullImagePath,
          quantity: requiredMora.round(),
        ),
      );
    }

    return materials.reversed.toList();
  }
}
