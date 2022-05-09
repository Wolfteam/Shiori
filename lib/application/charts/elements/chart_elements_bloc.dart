import 'package:bloc/bloc.dart';
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
      : versions = _genshinService.getBannerHistoryVersions(SortDirectionType.asc),
        super(const ChartElementsState.loading());

  @override
  Stream<ChartElementsState> mapEventToState(ChartElementsEvent event) async* {
    final s = event.map(
      init: (e) => _init(e.maxNumberOfColumns),
      elementSelected: (e) => state.maybeMap(
        loaded: (state) => _elementSelectionChanged(state, e.type),
        orElse: () => throw Exception('Invalid state'),
      ),
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

  //Some versions were skipped (e.g: 1.7, 1.8, 1.9), that's why we use this function
  //to determine if the version can be skipped or no
  bool isValidVersion(double value) {
    return versions.contains(value.truncateToDecimalPlaces());
  }

  ChartElementsState _init(int maxNumberOfColumns) {
    final firstVersion = versions.first;
    final lastVersion = versions.first + (maxNumberOfColumns / 10);
    final elements = _genshinService.getElementsForCharts(firstVersion, lastVersion);
    return ChartElementsState.loaded(
      maxNumberOfColumns: maxNumberOfColumns,
      firstVersion: firstVersion,
      lastVersion: lastVersion,
      elements: elements,
      filteredElements: elements,
      canGoToFirstPage: _canGoToFirstPage(firstVersion),
      canGoToLastPage: _canGoToLastPage(firstVersion),
      canGoToNextPage: _canGoToNextPage(firstVersion),
      canGoToPreviousPage: _canGoToPreviousPage(firstVersion),
    );
  }

  ChartElementsState _elementSelectionChanged(_InitialState state, ElementType type) {
    final selectedTypes = [...state.selectedElementTypes];
    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }

    return state.copyWith(selectedElementTypes: selectedTypes, filteredElements: _getFilteredElements(state.elements, selectedTypes));
  }

  List<ChartElementItemModel> _getFilteredElements(List<ChartElementItemModel> elements, List<ElementType> selectedTypes) =>
      selectedTypes.isEmpty ? elements : elements.where((el) => selectedTypes.contains(el.type)).toList();

  double _getStep(_InitialState state) => state.maxNumberOfColumns * gameVersionIncrementsBy;

  ChartElementsState _goToFirstOrLastPage(_InitialState state, bool toFirstPage) {
    final firstVersion = versions.first;
    if (toFirstPage) {
      return _newVersionChanged(state, firstVersion);
    }

    final possibleVersionA = (firstVersion + _getStep(state)).truncateToDecimalPlaces();
    final possibleVersionB = (versions.last - _getStep(state)).truncateToDecimalPlaces();
    if (possibleVersionA > possibleVersionB && possibleVersionB > firstVersion) {
      return _newVersionChanged(state, possibleVersionB);
    }
    return _newVersionChanged(state, possibleVersionA);
  }

  ChartElementsState _goToNextPage(_InitialState state) {
    if (!_canGoToNextPage(state.firstVersion)) {
      throw Exception('Cannot go to the next page');
    }
    final newVersion = (state.firstVersion + gameVersionIncrementsBy).truncateToDecimalPlaces();
    return _newVersionChanged(state, newVersion);
  }

  ChartElementsState _goToPreviousPage(_InitialState state) {
    if (!_canGoToPreviousPage(state.firstVersion)) {
      throw Exception('Cannot go to the previous page');
    }
    final newVersion = (state.firstVersion - gameVersionIncrementsBy).truncateToDecimalPlaces();
    return _newVersionChanged(state, newVersion);
  }

  ChartElementsState _newVersionChanged(_InitialState state, double newFirstVersion) {
    final step = _getStep(state);
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

    assert(newFirstVersion != newLastVersion, 'New and last version cannot be equal');

    final elements = _genshinService.getElementsForCharts(newFirstVersion, newLastVersion);
    return state.copyWith(
      elements: elements,
      filteredElements: _getFilteredElements(elements, state.selectedElementTypes),
      firstVersion: newFirstVersion,
      lastVersion: newLastVersion,
      canGoToFirstPage: _canGoToFirstPage(newFirstVersion),
      canGoToLastPage: _canGoToLastPage(newLastVersion),
      canGoToNextPage: _canGoToNextPage(newFirstVersion) && _canGoToLastPage(newLastVersion),
      canGoToPreviousPage: _canGoToPreviousPage(newFirstVersion) && _canGoToFirstPage(newFirstVersion),
    );
  }

  bool _canGoToFirstPage(double version) => version > versions.first;

  bool _canGoToNextPage(double version) => version + gameVersionIncrementsBy <= versions.last;

  bool _canGoToPreviousPage(double version) => version - gameVersionIncrementsBy >= versions.first;

  bool _canGoToLastPage(double version) => version < versions.last;
}
