import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/logging_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';
import 'package:meta/meta.dart';

part 'tier_list_bloc.freezed.dart';
part 'tier_list_event.dart';
part 'tier_list_state.dart';

const _initialState = TierListState.loaded(rows: [], charsAvailable: [], readyToSave: false);

class TierListBloc extends Bloc<TierListEvent, TierListState> {
  final GenshinService _genshinService;
  final DataService _dataService;
  final TelemetryService _telemetryService;
  final LoggingService _loggingService;
  final List<int> defaultColors = [
    0xfff44336,
    0xffff9800,
    0xffffc107,
    0xffffeb3b,
    0xff8bc34a,
  ];

  _LoadedState get currentState => state as _LoadedState;

  TierListBloc(this._genshinService, this._dataService, this._telemetryService, this._loggingService) : super(_initialState);

  @override
  Stream<TierListState> mapEventToState(TierListEvent event) async* {
    final s = await event.map(
      init: (e) async => _init(e.reset),
      rowTextChanged: (e) async => _rowTextChanged(e.index, e.newValue),
      rowPositionChanged: (e) async => _rowPositionChanged(e.index, e.newIndex),
      rowColorChanged: (e) async => _rowColorChanged(e.index, e.newColor),
      addNewRow: (e) async => _addNewRow(e.index, e.above),
      deleteRow: (e) async => _deleteRow(e.index),
      clearRow: (e) async => _clearRow(e.index),
      clearAllRows: (_) async => _clearAllRows(),
      addCharacterToRow: (e) async => _addCharacterToRow(e.index, e.charImg),
      deleteCharacterFromRow: (e) async => _deleteCharacterFromRow(e.index, e.charImg),
      readyToSave: (e) async => currentState.copyWith.call(readyToSave: e.ready),
      screenshotTaken: (e) async {
        if (e.succeed) {
          await _telemetryService.trackTierListBuilderScreenShootTaken();
        } else {
          _loggingService.error(runtimeType, 'Something went wrong while taking the tier list builder screenshot', e.ex, e.trace);
        }

        return currentState;
      },
      close: (e) async => _initialState,
    );

    yield s;
  }

  Future<TierListState> _init(bool reset) async {
    await _telemetryService.trackTierListOpened();
    if (reset) {
      await _dataService.deleteTierList();
    }

    final tierList = _dataService.getTierList();
    final defaultTierList = _genshinService.getDefaultCharacterTierList(defaultColors);
    if (tierList.isEmpty) {
      return TierListState.loaded(rows: defaultTierList, charsAvailable: [], readyToSave: false);
    }

    final usedCharImgs = tierList.expand((el) => el.charImgs).toList();
    final availableChars = defaultTierList.expand((el) => el.charImgs).where((el) => !usedCharImgs.contains(el)).toList();
    return TierListState.loaded(rows: tierList, charsAvailable: availableChars, readyToSave: false);
  }

  Future<TierListState> _rowTextChanged(int index, String newValue) async {
    final updated = currentState.rows.elementAt(index).copyWith.call(tierText: newValue);
    final rows = _updateRows(updated, index, index);
    await _dataService.saveTierList(rows);
    return currentState.copyWith.call(rows: rows);
  }

  Future<TierListState> _rowPositionChanged(int index, int newIndex) async {
    final updated = currentState.rows.elementAt(index);
    final rows = _updateRows(updated, newIndex, index);
    await _dataService.saveTierList(rows);
    return currentState.copyWith.call(rows: rows);
  }

  Future<TierListState> _rowColorChanged(int index, int newColor) async {
    final updated = currentState.rows.elementAt(index).copyWith.call(tierColor: newColor);
    final rows = _updateRows(updated, index, index);
    await _dataService.saveTierList(rows);
    return currentState.copyWith.call(rows: rows);
  }

  Future<TierListState> _addNewRow(int index, bool above) async {
    final colorsCopy = [...defaultColors];
    final color = (colorsCopy..shuffle()).first;
    final newIndex = above ? index : index + 1;

    final newRow = TierListRowModel.row(tierText: (currentState.rows.length + 1).toString(), tierColor: color, charImgs: []);
    final rows = [...currentState.rows];
    rows.insert(newIndex, newRow);
    await _dataService.saveTierList(rows);
    return currentState.copyWith.call(rows: rows);
  }

  Future<TierListState> _deleteRow(int index) async {
    if (currentState.rows.length == 1) {
      return currentState;
    }
    final rows = [...currentState.rows];
    final row = rows.elementAt(index);
    final chars = _updateAvailableChars([...currentState.charsAvailable, ...row.charImgs], []);
    rows.removeAt(index);
    await _dataService.saveTierList(rows);
    return currentState.copyWith.call(rows: rows, charsAvailable: chars);
  }

  Future<TierListState> _clearRow(int index) async {
    final row = currentState.rows.elementAt(index);
    final updated = row.copyWith.call(charImgs: []);
    final rows = _updateRows(updated, index, index);
    final chars = _updateAvailableChars([...currentState.charsAvailable, ...row.charImgs], []);
    await _dataService.saveTierList(rows);
    return currentState.copyWith.call(rows: rows, charsAvailable: chars);
  }

  Future<TierListState> _clearAllRows() async {
    final chars = _updateAvailableChars(_genshinService.getDefaultCharacterTierList(defaultColors).expand((row) => row.charImgs).toList(), []);
    final updatedRows = currentState.rows.map((row) => row.copyWith.call(charImgs: [])).toList();
    await _dataService.saveTierList(updatedRows);
    return currentState.copyWith.call(rows: updatedRows, charsAvailable: chars, readyToSave: false);
  }

  Future<TierListState> _addCharacterToRow(int index, String charImg) async {
    final row = currentState.rows.elementAt(index);
    final updated = row.copyWith.call(charImgs: [...row.charImgs, charImg]);
    final updatedChars = _updateAvailableChars(currentState.charsAvailable, [charImg]);
    final updatedRows = _updateRows(updated, index, index);
    await _dataService.saveTierList(updatedRows);
    return currentState.copyWith.call(rows: updatedRows, charsAvailable: updatedChars);
  }

  Future<TierListState> _deleteCharacterFromRow(int index, String charImg) async {
    final row = currentState.rows.elementAt(index);
    final updated = row.copyWith.call(charImgs: row.charImgs.where((img) => img != charImg).toList());
    final updatedChars = _updateAvailableChars([...currentState.charsAvailable, charImg], []);
    final updatedRows = _updateRows(updated, index, index);
    await _dataService.saveTierList(updatedRows);
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

  List<String> _updateAvailableChars(List<String> from, List<String> exclude) {
    var chars = from;
    if (exclude.isNotEmpty) {
      chars = chars.where((img) => !exclude.contains(img)).toList();
    }
    return chars..sort((x, y) => x.compareTo(y));
  }
}
