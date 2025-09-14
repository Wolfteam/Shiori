import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/double_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'chart_elements_bloc.freezed.dart';
part 'chart_elements_event.dart';
part 'chart_elements_state.dart';

class ChartElementsBloc extends Bloc<ChartElementsEvent, ChartElementsState> {
  final GenshinService _genshinService;
  final List<double> versions;

  ChartElementsBloc(this._genshinService)
    : versions = _genshinService.bannerHistory.getBannerHistoryVersions(SortDirectionType.asc),
      super(const ChartElementsState.loading()) {
    on<ChartElementsEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(ChartElementsEvent event, Emitter<ChartElementsState> emit) async {
    if (event is! ChartElementsEventInit && state is! ChartElementsStateLoaded) {
      throw Exception('Invalid state');
    }

    switch (event) {
      case ChartElementsEventInit():
        emit(_init(event.maxNumberOfColumns));
      case ChartElementsEventElementSelected():
        emit(_elementSelectionChanged(state as ChartElementsStateLoaded, event.type));
      case ChartElementsEventGoToNextPage():
        emit(_goToNextPage(state as ChartElementsStateLoaded));
      case ChartElementsEventGoToPreviousPage():
        emit(_goToPreviousPage(state as ChartElementsStateLoaded));
      case ChartElementsEventGoToFirstPage():
        emit(_goToFirstOrLastPage(state as ChartElementsStateLoaded, true));
      case ChartElementsEventGoToLastPage():
        emit(_goToFirstOrLastPage(state as ChartElementsStateLoaded, false));
    }
  }

  //Some versions were skipped (e.g: 1.7, 1.8, 1.9), that's why we use this function
  //to determine if the version can be skipped or no
  bool isValidVersion(double value) {
    return versions.contains(value.truncateToDecimalPlaces());
  }

  ChartElementsState _init(int maxNumberOfColumns) {
    if (maxNumberOfColumns < 1) {
      throw Exception('The provided maxNumberOfColumns = $maxNumberOfColumns is not valid');
    }
    final firstVersion = versions.first;
    double lastVersion = firstVersion + _getStep(maxNumberOfColumns);
    if (lastVersion > versions.last) {
      lastVersion = versions.last;
    }

    final elements = _genshinService.bannerHistory.getElementsForCharts(firstVersion, lastVersion);
    return ChartElementsState.loaded(
      maxNumberOfColumns: maxNumberOfColumns,
      firstVersion: firstVersion,
      lastVersion: lastVersion,
      elements: elements,
      filteredElements: elements,
      canGoToFirstPage: _canGoToFirstPage(firstVersion),
      canGoToLastPage: _canGoToLastPage(lastVersion),
      canGoToNextPage: _canGoToNextPage(lastVersion),
      canGoToPreviousPage: _canGoToPreviousPage(firstVersion),
    );
  }

  ChartElementsState _elementSelectionChanged(ChartElementsStateLoaded state, ElementType type) {
    final selectedTypes = [...state.selectedElementTypes];
    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }

    return state.copyWith(
      selectedElementTypes: selectedTypes,
      filteredElements: _getFilteredElements(state.elements, selectedTypes),
    );
  }

  List<ChartElementItemModel> _getFilteredElements(List<ChartElementItemModel> elements, List<ElementType> selectedTypes) =>
      selectedTypes.isEmpty ? elements : elements.where((el) => selectedTypes.contains(el.type)).toList();

  double _getStep(int maxNumberOfColumns) => maxNumberOfColumns * gameVersionIncrementsBy;

  ChartElementsState _goToFirstOrLastPage(ChartElementsStateLoaded state, bool toFirstPage) {
    final firstVersion = versions.first;
    if (toFirstPage) {
      return _newVersionChanged(state, firstVersion);
    }

    final fromVersion = versions.last - _getStep(state.maxNumberOfColumns);
    return _newVersionChanged(state, fromVersion);
  }

  ChartElementsState _goToNextPage(ChartElementsStateLoaded state) {
    if (!_canGoToNextPage(state.lastVersion)) {
      throw Exception('Cannot go to the next page');
    }
    final newVersion = (state.firstVersion + gameVersionIncrementsBy).truncateToDecimalPlaces();
    return _newVersionChanged(state, newVersion);
  }

  ChartElementsState _goToPreviousPage(ChartElementsStateLoaded state) {
    if (!_canGoToPreviousPage(state.firstVersion)) {
      throw Exception('Cannot go to the previous page');
    }
    final newVersion = (state.firstVersion - gameVersionIncrementsBy).truncateToDecimalPlaces();
    return _newVersionChanged(state, newVersion);
  }

  ChartElementsState _newVersionChanged(ChartElementsStateLoaded state, double newFirstVersion) {
    final step = _getStep(state.maxNumberOfColumns);
    double newLastVersion = (newFirstVersion + step).truncateToDecimalPlaces();

    if (newLastVersion > versions.last) {
      newLastVersion = versions.last;
    }
    if (newFirstVersion < versions.first) {
      throw Exception('First version = $newFirstVersion cannot be greater than = ${versions.first}');
    }

    if (newLastVersion > versions.last) {
      throw Exception('Last version = $newLastVersion cannot be greater than = ${versions.last}');
    }

    if (state.firstVersion == newFirstVersion && state.lastVersion == newLastVersion) {
      throw Exception('The state already has the same first and last version');
    }

    assert(newFirstVersion != newLastVersion, 'New and last version cannot be equal');

    final elements = _genshinService.bannerHistory.getElementsForCharts(newFirstVersion, newLastVersion);
    return state.copyWith(
      elements: elements,
      filteredElements: _getFilteredElements(elements, state.selectedElementTypes),
      firstVersion: newFirstVersion,
      lastVersion: newLastVersion,
      canGoToFirstPage: _canGoToFirstPage(newFirstVersion),
      canGoToLastPage: _canGoToLastPage(newLastVersion),
      canGoToNextPage: _canGoToNextPage(newLastVersion) && _canGoToLastPage(newLastVersion),
      canGoToPreviousPage: _canGoToPreviousPage(newFirstVersion) && _canGoToFirstPage(newFirstVersion),
    );
  }

  bool _canGoToFirstPage(double version) => version > versions.first;

  bool _canGoToNextPage(double version) => (version + gameVersionIncrementsBy).truncateToDecimalPlaces() <= versions.last;

  bool _canGoToPreviousPage(double version) => (version - gameVersionIncrementsBy).truncateToDecimalPlaces() >= versions.first;

  bool _canGoToLastPage(double version) => version < versions.last;
}
