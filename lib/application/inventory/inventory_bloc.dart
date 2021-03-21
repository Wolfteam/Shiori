import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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

  _LoadedState get currentState => state as _LoadedState;

  InventoryBloc(this._dataService, this._telemetryService) : super(const InventoryState.loading());

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

        final characters = _dataService.getAllCharactersInInventory();
        return currentState.copyWith.call(characters: characters);
      },
      addWeapon: (e) async {
        await _telemetryService.trackItemAddedToInventory(e.key, 1);
        await _dataService.addItemToInventory(e.key, ItemType.weapon, 1);

        final weapons = _dataService.getAllWeaponsInInventory();
        return currentState.copyWith.call(weapons: weapons);
      },
      deleteCharacter: (e) async {
        await _telemetryService.trackItemDeletedFromInventory(e.key);
        await _dataService.deleteItemFromInventory(e.key, ItemType.character);

        final characters = _dataService.getAllCharactersInInventory();
        return currentState.copyWith.call(characters: characters);
      },
      deleteWeapon: (e) async {
        await _telemetryService.trackItemDeletedFromInventory(e.key);
        await _dataService.deleteItemFromInventory(e.key, ItemType.weapon);

        final weapons = _dataService.getAllWeaponsInInventory();
        return currentState.copyWith.call(weapons: weapons);
      },
      updateMaterial: (e) async {
        await _telemetryService.trackItemUpdatedInInventory(e.key, e.quantity);
        await _dataService.updateItemInInventory(e.key, ItemType.material, e.quantity);

        final materials = _dataService.getAllMaterialsInInventory();
        return currentState.copyWith.call(materials: materials);
      },
      close: (_) async => const InventoryState.loaded(characters: [], weapons: [], materials: []),
    );

    yield s;
  }
}
