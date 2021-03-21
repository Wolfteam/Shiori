import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';
import 'package:meta/meta.dart';

part 'inventory_bloc.freezed.dart';
part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final DataService _dataService;
  final TelemetryService _telemetryService;
  final CharacterBloc _characterBloc;
  final WeaponBloc _weaponBloc;

  _LoadedState get currentState => state as _LoadedState;

  InventoryBloc(this._dataService, this._telemetryService, this._characterBloc, this._weaponBloc) : super(const InventoryState.loading());

  @override
  Stream<InventoryState> mapEventToState(InventoryEvent event) async* {
    final bool isLoading = state is _LoadingState;
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

        if (isLoading) {
          return state;
        }

        final characters = _dataService.getAllCharactersInInventory();
        return currentState.copyWith.call(characters: characters);
      },
      addWeapon: (e) async {
        await _telemetryService.trackItemAddedToInventory(e.key, 1);
        await _dataService.addItemToInventory(e.key, ItemType.weapon, 1);
        _weaponBloc.add(WeaponEvent.addedToInventory(key: e.key, wasAdded: true));

        if (isLoading) {
          return state;
        }

        final weapons = _dataService.getAllWeaponsInInventory();
        return currentState.copyWith.call(weapons: weapons);
      },
      deleteCharacter: (e) async {
        await _telemetryService.trackItemDeletedFromInventory(e.key);
        await _dataService.deleteItemFromInventory(e.key, ItemType.character);
        _characterBloc.add(CharacterEvent.addedToInventory(key: e.key, wasAdded: false));

        if (isLoading) {
          return state;
        }

        final characters = _dataService.getAllCharactersInInventory();
        return currentState.copyWith.call(characters: characters);
      },
      deleteWeapon: (e) async {
        await _telemetryService.trackItemDeletedFromInventory(e.key);
        await _dataService.deleteItemFromInventory(e.key, ItemType.weapon);
        _weaponBloc.add(WeaponEvent.addedToInventory(key: e.key, wasAdded: false));

        if (isLoading) {
          return state;
        }

        final weapons = _dataService.getAllWeaponsInInventory();
        return currentState.copyWith.call(weapons: weapons);
      },
      updateMaterial: (e) async {
        await _telemetryService.trackItemUpdatedInInventory(e.key, e.quantity);
        await _dataService.updateItemInInventory(e.key, ItemType.material, e.quantity);

        if (isLoading) {
          return state;
        }

        final materials = _dataService.getAllMaterialsInInventory();
        return currentState.copyWith.call(materials: materials);
      },
      close: (_) async => const InventoryState.loaded(characters: [], weapons: [], materials: []),
    );

    yield s;
  }
}
