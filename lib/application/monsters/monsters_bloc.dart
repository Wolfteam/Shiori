import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'monsters_bloc.freezed.dart';
part 'monsters_event.dart';
part 'monsters_state.dart';

class MonstersBloc extends Bloc<MonstersEvent, MonstersState> {
  final GenshinService _genshinService;
  final List<MonsterCardModel> _allMonsters = [];

  _LoadedState get currentState => state as _LoadedState;

  MonstersBloc(this._genshinService) : super(const MonstersState.loading());

  @override
  Stream<MonstersState> mapEventToState(MonstersEvent event) async* {
    final s = event.map(
      init: (e) {
        if (_allMonsters.isEmpty || e.force) {
          _allMonsters.clear();
          _allMonsters.addAll(_genshinService.monsters.getAllMonstersForCard());
        }

        return _buildInitialState(excludeKeys: e.excludeKeys);
      },
      sortDirectionTypeChanged: (e) => currentState.copyWith.call(tempSortDirectionType: e.sortDirectionType),
      typeChanged: (e) => currentState.copyWith.call(tempType: e.type),
      filterTypeChanged: (e) => currentState.copyWith.call(tempFilterType: e.type),
      searchChanged:
          (e) => _buildInitialState(
            search: e.search,
            type: currentState.type,
            filterType: currentState.filterType,
            sortDirectionType: currentState.sortDirectionType,
          ),
      applyFilterChanges:
          (_) => _buildInitialState(
            search: currentState.search,
            type: currentState.tempType,
            filterType: currentState.tempFilterType,
            sortDirectionType: currentState.tempSortDirectionType,
          ),
      cancelChanges:
          (_) => currentState.copyWith.call(
            tempFilterType: currentState.filterType,
            tempSortDirectionType: currentState.sortDirectionType,
            tempType: currentState.type,
          ),
      resetFilters:
          (_) => _buildInitialState(excludeKeys: state.maybeMap(loaded: (state) => state.excludeKeys, orElse: () => [])),
    );

    yield s;
  }

  MonstersState _buildInitialState({
    String? search,
    List<String> excludeKeys = const [],
    MonsterType? type,
    MonsterFilterType filterType = MonsterFilterType.name,
    SortDirectionType sortDirectionType = SortDirectionType.asc,
  }) {
    final isLoaded = state is _LoadedState;
    var data = [..._allMonsters];
    if (excludeKeys.isNotEmpty) {
      data = data.where((el) => !excludeKeys.contains(el.key)).toList();
    }

    if (!isLoaded) {
      _sortData(data, filterType, sortDirectionType);
      return MonstersState.loaded(
        monsters: data,
        search: search,
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

    if (type != null) {
      data = data.where((el) => el.type == type).toList();
    }

    _sortData(data, filterType, sortDirectionType);
    final s = currentState.copyWith.call(
      monsters: data,
      search: search,
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

  void _sortData(List<MonsterCardModel> data, MonsterFilterType filterType, SortDirectionType sortDirectionType) {
    switch (filterType) {
      case MonsterFilterType.name:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.name.compareTo(y.name));
        } else {
          data.sort((x, y) => y.name.compareTo(x.name));
        }
    }
  }
}
