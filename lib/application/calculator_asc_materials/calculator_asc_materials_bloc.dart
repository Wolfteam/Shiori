import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';

part 'calculator_asc_materials_bloc.freezed.dart';
part 'calculator_asc_materials_event.dart';
part 'calculator_asc_materials_state.dart';

class CalculatorAscMaterialsBloc extends Bloc<CalculatorAscMaterialsEvent, CalculatorAscMaterialsState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  _InitialState get currentState => state as _InitialState;

  CalculatorAscMaterialsBloc(
    this._genshinService,
    this._telemetryService,
  ) : super(const CalculatorAscMaterialsState.initial(items: [], summary: []));

  @override
  Stream<CalculatorAscMaterialsState> mapEventToState(
    CalculatorAscMaterialsEvent event,
  ) async* {
    final s = await event.map(
      init: (_) async => const CalculatorAscMaterialsState.initial(items: [], summary: []),
      addCharacter: (e) async {
        await _telemetryService.trackCalculatorItemAscMaterialLoaded(e.key);
        final char = _genshinService.getCharacter(e.key);
        final translation = _genshinService.getCharacterTranslation(e.key);

        final items = [
          ...currentState.items,
          ItemAscensionMaterials.forCharacters(
            key: e.key,
            image: Assets.getCharacterPath(char.image),
            name: translation.name,
            rarity: char.rarity,
            materials: _getCharacterMaterialsToUse(char, e.currentLevel, e.desiredLevel, e.currentAscensionLevel, e.desiredAscensionLevel, e.skills),
            currentLevel: e.currentLevel,
            desiredLevel: e.desiredLevel,
            skills: e.skills,
            desiredAscensionLevel: e.desiredAscensionLevel,
            currentAscensionLevel: e.currentAscensionLevel,
          )
        ];
        final materialsForSummary = _buildMaterialsForSummary(items);
        return currentState.copyWith.call(items: items, summary: _generateSummary(materialsForSummary));
      },
      addWeapon: (e) async {
        await _telemetryService.trackCalculatorItemAscMaterialLoaded(e.key);
        final weapon = _genshinService.getWeapon(e.key);
        final translation = _genshinService.getWeaponTranslation(e.key);
        final items = [
          ...currentState.items,
          ItemAscensionMaterials.forWeapons(
            key: e.key,
            image: weapon.fullImagePath,
            name: translation.name,
            rarity: weapon.rarity,
            materials: _getWeaponMaterialsToUse(weapon, e.currentLevel, e.desiredLevel, e.currentAscensionLevel, e.desiredAscensionLevel),
            currentLevel: e.currentLevel,
            desiredLevel: e.desiredLevel,
            desiredAscensionLevel: e.desiredAscensionLevel,
            currentAscensionLevel: e.currentAscensionLevel,
          )
        ];
        final materialsForSummary = _buildMaterialsForSummary(items);
        return currentState.copyWith.call(items: items, summary: _generateSummary(materialsForSummary));
      },
      removeItem: (e) async {
        final items = [...currentState.items];
        items.removeAt(e.index);
        final materialsForSummary = _buildMaterialsForSummary(items);
        return currentState.copyWith.call(items: items, summary: _generateSummary(materialsForSummary));
      },
      updateCharacter: (e) async {
        final currentChar = currentState.items.elementAt(e.index);
        final char = _genshinService.getCharacter(currentChar.key);
        final updatedChar = currentChar.copyWith.call(
          materials: _getCharacterMaterialsToUse(char, e.currentLevel, e.desiredLevel, e.currentAscensionLevel, e.desiredAscensionLevel, e.skills),
          currentLevel: e.currentLevel,
          desiredLevel: e.desiredLevel,
          skills: e.skills,
          desiredAscensionLevel: e.desiredAscensionLevel,
          currentAscensionLevel: e.currentAscensionLevel,
          isActive: e.isActive,
        );

        return _updateItem(e.index, updatedChar);
      },
      updateWeapon: (e) async {
        final currentWeapon = currentState.items.elementAt(e.index);
        final weapon = _genshinService.getWeapon(currentWeapon.key);
        final updatedWeapon = currentWeapon.copyWith.call(
          materials: _getWeaponMaterialsToUse(weapon, e.currentLevel, e.desiredLevel, e.currentAscensionLevel, e.desiredAscensionLevel),
          currentLevel: e.currentLevel,
          desiredLevel: e.desiredLevel,
          desiredAscensionLevel: e.desiredAscensionLevel,
          currentAscensionLevel: e.currentAscensionLevel,
          isActive: e.isActive,
        );

        return _updateItem(e.index, updatedWeapon);
      },
    );

    yield s;
  }

  ItemAscensionMaterials getItem(int index) {
    return currentState.items.elementAt(index);
  }

  List<AscensionMaterialsSummary> _generateSummary(List<ItemAscensionMaterialModel> current) {
    final flattened = _flatMaterialsList(current);

    final summary = <AscensionMaterialSummaryType, List<MaterialSummary>>{};
    for (var i = 0; i < flattened.length; i++) {
      final item = flattened[i];
      final material = _genshinService.getMaterialByImage(item.fullImagePath);

      MaterialSummary newValue;
      AscensionMaterialSummaryType key;

      if (material.isFromBoss) {
        key = AscensionMaterialSummaryType.worldBoss;
        newValue = MaterialSummary.fromBoss(
          key: material.key,
          materialType: item.materialType,
          fullImagePath: item.fullImagePath,
          quantity: item.quantity,
        );
      } else if (material.days.isNotEmpty) {
        key = AscensionMaterialSummaryType.day;
        newValue = MaterialSummary.fromDays(
          key: material.key,
          materialType: item.materialType,
          fullImagePath: item.fullImagePath,
          quantity: item.quantity,
          days: material.days,
        );
      } else {
        switch (material.type) {
          case MaterialType.common:
            key = AscensionMaterialSummaryType.common;
            break;
          case MaterialType.local:
            key = AscensionMaterialSummaryType.local;
            break;
          case MaterialType.currency:
            key = AscensionMaterialSummaryType.currency;
            break;
          case MaterialType.weapon:
          case MaterialType.weaponPrimary:
            key = AscensionMaterialSummaryType.common;
            break;
          case MaterialType.elemental:
          case MaterialType.jewels:
          case MaterialType.talents:
          case MaterialType.others:
          case MaterialType.ingredient:
            key = AscensionMaterialSummaryType.others;
            break;
          case MaterialType.expWeapon:
          case MaterialType.expCharacter:
            key = AscensionMaterialSummaryType.exp;
            break;
        }
        newValue = MaterialSummary.others(
          key: material.key,
          materialType: material.type,
          fullImagePath: material.fullImagePath,
          quantity: item.quantity,
        );
      }

      if (summary.containsKey(key)) {
        summary[key].add(newValue);
      } else {
        summary.putIfAbsent(key, () => [newValue]);
      }

      summary[key].sort((x, y) => x.key.compareTo(y.key));
    }

    return summary.entries.map((entry) => AscensionMaterialsSummary(type: entry.key, materials: entry.value)).toList();
  }

  List<ItemAscensionMaterialModel> _getCharacterMaterialsToUse(
    CharacterFileModel char,
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
    List<CharacterSkill> skills,
  ) {
    final expMaterials = _getItemExperienceMaterials(currentLevel, desiredLevel, true);

    final ascensionMaterials =
        char.ascensionMaterials.where((m) => m.rank > currentAscensionLevel && m.rank <= desiredAscensionLevel).expand((e) => e.materials).toList();

    final skillMaterials = <ItemAscensionMaterialModel>[];

    if (char.talentAscensionMaterials.isNotEmpty) {
      for (final skill in skills) {
        final materials = char.talentAscensionMaterials
            .where((m) => m.level > skill.currentLevel && m.level <= skill.desiredLevel)
            .expand((m) => m.materials)
            .toList();

        skillMaterials.addAll(materials);
      }
    } else if (char.multiTalentAscensionMaterials != null && char.multiTalentAscensionMaterials.isNotEmpty) {
      //The traveler has different materials depending on the skill, that's why we need to retrieve the right amount for the provided skill
      //Also, we are assuming that the skill's order are fixed
      var talentNumber = 1;
      for (final skill in skills) {
        final materials = char.multiTalentAscensionMaterials
            .where((mt) => mt.number == talentNumber)
            .expand((mt) => mt.materials)
            .where((m) => m.level > skill.currentLevel && m.level <= skill.desiredLevel)
            .expand((m) => m.materials)
            .toList();

        skillMaterials.addAll(materials);

        talentNumber++;
      }
    }

    return _flatMaterialsList(expMaterials + ascensionMaterials + skillMaterials);
  }

  List<ItemAscensionMaterialModel> _getWeaponMaterialsToUse(
    WeaponFileModel weapon,
    int currentLevel,
    int desiredLevel,
    int currentAscensionLevel,
    int desiredAscensionLevel,
  ) {
    final expMaterials = _getItemExperienceMaterials(currentLevel, desiredLevel, false);
    final materials = weapon.ascensionMaterials
        .where((m) => m.level > _mapToWeaponLevel(currentAscensionLevel) && m.level <= _mapToWeaponLevel(desiredAscensionLevel))
        .expand((m) => m.materials)
        .toList();

    return _flatMaterialsList(expMaterials + materials);
  }

  List<ItemAscensionMaterialModel> _flatMaterialsList(List<ItemAscensionMaterialModel> current) {
    final materials = <ItemAscensionMaterialModel>[];
    for (final image in current.map((e) => e.fullImagePath).toSet().toList()) {
      final item = current.firstWhere((m) => m.fullImagePath == image);
      final int quantity = current.where((m) => m.fullImagePath == image).map((e) => e.quantity).fold(0, (previous, current) => previous + current);

      materials.add(item.copyWith.call(quantity: quantity));
    }

    return materials;
  }

  CalculatorAscMaterialsState _updateItem(int index, ItemAscensionMaterials updatedItem) {
    final items = [...currentState.items];
    items.removeAt(index);
    items.insert(index, updatedItem);
    final materialsForSummary = _buildMaterialsForSummary(items);
    return currentState.copyWith.call(items: items, summary: _generateSummary(materialsForSummary));
  }

  List<ItemAscensionMaterialModel> _buildMaterialsForSummary(List<ItemAscensionMaterials> items) {
    return items.where((i) => i.isActive).expand((i) => i.materials).toList();
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

  List<ItemAscensionMaterialModel> _getItemExperienceMaterials(int currentLevel, int desiredLevel, bool forCharacters) {
    final materials = <ItemAscensionMaterialModel>[];
    //Here we order the exp materials in a way that the one that gives more exp is first and so on
    final expMaterials = _genshinService.getMaterials(forCharacters ? MaterialType.expCharacter : MaterialType.expWeapon)
      ..sort((x, y) => (y.experienceAttributes.experience - x.experienceAttributes.experience).round());
    var requiredExp = getItemTotalExp(currentLevel, desiredLevel, forCharacters);
    final moraMaterial = _genshinService.getMaterials(MaterialType.currency).first;

    for (final material in expMaterials) {
      if (requiredExp <= 0) {
        break;
      }

      final matExp = material.experienceAttributes.experience;
      final quantity = (requiredExp / matExp).floor();
      if (quantity == 0) {
        continue;
      }
      materials.add(ItemAscensionMaterialModel(quantity: quantity, image: material.image, materialType: material.type));
      requiredExp -= quantity * matExp;

      final requiredMora = quantity * material.experienceAttributes.pricePerUsage;
      materials.add(ItemAscensionMaterialModel(quantity: requiredMora.round(), image: moraMaterial.image, materialType: moraMaterial.type));
    }

    return materials.reversed.toList();
  }
}
