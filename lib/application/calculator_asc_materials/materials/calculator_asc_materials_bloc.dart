import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'calculator_asc_materials_bloc.freezed.dart';
part 'calculator_asc_materials_event.dart';
part 'calculator_asc_materials_state.dart';

const _initialState = CalculatorAscMaterialsState.initial(sessionKey: -1, items: [], summary: []);

class CalculatorAscMaterialsBloc extends Bloc<CalculatorAscMaterialsEvent, CalculatorAscMaterialsState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final CalculatorService _calculatorService;
  final DataService _dataService;
  final ResourceService _resourceService;

  _InitialState get currentState => state as _InitialState;

  CalculatorAscMaterialsBloc(
    this._genshinService,
    this._telemetryService,
    this._calculatorService,
    this._dataService,
    this._resourceService,
  ) : super(_initialState);

  @override
  Stream<CalculatorAscMaterialsState> mapEventToState(
    CalculatorAscMaterialsEvent event,
  ) async* {
    final s = await event.map(
      init: (e) async => _init(e.sessionKey),
      addCharacter: (e) async => _addCharacter(e),
      addWeapon: (e) async => _addWeapon(e),
      removeItem: (e) async => _removeItem(e),
      updateCharacter: (e) async => _updateCharacter(e),
      updateWeapon: (e) async => _updateWeapon(e),
      clearAllItems: (e) async => _clearAllItems(e.sessionKey),
      itemsReordered: (e) async => _itemsReordered(e.updated),
    );

    yield s;
  }

  CalculatorAscMaterialsState _init(int sessionKey) {
    final items = _dataService.calculator.getAllSessionItems(sessionKey);
    final materialsForSummary = _buildMaterialsForSummary(items);
    final summary = _calculatorService.generateSummary(materialsForSummary);
    return CalculatorAscMaterialsState.initial(sessionKey: sessionKey, items: items, summary: summary);
  }

  Future<CalculatorAscMaterialsState> _addCharacter(_AddCharacter e) async {
    await _telemetryService.trackCalculatorItemAscMaterialLoaded(e.key);
    final char = _genshinService.characters.getCharacter(e.key);
    final translation = _genshinService.translations.getCharacterTranslation(e.key);
    final newItem = ItemAscensionMaterials.forCharacters(
      key: e.key,
      image: _resourceService.getCharacterImagePath(char.image),
      position: currentState.items.length,
      elementType: char.elementType,
      name: translation.name,
      rarity: char.rarity,
      materials: _calculatorService.getCharacterMaterialsToUse(
        char,
        e.currentLevel,
        e.desiredLevel,
        e.currentAscensionLevel,
        e.desiredAscensionLevel,
        e.skills,
      ),
      currentLevel: e.currentLevel,
      desiredLevel: e.desiredLevel,
      skills: e.skills,
      desiredAscensionLevel: e.desiredAscensionLevel,
      currentAscensionLevel: e.currentAscensionLevel,
      useMaterialsFromInventory: e.useMaterialsFromInventory,
    );

    final allPossibleMaterialKeys = _calculatorService.getAllCharacterPossibleMaterialsToUse(char).map((e) => e.key).toList();
    await _dataService.calculator.addCalAscMatSessionItem(e.sessionKey, newItem, allPossibleMaterialKeys);
    return _init(e.sessionKey);
  }

  Future<CalculatorAscMaterialsState> _addWeapon(_AddWeapon e) async {
    await _telemetryService.trackCalculatorItemAscMaterialLoaded(e.key);
    final weapon = _genshinService.weapons.getWeapon(e.key);
    final translation = _genshinService.translations.getWeaponTranslation(e.key);
    final newItem = ItemAscensionMaterials.forWeapons(
      key: e.key,
      image: _resourceService.getWeaponImagePath(weapon.image, weapon.type),
      position: currentState.items.length,
      name: translation.name,
      rarity: weapon.rarity,
      materials: _calculatorService.getWeaponMaterialsToUse(
        weapon,
        e.currentLevel,
        e.desiredLevel,
        e.currentAscensionLevel,
        e.desiredAscensionLevel,
      ),
      currentLevel: e.currentLevel,
      desiredLevel: e.desiredLevel,
      desiredAscensionLevel: e.desiredAscensionLevel,
      currentAscensionLevel: e.currentAscensionLevel,
      useMaterialsFromInventory: e.useMaterialsFromInventory,
    );
    final allPossibleMaterialKeys = _calculatorService.getAllWeaponPossibleMaterialsToUse(weapon).map((e) => e.key).toList();
    await _dataService.calculator.addCalAscMatSessionItem(e.sessionKey, newItem, allPossibleMaterialKeys);
    return _init(e.sessionKey);
  }

  Future<CalculatorAscMaterialsState> _removeItem(_RemoveItem e) async {
    final itemsToLoop = [...currentState.items];
    //The saved position may be different, so that's why we don't use the index to delete
    //this item
    final itemToDelete = itemsToLoop.elementAt(e.index);
    final itemPosition = itemToDelete.position;
    final possibleMaterialItemKeys = _calculatorService.getAllPossibleMaterialKeysToUse(itemToDelete.key, itemToDelete.isCharacter);
    itemsToLoop.removeAt(e.index);

    await _dataService.calculator.deleteCalAscMatSessionItem(e.sessionKey, itemPosition, redistribute: false);

    for (int i = 0; i < itemsToLoop.length; i++) {
      final item = itemsToLoop[i];
      await _dataService.calculator.updateCalAscMatSessionItem(e.sessionKey, i, item, [], redistribute: false);
    }

    await _dataService.calculator.redistributeInventoryMaterialsFromSessionPosition(e.sessionKey, onlyMaterialKeys: possibleMaterialItemKeys);
    return _init(e.sessionKey);
  }

  Future<CalculatorAscMaterialsState> _updateCharacter(_UpdateCharacter e) {
    final currentChar = currentState.items.elementAt(e.index);
    final char = _genshinService.characters.getCharacter(currentChar.key);
    final updatedChar = currentChar.copyWith.call(
      materials: _calculatorService.getCharacterMaterialsToUse(
        char,
        e.currentLevel,
        e.desiredLevel,
        e.currentAscensionLevel,
        e.desiredAscensionLevel,
        e.skills,
      ),
      currentLevel: e.currentLevel,
      desiredLevel: e.desiredLevel,
      skills: e.skills,
      desiredAscensionLevel: e.desiredAscensionLevel,
      currentAscensionLevel: e.currentAscensionLevel,
      isActive: e.isActive,
      position: e.index,
      useMaterialsFromInventory: e.useMaterialsFromInventory,
    );

    final allPossibleMaterialKeys = _calculatorService.getAllCharacterPossibleMaterialsToUse(char).map((e) => e.key).toList();
    return _updateItem(e.sessionKey, e.index, updatedChar, allPossibleMaterialKeys);
  }

  Future<CalculatorAscMaterialsState> _updateWeapon(_UpdateWeapon e) {
    final currentWeapon = currentState.items.elementAt(e.index);
    final weapon = _genshinService.weapons.getWeapon(currentWeapon.key);
    final updatedWeapon = currentWeapon.copyWith.call(
      materials: _calculatorService.getWeaponMaterialsToUse(
        weapon,
        e.currentLevel,
        e.desiredLevel,
        e.currentAscensionLevel,
        e.desiredAscensionLevel,
      ),
      currentLevel: e.currentLevel,
      desiredLevel: e.desiredLevel,
      desiredAscensionLevel: e.desiredAscensionLevel,
      currentAscensionLevel: e.currentAscensionLevel,
      isActive: e.isActive,
      position: e.index,
      useMaterialsFromInventory: e.useMaterialsFromInventory,
    );

    final allPossibleMaterialKeys = _calculatorService.getAllWeaponPossibleMaterialsToUse(weapon).map((e) => e.key).toList();
    return _updateItem(e.sessionKey, e.index, updatedWeapon, allPossibleMaterialKeys);
  }

  Future<CalculatorAscMaterialsState> _clearAllItems(int sessionKey) async {
    await _dataService.calculator.deleteAllCalAscMatSessionItems(sessionKey);
    return CalculatorAscMaterialsState.initial(sessionKey: sessionKey, items: [], summary: []);
  }

  Future<CalculatorAscMaterialsState> _itemsReordered(List<ItemAscensionMaterials> updated) async {
    await _dataService.calculator.reorderItems(currentState.sessionKey, currentState.items, updated);
    return _init(currentState.sessionKey);
  }

  ItemAscensionMaterials getItem(int index) => currentState.items.elementAt(index);

  List<String> getItemsKeysToExclude() => currentState.items.map((e) => e.key).toList();

  Future<CalculatorAscMaterialsState> _updateItem(
    int sessionKey,
    int index,
    ItemAscensionMaterials updatedItem,
    List<String> allPossibleItemMaterialsKeys,
  ) async {
    await _dataService.calculator.updateCalAscMatSessionItem(sessionKey, index, updatedItem, allPossibleItemMaterialsKeys);
    return _init(sessionKey);
  }

  List<ItemAscensionMaterialModel> _buildMaterialsForSummary(List<ItemAscensionMaterials> items) {
    return items.where((i) => i.isActive).expand((i) => i.materials).toList();
  }
}
