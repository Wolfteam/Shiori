import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'weapon_bloc.freezed.dart';
part 'weapon_event.dart';
part 'weapon_state.dart';

class WeaponBloc extends Bloc<WeaponEvent, WeaponState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final DataService _dataService;
  final ResourceService _resourceService;

  WeaponBloc(this._genshinService, this._telemetryService, this._dataService, this._resourceService) : super(const WeaponState.loading());

  @override
  Stream<WeaponState> mapEventToState(WeaponEvent event) async* {
    final s = await event.when(
      loadFromKey: (key) async {
        final weapon = _genshinService.weapons.getWeapon(key);
        final translation = _genshinService.translations.getWeaponTranslation(weapon.key);
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
    final characters = _genshinService.characters.getCharacterForItemsUsingWeapon(weapon.key);
    final ascensionMaterials = weapon.ascensionMaterials.map((e) {
      final materials = e.materials.map((e) {
        final material = _genshinService.materials.getMaterialForCard(e.key);
        return ItemCommonWithQuantityAndName(e.key, material.name, material.image, material.image, e.quantity);
      }).toList();
      return WeaponAscensionModel(level: e.level, materials: materials);
    }).toList();

    final refinements = translation.refinements.mapIndexed((index, e) => WeaponFileRefinementModel(level: index + 1, description: e)).toList();

    final craftingMaterials = weapon.craftingMaterials.map((e) {
      final material = _genshinService.materials.getMaterialForCard(e.key);
      return ItemCommonWithQuantityAndName(e.key, material.name, material.image, material.image, e.quantity);
    }).toList();
    return WeaponState.loaded(
      key: weapon.key,
      name: translation.name,
      weaponType: weapon.type,
      fullImage: _resourceService.getWeaponImagePath(weapon.image, weapon.type),
      rarity: weapon.rarity,
      atk: weapon.atk,
      secondaryStat: weapon.secondaryStat,
      secondaryStatValue: weapon.secondaryStatValue,
      description: translation.description,
      locationType: weapon.location,
      isInInventory: _dataService.inventory.isItemInInventory(weapon.key, ItemType.weapon),
      ascensionMaterials: ascensionMaterials,
      refinements: refinements,
      characters: characters,
      stats: weapon.stats,
      craftingMaterials: craftingMaterials,
    );
  }
}
