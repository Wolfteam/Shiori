import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/common/pop_bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'weapon_bloc.freezed.dart';
part 'weapon_event.dart';
part 'weapon_state.dart';

class WeaponBloc extends PopBloc<WeaponEvent, WeaponState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final DataService _dataService;

  WeaponBloc(this._genshinService, this._telemetryService, this._dataService) : super(const WeaponState.loading());

  @override
  WeaponEvent getEventForPop(String? key) => WeaponEvent.loadFromKey(key: key!, addToQueue: false);

  @override
  Stream<WeaponState> mapEventToState(
    WeaponEvent event,
  ) async* {
    if (event is! _AddedToInventory) {
      yield const WeaponState.loading();
    }

    final s = await event.when(
      loadFromKey: (key, addToQueue) async {
        final weapon = _genshinService.getWeapon(key);
        final translation = _genshinService.getWeaponTranslation(weapon.key);

        if (addToQueue) {
          await _telemetryService.trackWeaponLoaded(key);
          currentItemsInStack.add(weapon.key);
        }
        return _buildInitialState(weapon, translation);
      },
      addedToInventory: (key, wasAdded) async {
        if (state is! _LoadedState) {
          return state;
        }

        final currentState = state as _LoadedState;
        if (currentState.key != key) {
          return state;
        }

        return currentState.copyWith.call(isInInventory: wasAdded);
      },
    );

    yield s;
  }

  WeaponState _buildInitialState(WeaponFileModel weapon, TranslationWeaponFile translation) {
    final charImgs = _genshinService.getCharacterForItemsUsingWeapon(weapon.key);
    final ascensionMaterials = weapon.ascensionMaterials.map((e) {
      final materials = e.materials.map((e) {
        final material = _genshinService.getMaterial(e.key);
        return ItemAscensionMaterialModel(key: material.key, type: material.type, quantity: e.quantity, image: material.fullImagePath);
      }).toList();
      return WeaponAscensionModel(level: e.level, materials: materials);
    }).toList();

    final refinements = weapon.refinements.where((el) => el.values.isNotEmpty).map(
      (e) {
        var description = translation.refinement ?? '';
        for (var i = 0; i < e.values.length; i++) {
          description = description.replaceFirst('{$i}', e.values[i]);
        }

        return WeaponFileRefinementModel(level: e.level, description: description);
      },
    ).toList();

    final craftingMaterials = weapon.craftingMaterials.map((e) {
      final material = _genshinService.getMaterial(e.key);
      return ItemAscensionMaterialModel(key: e.key, type: material.type, quantity: e.quantity, image: material.fullImagePath);
    }).toList();
    return WeaponState.loaded(
      key: weapon.key,
      name: translation.name,
      weaponType: weapon.type,
      fullImage: weapon.fullImagePath,
      rarity: weapon.rarity,
      atk: weapon.atk,
      secondaryStat: weapon.secondaryStat,
      secondaryStatValue: weapon.secondaryStatValue,
      description: translation.description,
      locationType: weapon.location,
      isInInventory: _dataService.isItemInInventory(weapon.key, ItemType.weapon),
      ascensionMaterials: ascensionMaterials,
      refinements: refinements,
      characters: charImgs,
      stats: weapon.stats,
      craftingMaterials: craftingMaterials,
    );
  }
}
