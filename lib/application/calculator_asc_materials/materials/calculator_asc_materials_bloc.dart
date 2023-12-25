import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'calculator_asc_materials_bloc.freezed.dart';
part 'calculator_asc_materials_event.dart';
part 'calculator_asc_materials_state.dart';

const _initialState = CalculatorAscMaterialsState.initial(sessionKey: -1, items: [], summary: [], showMaterialUsage: false);

class CalculatorAscMaterialsBloc extends Bloc<CalculatorAscMaterialsEvent, CalculatorAscMaterialsState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final CalculatorAscMaterialsService _calculatorService;
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
  Stream<CalculatorAscMaterialsState> mapEventToState(CalculatorAscMaterialsEvent event) async* {
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
    final session = _dataService.calculator.getSession(sessionKey);
    final items = _dataService.calculator.getAllSessionItems(sessionKey);
    final materialsForSummary = _buildMaterialsForSummary(items);
    final summary = _calculatorService.generateSummary(materialsForSummary);
    return CalculatorAscMaterialsState.initial(sessionKey: sessionKey, items: items, summary: summary, showMaterialUsage: session.showMaterialUsage);
  }

  Future<CalculatorAscMaterialsState> _addCharacter(_AddCharacter e) async {
    _checkSessionKey(e.sessionKey);
    _checkKeyNotInSession(e.key, true);
    _checkLevels(e.currentLevel, e.desiredLevel);
    _checkAscLevels(e.currentAscensionLevel, e.desiredAscensionLevel);
    _checkSkills(e.skills);

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
    await _dataService.calculator.addSessionItem(e.sessionKey, newItem, allPossibleMaterialKeys);
    return _init(e.sessionKey);
  }

  Future<CalculatorAscMaterialsState> _addWeapon(_AddWeapon e) async {
    _checkSessionKey(e.sessionKey);
    _checkKeyNotInSession(e.key, false);
    _checkLevels(e.currentLevel, e.desiredLevel);
    _checkAscLevels(e.currentAscensionLevel, e.desiredAscensionLevel);

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
    await _dataService.calculator.addSessionItem(e.sessionKey, newItem, allPossibleMaterialKeys);
    return _init(e.sessionKey);
  }

  Future<CalculatorAscMaterialsState> _removeItem(_RemoveItem e) async {
    _checkSessionKey(e.sessionKey);
    _checkItemIndex(e.index);

    final itemsToLoop = [...currentState.items];
    //The saved position may be different, so that's why we don't use the index to delete
    //this item
    final itemToDelete = itemsToLoop.elementAt(e.index);
    final itemPosition = itemToDelete.position;
    final possibleMaterialItemKeys = _calculatorService.getAllPossibleMaterialKeysToUse(itemToDelete.key, itemToDelete.isCharacter);
    itemsToLoop.removeAt(e.index);

    await _dataService.calculator.deleteSessionItem(e.sessionKey, itemPosition, redistribute: false);

    for (int i = 0; i < itemsToLoop.length; i++) {
      final item = itemsToLoop[i];
      await _dataService.calculator.updateSessionItem(e.sessionKey, i, item, [], redistribute: false);
    }

    await _dataService.calculator.redistributeInventoryMaterialsFromSessionPosition(e.sessionKey, onlyMaterialKeys: possibleMaterialItemKeys);
    return _init(e.sessionKey);
  }

  Future<CalculatorAscMaterialsState> _updateCharacter(_UpdateCharacter e) {
    _checkSessionKey(e.sessionKey);
    _checkItemIndex(e.index);
    _checkLevels(e.currentLevel, e.desiredLevel);
    _checkAscLevels(e.currentAscensionLevel, e.desiredAscensionLevel);
    _checkSkills(e.skills);

    final currentChar = currentState.items.elementAt(e.index);
    if (!currentChar.isCharacter) {
      throw Exception('Item = ${currentChar.key} at index = ${e.index} is not a character');
    }
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
    _checkSessionKey(e.sessionKey);
    _checkItemIndex(e.index);
    _checkLevels(e.currentLevel, e.desiredLevel);
    _checkAscLevels(e.currentAscensionLevel, e.desiredAscensionLevel);

    final currentWeapon = currentState.items.elementAt(e.index);
    if (!currentWeapon.isWeapon) {
      throw Exception('Item = ${currentWeapon.key} at index = ${e.index} is not a weapon');
    }

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
    _checkSessionKey(sessionKey);
    await _dataService.calculator.deleteAllSessionItems(sessionKey);
    return currentState.copyWith(items: [], summary: []);
  }

  Future<CalculatorAscMaterialsState> _itemsReordered(List<ItemAscensionMaterials> updated) async {
    _checkSessionKey(state.sessionKey);
    if (updated.isEmpty) {
      throw Exception('The updated reordered items are empty');
    }

    await _dataService.calculator.reorderItems(currentState.sessionKey, updated);
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
    await _dataService.calculator.updateSessionItem(sessionKey, index, updatedItem, allPossibleItemMaterialsKeys);
    return _init(sessionKey);
  }

  List<ItemAscensionMaterialModel> _buildMaterialsForSummary(List<ItemAscensionMaterials> items) {
    return items.where((i) => i.isActive).expand((i) => i.materials).toList();
  }

  void _checkSessionKey(int sessionKey) {
    if (sessionKey < 0) {
      throw Exception('SessionKey = $sessionKey is not valid');
    }
  }

  void _checkKeyNotInSession(String key, bool isCharacter) {
    if (isCharacter && state.items.any((el) => el.key == key && el.isCharacter)) {
      throw Exception('Character = $key is already in the session');
    }

    if (!isCharacter && state.items.any((el) => el.key == key && el.isWeapon)) {
      throw Exception('Weapon = $key is already in the session');
    }
  }

  void _checkItemIndex(int index) {
    if (index < 0 || index >= state.items.length) {
      throw Exception('Index = $index is not valid');
    }

    if (state.items.elementAtOrNull(index) == null) {
      throw Exception('No item was found at index = $index');
    }
  }

  void _checkLevels(int currentLevel, int desiredLevel) {
    if (currentLevel < minItemLevel || currentLevel > maxItemLevel) {
      throw Exception('Current level = $currentLevel is not valid');
    }

    if (desiredLevel < minItemLevel || desiredLevel > maxItemLevel) {
      throw Exception('Desired level = $desiredLevel is not valid');
    }
  }

  void _checkAscLevels(int currentAscLevel, int desiredAscLevel) {
    if (currentAscLevel < 0 || currentAscLevel > itemAscensionLevelMap.entries.last.key) {
      throw Exception('Current asc level = $currentAscLevel is not valid');
    }

    if (desiredAscLevel < 0 || desiredAscLevel > itemAscensionLevelMap.entries.last.key) {
      throw Exception('Desired asc level = $desiredAscLevel is not valid');
    }
  }

  void _checkSkills(List<CharacterSkill> skills) {
    if (skills.isEmpty) {
      throw Exception('Skills are empty');
    }
    for (final skill in skills) {
      if (skill.currentLevel < minSkillLevel || skill.currentLevel > maxSkillLevel) {
        throw Exception('Skill current level = ${skill.currentLevel} is not valid');
      }

      if (skill.desiredLevel < minSkillLevel || skill.desiredLevel > maxSkillLevel) {
        throw Exception('Skill current level = ${skill.desiredLevel} is not valid');
      }
    }
  }
}
