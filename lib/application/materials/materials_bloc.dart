import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'materials_bloc.freezed.dart';
part 'materials_event.dart';
part 'materials_state.dart';

class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  final GenshinService _genshinService;
  final List<MaterialCardModel> _allMaterials = [];

  MaterialsStateLoaded get currentState => state as MaterialsStateLoaded;

  MaterialsBloc(this._genshinService) : super(const MaterialsState.loading()) {
    on<MaterialsEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(MaterialsEvent event, Emitter<MaterialsState> emit) async {
    switch (event) {
      case MaterialsEventInit():
        if (_allMaterials.isEmpty || event.force) {
          _allMaterials.clear();
          _allMaterials.addAll(_genshinService.materials.getAllMaterialsForCard());
        }

        emit(_buildInitialState(excludeKeys: event.excludeKeys));
      case MaterialsEventSearchChanged():
        emit(
          _buildInitialState(
            search: event.search,
            rarity: currentState.rarity,
            type: currentState.type,
            filterType: currentState.filterType,
            sortDirectionType: currentState.sortDirectionType,
          ),
        );
      case MaterialsEventRarityChanged():
        emit(currentState.copyWith.call(tempRarity: event.rarity));
      case MaterialsEventTypeChanged():
        emit(currentState.copyWith.call(tempType: event.type));
      case MaterialsEventFilterTypeChanged():
        emit(currentState.copyWith.call(tempFilterType: event.type));
      case MaterialsEventApplyFilterChanges():
        emit(
          _buildInitialState(
            search: currentState.search,
            rarity: currentState.tempRarity,
            type: currentState.tempType,
            filterType: currentState.tempFilterType,
            sortDirectionType: currentState.tempSortDirectionType,
          ),
        );
      case MaterialsEventSortDirectionTypeChanged():
        emit(currentState.copyWith.call(tempSortDirectionType: event.sortDirectionType));
      case MaterialsEventCancelChanges():
        emit(
          currentState.copyWith.call(
            tempFilterType: currentState.filterType,
            tempRarity: currentState.rarity,
            tempSortDirectionType: currentState.sortDirectionType,
            tempType: currentState.type,
          ),
        );
      case MaterialsEventResetFilters():
        final excludedKeys = switch (state) {
          MaterialsStateLoading() => <String>[],
          final MaterialsStateLoaded state => state.excludeKeys,
        };

        emit(_buildInitialState(excludeKeys: excludedKeys));
    }
  }

  MaterialsState _buildInitialState({
    String? search,
    List<String> excludeKeys = const [],
    int rarity = 0,
    MaterialType? type,
    MaterialFilterType filterType = MaterialFilterType.grouped,
    SortDirectionType sortDirectionType = SortDirectionType.asc,
  }) {
    final isLoaded = state is MaterialsStateLoaded;
    var data = [..._allMaterials];
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
        case MaterialType.weaponPrimary:
        case MaterialType.weapon:
          data = data.where((el) => [MaterialType.weaponPrimary, MaterialType.weapon].contains(el.type)).toList();
        default:
          data = data.where((el) => el.type == type).toList();
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

  List<MaterialCardModel> _sortData(
    List<MaterialCardModel> data,
    MaterialFilterType filterType,
    SortDirectionType sortDirectionType,
  ) {
    switch (filterType) {
      case MaterialFilterType.name:
        return sortDirectionType == SortDirectionType.asc
            ? data.orderBy((el) => el.name).toList()
            : data.orderByDescending((el) => el.name).toList();
      case MaterialFilterType.rarity:
        return sortDirectionType == SortDirectionType.asc
            ? data.orderBy((el) => el.rarity).toList()
            : data.orderByDescending((el) => el.rarity).toList();
      case MaterialFilterType.grouped:
        return sortMaterialsByGrouping(data, sortDirectionType);
    }
  }
}
