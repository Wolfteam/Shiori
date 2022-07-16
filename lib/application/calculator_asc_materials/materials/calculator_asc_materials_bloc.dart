import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'calculator_asc_materials_bloc.freezed.dart';
part 'calculator_asc_materials_event.dart';
part 'calculator_asc_materials_state.dart';

const _initialState = CalculatorAscMaterialsState.initial(items: [], summary: []);

class CalculatorAscMaterialsBloc extends Bloc<CalculatorAscMaterialsEvent, CalculatorAscMaterialsState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final CalculatorService _calculatorService;
  final DataService _dataService;

  final CalculatorAscMaterialsSessionsBloc _calculatorAscMaterialsSessionsBloc;

  _InitialState get currentState => state as _InitialState;

  CalculatorAscMaterialsBloc(
    this._genshinService,
    this._telemetryService,
    this._calculatorService,
    this._dataService,
    this._calculatorAscMaterialsSessionsBloc,
  ) : super(_initialState);

  @override
  Stream<CalculatorAscMaterialsState> mapEventToState(
    CalculatorAscMaterialsEvent event,
  ) async* {
    final s = await event.map(
      init: (e) async {
        final session = _dataService.calculator.getCalcAscMatSession(e.sessionKey);
        final materialsForSummary = _buildMaterialsForSummary(session.items);
        final summary = _calculatorService.generateSummary(materialsForSummary);
        return CalculatorAscMaterialsState.initial(items: session.items, summary: summary);
      },
      addCharacter: (e) async {
        await _telemetryService.trackCalculatorItemAscMaterialLoaded(e.key);
        final char = _genshinService.getCharacter(e.key);
        final translation = _genshinService.getCharacterTranslation(e.key);
        var newItem = ItemAscensionMaterials.forCharacters(
          key: e.key,
          image: Assets.getCharacterPath(char.image),
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
        newItem = await _dataService.calculator.addCalAscMatSessionItem(e.sessionKey, newItem);
        final items = [...currentState.items, newItem];
        final materialsForSummary = _buildMaterialsForSummary(items);

        _notifyParent();
        return currentState.copyWith.call(items: items, summary: _calculatorService.generateSummary(materialsForSummary));
      },
      addWeapon: (e) async {
        await _telemetryService.trackCalculatorItemAscMaterialLoaded(e.key);
        final weapon = _genshinService.getWeapon(e.key);
        final translation = _genshinService.getWeaponTranslation(e.key);
        var newItem = ItemAscensionMaterials.forWeapons(
          key: e.key,
          image: weapon.fullImagePath,
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
        newItem = await _dataService.calculator.addCalAscMatSessionItem(e.sessionKey, newItem);
        final items = [...currentState.items, newItem];
        final materialsForSummary = _buildMaterialsForSummary(items);

        _notifyParent();
        return currentState.copyWith.call(items: items, summary: _calculatorService.generateSummary(materialsForSummary));
      },
      removeItem: (e) async {
        final itemsToLoop = [...currentState.items];
        //The saved position may be different, so that's why we don't use the index to delete
        //this item
        final itemPosition = itemsToLoop.elementAt(e.index).position;
        itemsToLoop.removeAt(e.index);

        await _dataService.calculator.deleteCalAscMatSessionItem(e.sessionKey, itemPosition, redistribute: false);

        for (var i = 0; i < itemsToLoop.length; i++) {
          final item = itemsToLoop[i];
          await _dataService.calculator.updateCalAscMatSessionItem(e.sessionKey, i, item, redistribute: false);
        }

        await _dataService.calculator.redistributeAllInventoryMaterials();

        final session = _dataService.calculator.getCalcAscMatSession(e.sessionKey);
        final materialsForSummary = _buildMaterialsForSummary(session.items);

        _notifyParent();
        return currentState.copyWith.call(items: session.items, summary: _calculatorService.generateSummary(materialsForSummary));
      },
      updateCharacter: (e) async {
        final currentChar = currentState.items.elementAt(e.index);
        final char = _genshinService.getCharacter(currentChar.key);
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
        return _updateItem(e.sessionKey, e.index, updatedChar);
      },
      updateWeapon: (e) async {
        final currentWeapon = currentState.items.elementAt(e.index);
        final weapon = _genshinService.getWeapon(currentWeapon.key);
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

        return _updateItem(e.sessionKey, e.index, updatedWeapon);
      },
      clearAllItems: (e) async {
        await _dataService.calculator.deleteAllCalAscMatSessionItems(e.sessionKey);
        return const CalculatorAscMaterialsState.initial(items: [], summary: []);
      },
    );

    yield s;
  }

  ItemAscensionMaterials getItem(int index) => currentState.items.elementAt(index);

  List<String> getItemsKeysToExclude() => currentState.items.map((e) => e.key).toList();

  Future<CalculatorAscMaterialsState> _updateItem(int sessionKey, int index, ItemAscensionMaterials updatedItem) async {
    final toAdd = await _dataService.calculator.updateCalAscMatSessionItem(sessionKey, index, updatedItem);
    final items = [...currentState.items];
    items.removeAt(index);
    items.insert(index, toAdd);

    final materialsForSummary = _buildMaterialsForSummary(items);
    return currentState.copyWith.call(items: items, summary: _calculatorService.generateSummary(materialsForSummary));
  }

  List<ItemAscensionMaterialModel> _buildMaterialsForSummary(List<ItemAscensionMaterials> items) {
    return items.where((i) => i.isActive).expand((i) => i.materials).toList();
  }

  void _notifyParent() => _calculatorAscMaterialsSessionsBloc.add(const CalculatorAscMaterialsSessionsEvent.init());
}
