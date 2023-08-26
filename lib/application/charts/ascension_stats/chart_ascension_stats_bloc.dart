import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'chart_ascension_stats_bloc.freezed.dart';
part 'chart_ascension_stats_event.dart';
part 'chart_ascension_stats_state.dart';

const _firstPage = 1;

class ChartAscensionStatsBloc extends Bloc<ChartAscensionStatsEvent, ChartAscensionStatsState> {
  final List<ChartAscensionStatModel> _characterAscensionStats;
  final List<ChartAscensionStatModel> _weaponAscensionStats;

  ChartAscensionStatsBloc(GenshinService genshinService)
      : _characterAscensionStats = genshinService.getItemAscensionStatsForCharts(ItemType.character),
        _weaponAscensionStats = genshinService.getItemAscensionStatsForCharts(ItemType.weapon),
        super(const ChartAscensionStatsState.loading());

  @override
  Stream<ChartAscensionStatsState> mapEventToState(ChartAscensionStatsEvent event) async* {
    final s = event.map(
      init: (e) => _init(e.type, e.maxNumberOfColumns),
      goToNextPage: (e) => state.maybeMap(
        loaded: _goToNextPage,
        orElse: () => throw Exception('Invalid state'),
      ),
      goToPreviousPage: (e) => state.maybeMap(
        loaded: _goToPreviousPage,
        orElse: () => throw Exception('Invalid state'),
      ),
      goToFirstPage: (e) => state.maybeMap(
        loaded: (state) => _goToFirstOrLastPage(state, true),
        orElse: () => throw Exception('Invalid state'),
      ),
      goToLastPage: (e) => state.maybeMap(
        loaded: (state) => _goToFirstOrLastPage(state, false),
        orElse: () => throw Exception('Invalid state'),
      ),
    );

    yield s;
  }

  ChartAscensionStatsState _init(ItemType itemType, int maxNumberOfColumns) {
    if (state.mapOrNull(loaded: (state) => state.itemType == itemType && state.maxNumberOfColumns == maxNumberOfColumns) == true) {
      return state;
    }

    if (maxNumberOfColumns < 1) {
      throw Exception('The provided maxNumberOfColumns = $maxNumberOfColumns is not valid');
    }

    final ascensionStats = <ChartAscensionStatModel>[];
    switch (itemType) {
      case ItemType.character:
        ascensionStats.addAll(_characterAscensionStats.take(maxNumberOfColumns));
      case ItemType.weapon:
        ascensionStats.addAll(_weaponAscensionStats.take(maxNumberOfColumns));
      default:
        throw Exception('ItemType = $itemType is not valid');
    }

    final maxPage = _getMaxPage(itemType, maxNumberOfColumns);
    return ChartAscensionStatsState.loaded(
      canGoToFirstPage: _canGoToFirstPage(_firstPage),
      canGoToPreviousPage: _canGoToPreviousPage(_firstPage),
      canGoToNextPage: _canGoToNextPage(_firstPage, maxPage),
      canGoToLastPage: _canGoToLastPage(_firstPage, maxPage),
      currentPage: _firstPage,
      maxPage: _getMaxPage(itemType, maxNumberOfColumns),
      maxNumberOfColumns: maxNumberOfColumns,
      itemType: itemType,
      maxCount: ascensionStats.map((e) => e.quantity).reduce(max),
      ascensionStats: ascensionStats,
    );
  }

  int _getMaxPage(ItemType itemType, int take) {
    if (take <= 0) {
      throw Exception('Take = $take is not valid');
    }
    double pages = 0;
    switch (itemType) {
      case ItemType.character:
        pages = _characterAscensionStats.length / take;
      case ItemType.weapon:
        pages = _weaponAscensionStats.length / take;
      default:
        throw Exception('ItemType = $itemType is not valid');
    }
    return pages.ceil();
  }

  ChartAscensionStatsState _goToFirstOrLastPage(_LoadedState state, bool toFirstPage) {
    final page = toFirstPage ? _firstPage : state.maxPage;
    return _pageChanged(state, page);
  }

  ChartAscensionStatsState _goToNextPage(_LoadedState state) {
    if (!_canGoToNextPage(state.currentPage, state.maxPage)) {
      throw Exception('Cannot go to the next page');
    }
    final newPage = state.currentPage + 1;
    return _pageChanged(state, newPage);
  }

  ChartAscensionStatsState _goToPreviousPage(_LoadedState state) {
    if (!_canGoToPreviousPage(state.currentPage)) {
      throw Exception('Cannot go to the previous page');
    }
    final newPage = state.currentPage - 1;
    return _pageChanged(state, newPage);
  }

  ChartAscensionStatsState _pageChanged(_LoadedState state, int newPage) {
    if (newPage < _firstPage) {
      throw Exception('The newPage = $newPage cannot be less than $_firstPage');
    }

    if (state.currentPage == newPage) {
      throw Exception('We are already on the same page = $newPage');
    }

    final skip = state.maxNumberOfColumns * (newPage - 1);
    final ascensionStats = <ChartAscensionStatModel>[];
    switch (state.itemType) {
      case ItemType.character:
        ascensionStats.addAll(_characterAscensionStats.skip(skip).take(state.maxNumberOfColumns));
      case ItemType.weapon:
        ascensionStats.addAll(_weaponAscensionStats.skip(skip).take(state.maxNumberOfColumns));
      default:
        throw Exception('ItemType = ${state.itemType} is not valid');
    }
    return state.copyWith(
      canGoToFirstPage: _canGoToFirstPage(newPage),
      canGoToLastPage: _canGoToLastPage(newPage, state.maxPage),
      canGoToNextPage: _canGoToNextPage(newPage, state.maxPage) && _canGoToLastPage(newPage, state.maxPage),
      canGoToPreviousPage: _canGoToPreviousPage(newPage) && _canGoToFirstPage(newPage),
      ascensionStats: ascensionStats,
      currentPage: newPage,
    );
  }

  bool _canGoToFirstPage(int currentPage) => currentPage > _firstPage;

  bool _canGoToNextPage(int currentPage, int maxPage) => currentPage + 1 <= maxPage;

  bool _canGoToPreviousPage(int currentPage) => currentPage - 1 >= _firstPage;

  bool _canGoToLastPage(int currentPage, int maxPage) => currentPage < maxPage;
}
