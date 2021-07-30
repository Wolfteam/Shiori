import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';
import 'package:meta/meta.dart';

part 'inventory_bloc.freezed.dart';
part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GenshinService _genshinService;
  final DataService _dataService;
  final TelemetryService _telemetryService;
  final CharacterBloc _characterBloc;
  final WeaponBloc _weaponBloc;

  InventoryBloc(
    this._genshinService,
    this._dataService,
    this._telemetryService,
    this._characterBloc,
    this._weaponBloc,
  ) : super(const InventoryState.loading());

  @override
  Stream<InventoryState> mapEventToState(InventoryEvent event) async* {
    final s = await event.map(
      init: (_) async {
        final characters = _dataService.getAllCharactersInInventory();
        final weapons = _dataService.getAllWeaponsInInventory();
        final materials = _dataService.getAllMaterialsInInventory();

        return InventoryState.loaded(characters: characters, weapons: weapons, materials: materials);
      },
      addCharacter: (e) async {
        await _telemetryService.trackItemAddedToInventory(e.key, 1);
        await _dataService.addItemToInventory(e.key, ItemType.character, 1);
        _characterBloc.add(CharacterEvent.addedToInventory(key: e.key, wasAdded: true));

        return state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith.call(characters: _dataService.getAllCharactersInInventory()),
        );
      },
      addWeapon: (e) async {
        await _telemetryService.trackItemAddedToInventory(e.key, 1);
        await _dataService.addItemToInventory(e.key, ItemType.weapon, 1);
        _weaponBloc.add(WeaponEvent.addedToInventory(key: e.key, wasAdded: true));

        return state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith.call(weapons: _dataService.getAllWeaponsInInventory()),
        );
      },
      deleteCharacter: (e) async {
        await _telemetryService.trackItemDeletedFromInventory(e.key);
        await _dataService.deleteItemFromInventory(e.key, ItemType.character);
        _characterBloc.add(CharacterEvent.addedToInventory(key: e.key, wasAdded: false));

        return state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith.call(characters: _dataService.getAllCharactersInInventory()),
        );
      },
      deleteWeapon: (e) async {
        await _telemetryService.trackItemDeletedFromInventory(e.key);
        await _dataService.deleteItemFromInventory(e.key, ItemType.weapon);
        _weaponBloc.add(WeaponEvent.addedToInventory(key: e.key, wasAdded: false));

        return state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith.call(weapons: _dataService.getAllWeaponsInInventory()),
        );
      },
      updateMaterial: (e) async {
        await _telemetryService.trackItemUpdatedInInventory(e.key, e.quantity);
        await _dataService.updateItemInInventory(e.key, ItemType.material, e.quantity);

        return state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith.call(materials: _dataService.getAllMaterialsInInventory()),
        );
      },
      close: (_) async => const InventoryState.loaded(characters: [], weapons: [], materials: []),
      clearAllCharacters: (_) async {
        await _telemetryService.trackItemsDeletedFromInventory(ItemType.character);
        await _dataService.deleteItemsFromInventory(ItemType.character);

        return state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith.call(characters: []),
        );
      },
      clearAllWeapons: (_) async {
        await _telemetryService.trackItemsDeletedFromInventory(ItemType.weapon);
        await _dataService.deleteItemsFromInventory(ItemType.weapon);

        return state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith.call(weapons: []),
        );
      },
      clearAllMaterials: (_) async {
        await _telemetryService.trackItemsDeletedFromInventory(ItemType.material);
        await _dataService.deleteItemsFromInventory(ItemType.material);

        return state.map(
          loading: (state) => state,
          loaded: (state) => state.copyWith.call(materials: _dataService.getAllMaterialsInInventory()),
        );
      },
    );

    yield s;
  }

  List<String> getItemsKeysToExclude() {
    final upcoming = _genshinService.getUpcomingKeys();
    return state.maybeMap(
      loaded: (state) => state.characters.map((e) => e.key).toList() + state.weapons.map((e) => e.key).toList() + upcoming,
      orElse: () => upcoming,
    );
  }
}
