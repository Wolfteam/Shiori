import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'weapon_bloc.freezed.dart';
part 'weapon_event.dart';
part 'weapon_state.dart';

class WeaponBloc extends Bloc<WeaponEvent, WeaponState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final DataService _dataService;

  WeaponBloc(this._genshinService, this._telemetryService, this._dataService) : super(const WeaponState.loading());

  @override
  Stream<WeaponState> mapEventToState(WeaponEvent event) async* {
    final s = await event.when(
      loadFromKey: (key) async {
        final weapon = _genshinService.getWeapon(key);
        final translation = _genshinService.getWeaponTranslation(weapon.key);
        await _telemetryService.trackWeaponLoaded(key);
        return _buildInitialState(weapon, translation);
      },
      addToInventory: (key) async => state.map(
        loading: (state) async => state,
        loaded: (state) async {
          await _telemetryService.trackItemAddedToInventory(key, 1);
          await _dataService.inventory.addWeaponToInventory(key);
          return state.copyWith.call(isInInventory: true);
        },
      ),
      deleteFromInventory: (key) async => state.map(
        loading: (state) async => state,
        loaded: (state) async {
          await _telemetryService.trackItemDeletedFromInventory(key);
          await _dataService.inventory.deleteWeaponFromInventory(key);
          return state.copyWith.call(isInInventory: false);
        },
      ),
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

    final refinements = translation.refinements.mapIndexed((index, e) => WeaponFileRefinementModel(level: index + 1, description: e)).toList();

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
      isInInventory: _dataService.inventory.isItemInInventory(weapon.key, ItemType.weapon),
      ascensionMaterials: ascensionMaterials,
      refinements: refinements,
      characters: charImgs,
      stats: weapon.stats,
      craftingMaterials: craftingMaterials,
    );
  }
}
