import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/enums/material_type.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';

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
      init: (e) => _buildInitialState(),
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
    );

    yield s;
  }

  MaterialsState _buildInitialState({
    String search,
    int rarity = 0,
    MaterialType type = MaterialType.all,
    MaterialFilterType filterType = MaterialFilterType.rarity,
    SortDirectionType sortDirectionType = SortDirectionType.asc,
  }) {
    final isLoaded = state is _LoadedState;
    var data = _genshinService.getAllMaterials();

    if (!isLoaded) {
      _sortData(data, filterType, sortDirectionType);
      return MaterialsState.loaded(
        materials: data,
        search: search,
        rarity: rarity,
        tempRarity: rarity,
        type: type,
        tempType: type,
        filterType: filterType,
        tempFilterType: filterType,
        sortDirectionType: sortDirectionType,
        tempSortDirectionType: sortDirectionType,
      );
    }

    if (search != null && search.isNotEmpty) {
      data = data.where((el) => el.name.toLowerCase().contains(search.toLowerCase())).toList();
    }

    if (rarity > 0) {
      data = data.where((el) => el.rarity == rarity).toList();
    }

    if (type != MaterialType.all) {
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

    _sortData(data, filterType, sortDirectionType);

    final s = currentState.copyWith.call(
      materials: data,
      search: search,
      rarity: rarity,
      tempRarity: rarity,
      type: type,
      tempType: type,
      filterType: filterType,
      tempFilterType: filterType,
      sortDirectionType: sortDirectionType,
      tempSortDirectionType: sortDirectionType,
    );
    return s;
  }

  void _sortData(
    List<MaterialCardModel> data,
    MaterialFilterType filterType,
    SortDirectionType sortDirectionType,
  ) {
    switch (filterType) {
      case MaterialFilterType.name:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.name.compareTo(y.name));
        } else {
          data.sort((x, y) => y.name.compareTo(x.name));
        }
        break;
      case MaterialFilterType.rarity:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.rarity.compareTo(y.rarity));
        } else {
          data.sort((x, y) => y.rarity.compareTo(x.rarity));
        }
        break;
      default:
        break;
    }
  }
}
