import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/enums/material_type.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'materials_bloc.freezed.dart';
part 'materials_event.dart';
part 'materials_state.dart';

class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  final GenshinService _genshinService;

  _LoadedState get currentState => state as _LoadedState;

  MaterialsBloc(this._genshinService) : super(const MaterialsState.loading());

  @override
  Stream<MaterialsState> mapEventToState(MaterialsEvent event) async* {
    final s = event.map(
      init: (e) => _buildInitialState(excludeKeys: e.excludeKeys),
      rarityChanged: (e) => currentState.copyWith.call(tempRarity: e.rarity),
      sortDirectionTypeChanged: (e) => currentState.copyWith.call(tempSortDirectionType: e.sortDirectionType),
      typeChanged: (e) => currentState.copyWith.call(tempType: e.type),
      filterTypeChanged: (e) => currentState.copyWith.call(tempFilterType: e.type),
      searchChanged: (e) => _buildInitialState(
        search: e.search,
        rarity: currentState.rarity,
        type: currentState.type,
        filterType: currentState.filterType,
        sortDirectionType: currentState.sortDirectionType,
      ),
      applyFilterChanges: (_) => _buildInitialState(
        search: currentState.search,
        rarity: currentState.tempRarity,
        type: currentState.tempType,
        filterType: currentState.tempFilterType,
        sortDirectionType: currentState.tempSortDirectionType,
      ),
      cancelChanges: (_) => currentState.copyWith.call(
        tempFilterType: currentState.filterType,
        tempRarity: currentState.rarity,
        tempSortDirectionType: currentState.sortDirectionType,
        tempType: currentState.type,
      ),
      resetFilters: (_) => _buildInitialState(
        excludeKeys: state.maybeMap(loaded: (state) => state.excludeKeys, orElse: () => []),
      ),
    );

    yield s;
  }

  MaterialsState _buildInitialState({
    String? search,
    List<String> excludeKeys = const [],
    int rarity = 0,
    MaterialType? type,
    MaterialFilterType filterType = MaterialFilterType.grouped,
    SortDirectionType sortDirectionType = SortDirectionType.asc,
  }) {
    final isLoaded = state is _LoadedState;
    var data = _genshinService.getAllMaterialsForCard();
    if (excludeKeys.isNotEmpty) {
      data = data.where((el) => !excludeKeys.contains(el.key)).toList();
    }

    if (!isLoaded) {
      return MaterialsState.loaded(
        materials: _sortData(data, filterType, sortDirectionType),
        search: search,
        rarity: rarity,
        tempRarity: rarity,
        type: type,
        tempType: type,
        filterType: filterType,
        tempFilterType: filterType,
        sortDirectionType: sortDirectionType,
        tempSortDirectionType: sortDirectionType,
        excludeKeys: excludeKeys,
      );
    }

    if (search != null && search.isNotEmpty) {
      data = data.where((el) => el.name.toLowerCase().contains(search.toLowerCase())).toList();
    }

    if (rarity > 0) {
      data = data.where((el) => el.rarity == rarity).toList();
    }

    if (type != null) {
      switch (type) {
        case MaterialType.expWeapon:
        case MaterialType.expCharacter:
          data = data.where((el) => [MaterialType.expWeapon, MaterialType.expCharacter].contains(el.type)).toList();
          break;
        case MaterialType.weaponPrimary:
        case MaterialType.weapon:
          data = data.where((el) => [MaterialType.weaponPrimary, MaterialType.weapon].contains(el.type)).toList();
          break;
        default:
          data = data.where((el) => el.type == type).toList();
          break;
      }
    }

    final s = currentState.copyWith.call(
      materials: _sortData(data, filterType, sortDirectionType),
      search: search,
      rarity: rarity,
      tempRarity: rarity,
      type: type,
      tempType: type,
      filterType: filterType,
      tempFilterType: filterType,
      sortDirectionType: sortDirectionType,
      tempSortDirectionType: sortDirectionType,
      excludeKeys: excludeKeys,
    );
    return s;
  }

  List<MaterialCardModel> _sortData(List<MaterialCardModel> data, MaterialFilterType filterType, SortDirectionType sortDirectionType) {
    switch (filterType) {
      case MaterialFilterType.name:
        return sortDirectionType == SortDirectionType.asc ? data.orderBy((el) => el.name).toList() : data.orderByDescending((el) => el.name).toList();
      case MaterialFilterType.rarity:
        return sortDirectionType == SortDirectionType.asc
            ? data.orderBy((el) => el.rarity).toList()
            : data.orderByDescending((el) => el.rarity).toList();
      case MaterialFilterType.grouped:
        return sortMaterialsByGrouping(data, sortDirectionType);
      default:
        return data;
    }
  }
}
