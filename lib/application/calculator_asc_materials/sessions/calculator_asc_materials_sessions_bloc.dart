import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'calculator_asc_materials_sessions_bloc.freezed.dart';
part 'calculator_asc_materials_sessions_event.dart';
part 'calculator_asc_materials_sessions_state.dart';

class CalculatorAscMaterialsSessionsBloc extends Bloc<CalculatorAscMaterialsSessionsEvent, CalculatorAscMaterialsSessionsState> {
  final DataService _dataService;
  final TelemetryService _telemetryService;

  final List<StreamSubscription> _calcItemSubscriptions = [];

  _LoadedState get currentState => state as _LoadedState;

  CalculatorAscMaterialsSessionsBloc(this._dataService, this._telemetryService) : super(const CalculatorAscMaterialsSessionsState.loading()) {
    final itemAddedSubs = _dataService.calculator.itemAdded.stream.listen(
      (e) => add(CalculatorAscMaterialsSessionsEvent.itemAdded(sessionKey: e.sessionKey, isCharacter: e.isCharacter)),
    );
    final itemDeletedSubs = _dataService.calculator.itemDeleted.stream.listen(
      (e) => add(CalculatorAscMaterialsSessionsEvent.itemDeleted(sessionKey: e.sessionKey, isCharacter: e.isCharacter)),
    );

    _calcItemSubscriptions.add(itemAddedSubs);
    _calcItemSubscriptions.add(itemDeletedSubs);
  }

  @override
  Stream<CalculatorAscMaterialsSessionsState> mapEventToState(CalculatorAscMaterialsSessionsEvent event) async* {
    if (state is! _LoadedState && event is! _Init) {
      throw Exception('Invalid state');
    }

    final s = await event.map(
      init: (_) async => _init(),
      createSession: (e) async => _createSession(e.name, e.showMaterialUsage),
      updateSession: (e) async => _updateSession(e.key, e.name, e.showMaterialUsage),
      deleteSession: (e) async => _deleteSession(e.key),
      deleteAllSessions: (_) async => _deleteAllSessions(),
      itemsReordered: (e) async => _itemsReordered(e.updated),
      itemAdded: (e) async => _changeItemCount(e.sessionKey, true, e.isCharacter),
      itemDeleted: (e) async => _changeItemCount(e.sessionKey, false, e.isCharacter),
    );

    yield s;
  }

  @override
  Future<void> close() async {
    await Future.wait(_calcItemSubscriptions.map((e) => e.cancel()));
    return super.close();
  }

  Future<CalculatorAscMaterialsSessionsState> _init() async {
    await _telemetryService.trackCalculatorAscMaterialsSessionsLoaded();
    final sessions = _dataService.calculator.getAllSessions();
    return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
  }

  Future<CalculatorAscMaterialsSessionsState> _createSession(String name, bool showMaterialUsage) async {
    if (name.isNullEmptyOrWhitespace) {
      throw Exception('The provided session name is not valid');
    }

    await _telemetryService.trackCalculatorAscMaterialsSessionsCreated();
    final createdSession = await _dataService.calculator.createSession(name.trim(), currentState.sessions.length, showMaterialUsage);
    final sessions = [...currentState.sessions, createdSession];
    return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
  }

  Future<CalculatorAscMaterialsSessionsState> _updateSession(int key, String name, bool showMaterialUsage) async {
    if (key < 0) {
      throw Exception('SessionKey = $key is not valid');
    }

    if (name.isNullEmptyOrWhitespace) {
      throw Exception('The provided session name is not valid');
    }

    final CalculatorSessionModel? current = currentState.sessions.firstWhereOrDefault((el) => el.key == key);
    if (current == null) {
      throw Exception('SessionKey = $key does not exist');
    }
    await _telemetryService.trackCalculatorAscMaterialsSessionsUpdated();
    final updatedSession = await _dataService.calculator.updateSession(key, name.trim(), showMaterialUsage);
    final index = currentState.sessions.indexOf(current);
    final sessions = [...currentState.sessions];
    sessions.removeAt(index);
    sessions.insert(index, updatedSession);
    return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
  }

  Future<CalculatorAscMaterialsSessionsState> _deleteSession(int key) async {
    if (key < 0) {
      throw Exception('SessionKey = $key is not valid');
    }
    await _telemetryService.trackCalculatorAscMaterialsSessionsDeleted();
    await _dataService.calculator.deleteSession(key);
    final sessions = [...currentState.sessions];
    sessions.removeWhere((el) => el.key == key);
    return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
  }

  Future<CalculatorAscMaterialsSessionsState> _deleteAllSessions() async {
    await _telemetryService.trackCalculatorAscMaterialsSessionsDeleted(all: true);
    await _dataService.calculator.deleteAllSessions();
    return const CalculatorAscMaterialsSessionsState.loaded(sessions: []);
  }

  Future<CalculatorAscMaterialsSessionsState> _itemsReordered(List<CalculatorSessionModel> updated) async {
    if (updated.isEmpty) {
      throw Exception('The updated reordered items are empty');
    }

    await _dataService.calculator.reorderSessions(updated);
    final sessions = _dataService.calculator.getAllSessions();
    return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
  }

  CalculatorAscMaterialsSessionsState _changeItemCount(int sessionKey, bool added, bool isCharacter) {
    final CalculatorSessionModel? session = currentState.sessions.firstWhereOrDefault((session) => session.key == sessionKey);
    if (session == null) {
      return currentState;
    }
    final index = currentState.sessions.indexOf(session);
    final updatedSessions = [...currentState.sessions];
    updatedSessions.removeAt(index);

    int count = isCharacter ? session.numberOfCharacters : session.numberOfWeapons;
    if (added) {
      count++;
    } else {
      count--;
    }
    if (count < 0) {
      count = 0;
    }
    final updatedSession = isCharacter ? session.copyWith(numberOfCharacters: count) : session.copyWith(numberOfWeapons: count);
    updatedSessions.insert(index, updatedSession);
    return currentState.copyWith(sessions: updatedSessions);
  }
}
