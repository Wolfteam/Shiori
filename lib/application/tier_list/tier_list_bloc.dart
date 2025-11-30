import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'tier_list_bloc.freezed.dart';
part 'tier_list_event.dart';
part 'tier_list_state.dart';

const _initialState = TierListState.loaded(rows: [], charsAvailable: [], readyToSave: false);

class TierListBloc extends Bloc<TierListEvent, TierListState> {
  final GenshinService _genshinService;
  final DataService _dataService;
  final TelemetryService _telemetryService;
  final LoggingService _loggingService;
  static final List<int> defaultColors = [
    0xfff44336,
    0xfff56c62,
    0xffff7d06,
    0xffff9800,
    0xffffc107,
    0xffffeb3b,
    0xff8bc34a,
  ];

  TierListStateLoaded get currentState => state as TierListStateLoaded;

  TierListBloc(this._genshinService, this._dataService, this._telemetryService, this._loggingService) : super(_initialState) {
    on<TierListEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(TierListEvent event, Emitter<TierListState> emit) async {
    switch (event) {
      case TierListEventInit():
        emit(await _init(event.reset));
      case TierListEventRowTextChanged():
        emit(await _rowTextChanged(event.index, event.newValue));
      case TierListEventRowPositionChanged():
        emit(await _rowPositionChanged(event.index, event.newIndex));
      case TierListEventRowColorChanged():
        emit(await _rowColorChanged(event.index, event.newColor));
      case TierListEventAddRow():
        emit(await _addNewRow(event.index, event.above));
      case TierListEventDeleteRow():
        emit(await _deleteRow(event.index));
      case TierListEventClearRow():
        emit(await _clearRow(event.index));
      case TierListEventClearAllRows():
        emit(await _clearAllRows());
      case TierListEventAddCharacterToRow():
        emit(await _addCharacterToRow(event.index, event.item));
      case TierListEventDeleteCharacterFromRow():
        emit(await _deleteCharacterFromRow(event.index, event.item));
      case TierListEventReadyToSave():
        emit(currentState.copyWith.call(readyToSave: event.ready));
      case TierListEventScreenshotTaken():
        if (event.succeed) {
          await _telemetryService.trackTierListBuilderScreenShootTaken();
          emit(await _init(false));
          return;
        }
        _loggingService.error(
          runtimeType,
          'Something went wrong while taking the tier list builder screenshot',
          event.ex,
          event.trace,
        );
        emit(currentState);
    }
  }

  Future<TierListState> _init(bool reset) async {
    await _telemetryService.trackTierListOpened();
    if (reset) {
      await _dataService.tierList.deleteTierList();
    }

    final tierList = _dataService.tierList.getTierList();
    final defaultTierList = _genshinService.characters.getDefaultCharacterTierList(defaultColors);
    if (tierList.isEmpty) {
      return TierListState.loaded(rows: defaultTierList, charsAvailable: [], readyToSave: false);
    }

    final items = tierList.expand((el) => el.items).toList();
    final availableChars = defaultTierList.expand((el) => el.items).where((el) => !items.any((x) => x.key == el.key)).toList()
      ..sort((x, y) => x.key.compareTo(y.key));
    return TierListState.loaded(rows: tierList, charsAvailable: availableChars, readyToSave: false);
  }

  Future<TierListState> _rowTextChanged(int index, String newValue) async {
    final updated = currentState.rows.elementAt(index).copyWith.call(tierText: newValue);
    final rows = _updateRows(updated, index, index);
    await _dataService.tierList.saveTierList(rows);
    return currentState.copyWith.call(rows: rows);
  }

  Future<TierListState> _rowPositionChanged(int index, int newIndex) async {
    final updated = currentState.rows.elementAt(index);
    final rows = _updateRows(updated, newIndex, index);
    await _dataService.tierList.saveTierList(rows);
    return currentState.copyWith.call(rows: rows);
  }

  Future<TierListState> _rowColorChanged(int index, int newColor) async {
    final updated = currentState.rows.elementAt(index).copyWith.call(tierColor: newColor);
    final rows = _updateRows(updated, index, index);
    await _dataService.tierList.saveTierList(rows);
    return currentState.copyWith.call(rows: rows);
  }

  Future<TierListState> _addNewRow(int index, bool above) async {
    final colorsCopy = [...defaultColors];
    final color = (colorsCopy..shuffle()).first;
    final newIndex = above ? index : index + 1;

    final newRow = TierListRowModel.row(tierText: (currentState.rows.length + 1).toString(), tierColor: color, items: []);
    final rows = [...currentState.rows];
    rows.insert(newIndex, newRow);
    await _dataService.tierList.saveTierList(rows);
    return currentState.copyWith.call(rows: rows);
  }

  Future<TierListState> _deleteRow(int index) async {
    if (currentState.rows.length == 1) {
      return currentState;
    }
    final rows = [...currentState.rows];
    final row = rows.elementAt(index);
    final chars = _updateAvailableChars([...currentState.charsAvailable, ...row.items], []);
    rows.removeAt(index);
    await _dataService.tierList.saveTierList(rows);
    return currentState.copyWith.call(rows: rows, charsAvailable: chars);
  }

  Future<TierListState> _clearRow(int index) async {
    final row = currentState.rows.elementAt(index);
    final updated = row.copyWith.call(items: []);
    final rows = _updateRows(updated, index, index);
    final chars = _updateAvailableChars([...currentState.charsAvailable, ...row.items], []);
    await _dataService.tierList.saveTierList(rows);
    return currentState.copyWith.call(rows: rows, charsAvailable: chars);
  }

  Future<TierListState> _clearAllRows() async {
    final chars = _updateAvailableChars(
      _genshinService.characters.getDefaultCharacterTierList(defaultColors).expand((row) => row.items).toList(),
      [],
    );
    final updatedRows = currentState.rows.map((row) => row.copyWith.call(items: [])).toList();
    await _dataService.tierList.saveTierList(updatedRows);
    return currentState.copyWith.call(rows: updatedRows, charsAvailable: chars, readyToSave: false);
  }

  Future<TierListState> _addCharacterToRow(int index, ItemCommon item) async {
    if (!currentState.charsAvailable.any((el) => el.key == item.key)) {
      return currentState;
    }
    final row = currentState.rows.elementAt(index);
    final updated = row.copyWith.call(items: [...row.items, item]);
    final updatedChars = _updateAvailableChars(currentState.charsAvailable, [item]);
    final updatedRows = _updateRows(updated, index, index);
    await _dataService.tierList.saveTierList(updatedRows);
    return currentState.copyWith.call(rows: updatedRows, charsAvailable: updatedChars);
  }

  Future<TierListState> _deleteCharacterFromRow(int index, ItemCommon item) async {
    final row = currentState.rows.elementAt(index);
    final updated = row.copyWith.call(items: row.items.where((el) => el.key != item.key).toList());
    final updatedChars = _updateAvailableChars([...currentState.charsAvailable, item], []);
    final updatedRows = _updateRows(updated, index, index);
    await _dataService.tierList.saveTierList(updatedRows);
    return currentState.copyWith.call(rows: updatedRows, charsAvailable: updatedChars, readyToSave: false);
  }

  List<TierListRowModel> _updateRows(TierListRowModel updated, int newIndex, int excludeIndex) {
    final rows = <TierListRowModel>[];

    if (newIndex < 0 || newIndex == currentState.rows.length) {
      return currentState.rows;
    }

    for (int i = 0; i < currentState.rows.length; i++) {
      if (i == excludeIndex) {
        continue;
      }
      final row = currentState.rows[i];
      rows.add(row);
    }

    rows.insert(newIndex, updated);
    return rows;
  }

  List<ItemCommon> _updateAvailableChars(List<ItemCommon> from, List<ItemCommon> exclude) {
    var chars = from;
    if (exclude.isNotEmpty) {
      chars = chars.where((item) => !exclude.any((el) => el.key == item.key)).toList();
    }
    return chars..sort((x, y) => x.key.compareTo(y.key));
  }
}
