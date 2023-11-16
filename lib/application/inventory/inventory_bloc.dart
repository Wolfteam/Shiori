import 'dart:async';

import 'package:bloc/bloc.dart';
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
  }

  @override
  Stream<InventoryState> mapEventToState(InventoryEvent event) async* {
    final s = await event.map(
      init: (_) async {
        final characters = _dataService.inventory.getAllCharactersInInventory();
        final weapons = _dataService.inventory.getAllWeaponsInInventory();
        final materials = _dataService.inventory.getAllMaterialsInInventory();

        return InventoryState.loaded(characters: characters, weapons: weapons, materials: materials);
      },
      addCharacter: (e) async {
        await _telemetryService.trackItemAddedToInventory(e.key, 1);
        await _dataService.inventory.addCharacterToInventory(e.key, raiseEvent: false);
        return _refreshItems(ItemType.character);
      },
      addWeapon: (e) async {
        await _telemetryService.trackItemAddedToInventory(e.key, 1);
        await _dataService.inventory.addWeaponToInventory(e.key, raiseEvent: false);
        return _refreshItems(ItemType.weapon);
      },
      deleteCharacter: (e) async {
        await _telemetryService.trackItemDeletedFromInventory(e.key);
        await _dataService.inventory.deleteCharacterFromInventory(e.key, raiseEvent: false);
        return _refreshItems(ItemType.character);
      },
      deleteWeapon: (e) async {
        await _telemetryService.trackItemDeletedFromInventory(e.key);
        await _dataService.inventory.deleteWeaponFromInventory(e.key, raiseEvent: false);
        return _refreshItems(ItemType.weapon);
      },
      updateMaterial: (e) async {
        await _telemetryService.trackItemUpdatedInInventory(e.key, e.quantity);
        await _dataService.inventory.addMaterialToInventory(
          e.key,
          e.quantity,
          redistribute: _dataService.calculator.redistributeInventoryMaterial,
          raiseEvent: false,
        );
        return _refreshItems(ItemType.material);
      },
      clearAllCharacters: (_) async {
        await _telemetryService.trackItemsDeletedFromInventory(ItemType.character);
        await _dataService.inventory.deleteItemsFromInventory(ItemType.character, raiseEvent: false);
        return state.copyWith.call(characters: []);
      },
      clearAllWeapons: (_) async {
        await _telemetryService.trackItemsDeletedFromInventory(ItemType.weapon);
        await _dataService.inventory.deleteItemsFromInventory(ItemType.weapon, raiseEvent: false);
        return state.copyWith.call(weapons: []);
      },
      clearAllMaterials: (_) async {
        await _telemetryService.trackItemsDeletedFromInventory(ItemType.material);
        await _dataService.inventory.deleteItemsFromInventory(ItemType.material, raiseEvent: false);
        return _refreshItems(ItemType.material);
      },
      refresh: (e) async => _refreshItems(e.type),
    );

    yield s;
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
    return state.maybeMap(
      loaded: (state) => state.characters.map((e) => e.key).toList() + state.weapons.map((e) => e.key).toList() + upcoming,
      orElse: () => upcoming,
    );
  }
}
