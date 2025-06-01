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

  MonstersStateLoaded get currentState => state as MonstersStateLoaded;

  MonstersBloc(this._genshinService) : super(const MonstersState.loading());

  @override
  Stream<MonstersState> mapEventToState(MonstersEvent event) async* {
    switch (event) {
      case MonstersEventInit():
        if (_allMonsters.isEmpty || event.force) {
          _allMonsters.clear();
          _allMonsters.addAll(_genshinService.monsters.getAllMonstersForCard());
        }

        yield _buildInitialState(excludeKeys: event.excludeKeys);
      case MonstersEventSearchChanged():
        yield _buildInitialState(
          search: event.search,
          type: currentState.type,
          filterType: currentState.filterType,
          sortDirectionType: currentState.sortDirectionType,
        );
      case MonstersEventTypeChanged():
        yield currentState.copyWith.call(tempType: event.type);
      case MonstersEventFilterTypeChanged():
        yield currentState.copyWith.call(tempFilterType: event.type);
      case MonstersEventApplyFilterChanges():
        yield _buildInitialState(
          search: currentState.search,
          type: currentState.tempType,
          filterType: currentState.tempFilterType,
          sortDirectionType: currentState.tempSortDirectionType,
        );
      case MonstersEventSortDirectionTypeChanged():
        yield currentState.copyWith.call(tempSortDirectionType: event.sortDirectionType);
      case MonstersEventCancelChanges():
        yield currentState.copyWith.call(
          tempFilterType: currentState.filterType,
          tempSortDirectionType: currentState.sortDirectionType,
          tempType: currentState.type,
        );
      case MonstersEventResetFilters():
        final excludedKeys = switch (state) {
          MonstersStateLoading() => <String>[],
          final MonstersStateLoaded state => state.excludeKeys,
        };

        yield _buildInitialState(excludeKeys: excludedKeys);
    }
  }

  MonstersState _buildInitialState({
    String? search,
    List<String> excludeKeys = const [],
    MonsterType? type,
    MonsterFilterType filterType = MonsterFilterType.name,
    SortDirectionType sortDirectionType = SortDirectionType.asc,
  }) {
    final isLoaded = state is MonstersStateLoaded;
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
