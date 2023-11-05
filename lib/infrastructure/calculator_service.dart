import 'package:darq/darq.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';

class CalculatorServiceImpl implements CalculatorService {
  final GenshinService _genshinService;
  final ResourceService _resourceService;

  //These are initialized and cached when needed
  final List<MaterialFileModel> _charExpMaterials = [];
  final List<MaterialFileModel> _weaponExpMaterials = [];
  MaterialFileModel? _moraMaterial;

  CalculatorServiceImpl(this._genshinService, this._resourceService);

  @override
  List<AscensionMaterialsSummary> generateSummary(List<ItemAscensionMaterialModel> current) {
    final flattened = current.groupBy((g) => g.key).map((g) {
      final mapped = g.first.copyWith(
        requiredQuantity: g.map((e) => e.requiredQuantity).sum(),
        availableQuantity: g.map((e) => e.availableQuantity).sum(),
        remainingQuantity: g.map((e) => e.remainingQuantity).sum(),
      );

      return mapped;
    }).toList();

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
          fullImagePath: _resourceService.getMaterialImagePath(material.image, material.type),
          requiredQuantity: item.requiredQuantity,
          availableQuantity: item.availableQuantity,
          remainingQuantity: item.remainingQuantity,
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
          fullImagePath: _resourceService.getMaterialImagePath(material.image, material.type),
          requiredQuantity: item.requiredQuantity,
          availableQuantity: item.availableQuantity,
          remainingQuantity: item.remainingQuantity,
          days: material.days,
        );
      } else {
        switch (material.type) {
          case MaterialType.common:
            key = AscensionMaterialSummaryType.common;
          //some characters use ingredient / local specialities, so we label them all as local
          case MaterialType.local:
          case MaterialType.ingredient:
            key = AscensionMaterialSummaryType.local;
          case MaterialType.currency:
            key = AscensionMaterialSummaryType.currency;
          //there are some weapon secondary materials used by some characters, so I pretty much group them as common
          case MaterialType.weapon:
          case MaterialType.weaponPrimary:
            key = AscensionMaterialSummaryType.common;
          //this case shouldn't be common except for the traveler, since the elementalStone they use is no dropped from boss
          case MaterialType.elementalStone:
          case MaterialType.jewels:
          case MaterialType.talents:
          case MaterialType.others:
            key = AscensionMaterialSummaryType.others;
          case MaterialType.expWeapon:
          case MaterialType.expCharacter:
            key = AscensionMaterialSummaryType.exp;
        }
        newValue = MaterialSummary(
          key: material.key,
          type: material.type,
          rarity: material.rarity,
          position: material.position,
          level: material.level,
          hasSiblings: material.hasSiblings,
          fullImagePath: _resourceService.getMaterialImagePath(material.image, material.type),
          requiredQuantity: item.requiredQuantity,
          availableQuantity: item.availableQuantity,
          remainingQuantity: item.remainingQuantity,
          days: [],
        );
      }

      if (summary.containsKey(key)) {
        summary[key]!.add(newValue);
      } else {
        summary.putIfAbsent(key, () => [newValue]);
      }
    }

    return summary.entries
        .map((entry) => AscensionMaterialsSummary(type: entry.key, materials: sortMaterialsByGrouping(entry.value, SortDirectionType.desc)))
        .toList();
  }

  @override
  List<ItemAscensionMaterialModel> getAllCharacterPossibleMaterialsToUse(CharacterFileModel char) {
    final int currentLevel = itemAscensionLevelMap.entries.first.value;
    const int desiredLevel = maxItemLevel;
    const int currentAscensionLevel = minAscensionLevel;
    const int desiredAscensionLevel = maxAscensionLevel;

    return getCharacterMaterialsToUse(char, currentLevel, desiredLevel, currentAscensionLevel, desiredAscensionLevel, [], ignoreSkillLevel: true);
  }

  @override
  List<ItemAscensionMaterialModel> getAllWeaponPossibleMaterialsToUse(WeaponFileModel weapon) {
    final int currentLevel = itemAscensionLevelMap.entries.first.value;
    const int desiredLevel = maxItemLevel;
    const int currentAscensionLevel = minAscensionLevel;
    const int desiredAscensionLevel = maxAscensionLevel;

    return getWeaponMaterialsToUse(weapon, currentLevel, desiredLevel, currentAscensionLevel, desiredAscensionLevel);
  }

  @override
  List<String> getAllPossibleMaterialKeysToUse(String itemKey, bool isCharacter) {
    final allPossibleMaterialItemKeys = <String>[];
    if (isCharacter) {
      final char = _genshinService.characters.getCharacter(itemKey);
      allPossibleMaterialItemKeys.addAll(getAllCharacterPossibleMaterialsToUse(char).map((e) => e.key));
    } else {
      final weapon = _genshinService.weapons.getWeapon(itemKey);
      allPossibleMaterialItemKeys.addAll(getAllWeaponPossibleMaterialsToUse(weapon).map((e) => e.key));
    }

    return allPossibleMaterialItemKeys;
  }

  @override
  List<ItemAscensionMaterialModel> getCharacterMaterialsToUse(
    CharacterFileModel char,
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
    List<CharacterSkill> skills, {
    bool sort = true,
    bool ignoreSkillLevel = false,
  }) {
    final allMaterials = <ItemAscensionMaterialFileModel>[];

    final expMaterials = _getItemExperienceMaterials(currentLevel, desiredLevel, char.rarity, true);
    allMaterials.addAll(expMaterials);

    final ascensionMaterials = char.ascensionMaterials
        .where(
          (m) => m.rank > currentAscensionLevel && m.rank <= desiredAscensionLevel,
        )
        .expand((e) => e.materials);
    allMaterials.addAll(ascensionMaterials);

    if (char.talentAscensionMaterials.isNotEmpty) {
      if (ignoreSkillLevel) {
        final materials = char.talentAscensionMaterials.expand((m) => m.materials);
        allMaterials.addAll(materials);
      } else {
        for (final skill in skills) {
          final materials = char.talentAscensionMaterials
              .where(
                (m) => m.level > skill.currentLevel && m.level <= skill.desiredLevel,
              )
              .expand((m) => m.materials);
          allMaterials.addAll(materials);
        }
      }
    } else if (char.multiTalentAscensionMaterials != null && char.multiTalentAscensionMaterials!.isNotEmpty) {
      //The traveler has different materials depending on the skill, that's why we need to retrieve the right amount for the provided skill
      //Also, we are assuming that the skill's order are fixed
      int talentNumber = 1;
      if (ignoreSkillLevel) {
        for (int i = talentNumber; i < char.multiTalentAscensionMaterials!.length + 1; i++) {
          final materials = char.multiTalentAscensionMaterials!.where((mt) => mt.number == i).expand((mt) => mt.materials).expand((m) => m.materials);
          allMaterials.addAll(materials);
        }
      } else {
        for (final skill in skills) {
          final materials = char.multiTalentAscensionMaterials!
              .where((mt) => mt.number == talentNumber)
              .expand((mt) => mt.materials)
              .where((m) => m.level > skill.currentLevel && m.level <= skill.desiredLevel)
              .expand((m) => m.materials);
          allMaterials.addAll(materials);

          talentNumber++;
        }
      }
    }

    final materials = allMaterials.groupBy((m) => m.key).map((g) {
      final material = _genshinService.materials.getMaterial(g.key);
      final int quantity = g.map((e) => e.quantity).sum();
      final imagePath = _resourceService.getMaterialImagePath(material.image, material.type);
      return ItemAscensionMaterialModel.fromMaterial(quantity, material, imagePath, remainingQuantity: quantity);
    });
    if (!sort) {
      return materials.toList();
    }
    return sortMaterialsByGrouping(materials, SortDirectionType.asc);
  }

  @override
  List<ItemAscensionMaterialModel> getWeaponMaterialsToUse(
    WeaponFileModel weapon,
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel, {
    bool sort = true,
  }) {
    final ascensionMaterials = weapon.ascensionMaterials
        .where((m) => m.level > _mapToWeaponLevel(currentAscensionLevel) && m.level <= _mapToWeaponLevel(desiredAscensionLevel))
        .expand((m) => m.materials);
    final expMaterials = _getItemExperienceMaterials(currentLevel, desiredLevel, weapon.rarity, false);
    final materials = expMaterials.concat(ascensionMaterials).groupBy((m) => m.key).map((g) {
      final material = _genshinService.materials.getMaterial(g.key);
      final int quantity = g.map((e) => e.quantity).sum();
      return ItemAscensionMaterialModel.fromMaterial(quantity, material, _resourceService.getMaterialImagePath(material.image, material.type));
    });
    if (!sort) {
      return materials.toList();
    }
    return sortMaterialsByGrouping(materials, SortDirectionType.asc);
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
  (bool, bool, bool, bool) isSkillEnabled(
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

    return (currentDecEnabled, currentIncEnabled, desiredDecEnabled, desiredIncEnabled);
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

  List<ItemAscensionMaterialFileModel> _getItemExperienceMaterials(int currentLevel, int desiredLevel, int rarity, bool forCharacters) {
    final materials = <ItemAscensionMaterialFileModel>[];
    double requiredExp = getItemTotalExp(currentLevel, desiredLevel, rarity, forCharacters);
    if (requiredExp <= 0) {
      return materials;
    }

    //Here we order the exp materials in a way that the one that gives more exp is first and so on
    if (forCharacters && _charExpMaterials.isEmpty) {
      final charExpMaterials = _genshinService.materials.getMaterials(MaterialType.expCharacter)
        ..sort((x, y) => (y.experienceAttributes!.experience - x.experienceAttributes!.experience).round());
      _charExpMaterials.addAll(charExpMaterials);
    } else if (!forCharacters && _weaponExpMaterials.isEmpty) {
      final weaponExpMaterials = _genshinService.materials.getMaterials(MaterialType.expWeapon)
        ..sort((x, y) => (y.experienceAttributes!.experience - x.experienceAttributes!.experience).round());
      _weaponExpMaterials.addAll(weaponExpMaterials);
    }

    final expMaterials = forCharacters ? _charExpMaterials : _weaponExpMaterials;
    _moraMaterial ??= _genshinService.materials.getMoraMaterial();

    for (final MaterialFileModel material in expMaterials) {
      if (requiredExp <= 0) {
        break;
      }

      final double matExp = material.experienceAttributes!.experience;
      final int quantity = (requiredExp / matExp).floor();
      if (quantity == 0) {
        continue;
      }

      materials.add(ItemAscensionMaterialFileModel(key: material.key, type: material.type, quantity: quantity));
      requiredExp -= quantity * matExp;

      final double requiredMora = quantity * material.experienceAttributes!.pricePerUsage;
      materials.add(ItemAscensionMaterialFileModel(key: _moraMaterial!.key, type: _moraMaterial!.type, quantity: requiredMora.round()));
    }

    return materials.reverse().toList();
  }
}
