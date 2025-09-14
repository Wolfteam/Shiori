import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'inventory_bloc.freezed.dart';
part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GenshinService _genshinService;
  final DataService _dataService;
  final TelemetryService _telemetryService;

  late final List<StreamSubscription> _streamSubscriptions;

  InventoryBloc(
    this._genshinService,
    this._dataService,
    this._telemetryService,
  ) : super(const InventoryState.loaded(characters: [], weapons: [], materials: [])) {
    _streamSubscriptions = [
      _dataService.inventory.itemAddedToInventory.stream.listen((type) => add(InventoryEvent.refresh(type: type))),
      _dataService.inventory.itemDeletedFromInventory.stream.listen((type) => add(InventoryEvent.refresh(type: type))),
      _dataService.inventory.itemUpdatedInInventory.stream.listen((type) => add(InventoryEvent.refresh(type: type))),
    ];
    on<InventoryEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(InventoryEvent event, Emitter<InventoryState> emit) async {
    switch (event) {
      case InventoryEventInit():
        final characters = _dataService.inventory.getAllCharactersInInventory();
        final weapons = _dataService.inventory.getAllWeaponsInInventory();
        final materials = _dataService.inventory.getAllMaterialsInInventory();
        emit(InventoryState.loaded(characters: characters, weapons: weapons, materials: materials));
      case InventoryEventAddCharacter():
        await _telemetryService.trackItemAddedToInventory(event.key, 1);
        await _dataService.inventory.addCharacterToInventory(event.key, raiseEvent: false);
        emit(_refreshItems(ItemType.character));
      case InventoryEventAddWeapon():
        await _telemetryService.trackItemAddedToInventory(event.key, 1);
        await _dataService.inventory.addWeaponToInventory(event.key, raiseEvent: false);
        emit(_refreshItems(ItemType.weapon));
      case InventoryEventDeleteCharacter():
        await _telemetryService.trackItemDeletedFromInventory(event.key);
        await _dataService.inventory.deleteCharacterFromInventory(event.key, raiseEvent: false);
        emit(_refreshItems(ItemType.character));
      case InventoryEventDeleteWeapon():
        await _telemetryService.trackItemDeletedFromInventory(event.key);
        await _dataService.inventory.deleteWeaponFromInventory(event.key, raiseEvent: false);
        emit(_refreshItems(ItemType.weapon));
      case InventoryEventUpdateMaterial():
        await _telemetryService.trackItemUpdatedInInventory(event.key, event.quantity);
        await _dataService.inventory.addMaterialToInventory(
          event.key,
          event.quantity,
          redistribute: _dataService.calculator.redistributeInventoryMaterial,
          raiseEvent: false,
        );
        emit(_refreshItems(ItemType.material));
      case InventoryEventClearAllCharacters():
        await _telemetryService.trackItemsDeletedFromInventory(ItemType.character);
        await _dataService.inventory.deleteItemsFromInventory(ItemType.character, raiseEvent: false);
        emit(state.copyWith.call(characters: []));
      case InventoryEventClearAllWeapons():
        await _telemetryService.trackItemsDeletedFromInventory(ItemType.weapon);
        await _dataService.inventory.deleteItemsFromInventory(ItemType.weapon, raiseEvent: false);
        emit(state.copyWith.call(weapons: []));
      case InventoryEventClearAllMaterials():
        await _telemetryService.trackItemsDeletedFromInventory(ItemType.material);
        await _dataService.inventory.deleteItemsFromInventory(ItemType.material, raiseEvent: false);
        emit(_refreshItems(ItemType.material));
      case InventoryEventRefresh():
        emit(_refreshItems(event.type));
    }
  }

  @override
  Future<void> close() async {
    await Future.wait(_streamSubscriptions.map((e) => e.cancel()));
    await super.close();
  }

  InventoryState _refreshItems(ItemType type) {
    switch (type) {
      case ItemType.character:
        return state.copyWith.call(characters: _dataService.inventory.getAllCharactersInInventory());
      case ItemType.weapon:
        return state.copyWith.call(weapons: _dataService.inventory.getAllWeaponsInInventory());
      case ItemType.artifact:
        throw Exception('Not implemented');
      case ItemType.material:
        return state.copyWith.call(materials: _dataService.inventory.getAllMaterialsInInventory());
    }
  }

  List<String> getItemsKeysToExclude() {
    final upcoming = _genshinService.getUpcomingKeys();
    return state.characters.map((e) => e.key).toList() + state.weapons.map((e) => e.key).toList() + upcoming;
  }
}
