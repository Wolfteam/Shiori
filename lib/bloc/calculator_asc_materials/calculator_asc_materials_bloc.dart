import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/assets.dart';
import '../../common/enums/ascension_material_summary_type.dart';
import '../../common/enums/material_type.dart';
import '../../models/models.dart';
import '../../services/genshing_service.dart';

part 'calculator_asc_materials_bloc.freezed.dart';
part 'calculator_asc_materials_event.dart';
part 'calculator_asc_materials_state.dart';

class CalculatorAscMaterialsBloc extends Bloc<CalculatorAscMaterialsEvent, CalculatorAscMaterialsState> {
  final GenshinService _genshinService;

  _InitialState get currentState => state as _InitialState;

  CalculatorAscMaterialsBloc(this._genshinService)
      : super(const CalculatorAscMaterialsState.initial(items: [], summary: []));

  @override
  Stream<CalculatorAscMaterialsState> mapEventToState(
    CalculatorAscMaterialsEvent event,
  ) async* {
    final s = event.map(
      init: (_) => const CalculatorAscMaterialsState.initial(items: [], summary: []),
      addCharacter: (e) {
        final char = _genshinService.getCharacter(e.key);
        final translation = _genshinService.getCharacterTranslation(e.key);

        final items = [
          ...currentState.items,
          ItemAscentionMaterials.forCharacters(
            key: e.key,
            image: Assets.getCharacterPath(char.image),
            name: translation.name,
            rarity: char.rarity,
            materials: _getCharacterMaterialsToUse(char, e.currentLevel, e.desiredLevel, e.skills),
            currentLevel: e.currentLevel,
            desiredLevel: e.desiredLevel,
            skills: e.skills,
          )
        ];

        return currentState.copyWith
            .call(items: items, summary: _generateSummary(items.expand((i) => i.materials).toList()));
      },
      addWeapon: (e) {
        final weapon = _genshinService.getWeapon(e.key);
        final translation = _genshinService.getWeaponTranslation(e.key);
        final items = [
          ...currentState.items,
          ItemAscentionMaterials.forWeapons(
            key: e.key,
            image: weapon.fullImagePath,
            name: translation.name,
            rarity: weapon.rarity,
            materials: _getWeaponMaterialsToUse(weapon, e.currentLevel, e.desiredLevel),
            currentLevel: e.currentLevel,
            desiredLevel: e.desiredLevel,
          )
        ];
        return currentState.copyWith
            .call(items: items, summary: _generateSummary(items.expand((i) => i.materials).toList()));
      },
      removeItem: (e) {
        final items = [...currentState.items];
        items.removeAt(e.index);
        return currentState.copyWith
            .call(items: items, summary: _generateSummary(items.expand((i) => i.materials).toList()));
      },
      updateCharacter: (e) {
        final currentChar = currentState.items.elementAt(e.index);
        final char = _genshinService.getCharacter(currentChar.key);
        final updatedChar = currentChar.copyWith.call(
          materials: _getCharacterMaterialsToUse(char, e.currentLevel, e.desiredLevel, e.skills),
          currentLevel: e.currentLevel,
          desiredLevel: e.desiredLevel,
          skills: e.skills,
        );

        return _updateItem(e.index, updatedChar);
      },
      updateWeapon: (e) {
        final currentWeapon = currentState.items.elementAt(e.index);
        final weapon = _genshinService.getWeapon(currentWeapon.key);
        final updatedWeapon = currentWeapon.copyWith.call(
          materials: _getWeaponMaterialsToUse(weapon, e.currentLevel, e.desiredLevel),
          currentLevel: e.currentLevel,
          desiredLevel: e.desiredLevel,
        );

        return _updateItem(e.index, updatedWeapon);
      },
    );

    yield s;
  }

  ItemAscentionMaterials getItem(int index) {
    return currentState.items.elementAt(index);
  }

  List<AscensionMaterialsSummary> _generateSummary(List<ItemAscentionMaterialModel> current) {
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
            key = AscensionMaterialSummaryType.others;
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

  List<ItemAscentionMaterialModel> _getCharacterMaterialsToUse(
    CharacterFileModel char,
    int currentLevel,
    int desiredLevel,
    List<CharacterSkill> skills,
  ) {
    final ascensionMaterials = char.ascentionMaterials
        .where((m) => m.rank > currentLevel && m.rank <= desiredLevel)
        .expand((e) => e.materials)
        .toList();

    final skillMaterials = <ItemAscentionMaterialModel>[];

    for (final skill in skills) {
      final materials = char.talentAscentionMaterials
          .where((m) => m.level > skill.currentLevel && m.level <= skill.desiredLevel)
          .expand((m) => m.materials)
          .toList();

      skillMaterials.addAll(materials);
    }

    if (char.multiTalentAscentionMaterials != null && char.multiTalentAscentionMaterials.isNotEmpty) {
//TODO: WHAT SHOULD I DO HERE ?
    }

    return _flatMaterialsList(ascensionMaterials + skillMaterials);
  }

  List<ItemAscentionMaterialModel> _getWeaponMaterialsToUse(
    WeaponFileModel weapon,
    int currentLevel,
    int desiredLevel,
  ) {
    final materials = weapon.ascentionMaterials
        .where((m) => m.level > _mapToWeaponLevel(currentLevel) && m.level <= _mapToWeaponLevel(desiredLevel))
        .expand((m) => m.materials)
        .toList();

    return _flatMaterialsList(materials);
  }

  List<ItemAscentionMaterialModel> _flatMaterialsList(List<ItemAscentionMaterialModel> current) {
    final materials = <ItemAscentionMaterialModel>[];
    for (final image in current.map((e) => e.fullImagePath).toSet().toList()) {
      final item = current.firstWhere((m) => m.fullImagePath == image);
      final int quantity = current
          .where((m) => m.fullImagePath == image)
          .map((e) => e.quantity)
          .fold(0, (previous, current) => previous + current);

      materials.add(item.copyWith.call(quantity: quantity));
    }

    return materials;
  }

  CalculatorAscMaterialsState _updateItem(int index, ItemAscentionMaterials updatedItem) {
    final items = [...currentState.items];
    items.removeAt(index);
    items.insert(index, updatedItem);
    return currentState.copyWith
        .call(items: items, summary: _generateSummary(items.expand((i) => i.materials).toList()));
  }

  int _mapToWeaponLevel(int val) {
    switch (val) {
      //Here we consider the 0, because otherwise we will always start from a current level of 1, and sometimes, we want to know the whole thing
      //(from 1 to 10 with 1 inclusive)
      case 0:
        return 0;
      case 1:
        return 20;
      case 2:
        return 40;
      case 3:
        return 50;
      case 4:
        return 60;
      case 5:
        return 70;
      case 6:
        return 80;
      default:
        throw Exception('The provided value = $val is not mapped');
    }
  }
}
