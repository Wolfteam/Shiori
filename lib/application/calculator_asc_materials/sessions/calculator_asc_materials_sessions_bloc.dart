import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'calculator_asc_materials_sessions_bloc.freezed.dart';
part 'calculator_asc_materials_sessions_event.dart';
part 'calculator_asc_materials_sessions_state.dart';

class CalculatorAscMaterialsSessionsBloc extends Bloc<CalculatorAscMaterialsSessionsEvent, CalculatorAscMaterialsSessionsState> {
  final DataService _dataService;
  final TelemetryService _telemetryService;

  final List<StreamSubscription> subscriptions = [];

  _LoadedState get currentState => state as _LoadedState;

  CalculatorAscMaterialsSessionsBloc(this._dataService, this._telemetryService) : super(const CalculatorAscMaterialsSessionsState.loading()) {
    final itemAddedSubs = _dataService.calculator.itemAdded.stream.listen(
      (e) => add(CalculatorAscMaterialsSessionsEvent.itemAdded(sessionKey: e.sessionKey, isCharacter: e.isCharacter)),
    );
    final itemDeletedSubs = _dataService.calculator.itemDeleted.stream.listen(
      (e) => add(CalculatorAscMaterialsSessionsEvent.itemDeleted(sessionKey: e.sessionKey, isCharacter: e.isCharacter)),
    );

    subscriptions.add(itemAddedSubs);
    subscriptions.add(itemDeletedSubs);
  }

  @override
  Stream<CalculatorAscMaterialsSessionsState> mapEventToState(CalculatorAscMaterialsSessionsEvent event) async* {
    final s = await event.map(
      init: (_) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsLoaded();
        final sessions = _dataService.calculator.getAllSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      createSession: (e) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsCreated();
        await _dataService.calculator.createSession(e.name.trim(), currentState.sessions.length);
        final sessions = _dataService.calculator.getAllSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      updateSession: (e) async {
        final position = currentState.sessions.firstWhere((el) => el.key == e.key).position;
        await _telemetryService.trackCalculatorAscMaterialsSessionsUpdated();
        await _dataService.calculator.updateSession(e.key, e.name.trim(), position);
        final sessions = _dataService.calculator.getAllSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      deleteSession: (e) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsDeleted();
        await _dataService.calculator.deleteSession(e.key);
        final sessions = _dataService.calculator.getAllSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      deleteAllSessions: (_) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsDeleted(all: true);
        await _dataService.calculator.deleteAllSessions();
        return const CalculatorAscMaterialsSessionsState.loaded(sessions: []);
      },
      itemsReordered: (e) async => _itemsReordered(e.updated),
      itemAdded: (e) async => state.map(
        loaded: (state) => _changeItemCount(e.sessionKey, true, e.isCharacter),
        loading: (_) => throw Exception('Invalid state'),
      ),
      itemDeleted: (e) async => state.map(
        loaded: (state) => _changeItemCount(e.sessionKey, false, e.isCharacter),
        loading: (_) => throw Exception('Invalid state'),
      ),
    );

    yield s;
  }

  @override
  Future<void> close() async {
    await Future.wait(subscriptions.map((e) => e.cancel()));
    return super.close();
  }

  Future<CalculatorAscMaterialsSessionsState> _itemsReordered(List<CalculatorSessionModel> updated) async {
    assert(currentState.sessions.length == updated.length);
    for (int i = 0; i < updated.length; i++) {
      final updatedSession = updated[i];
      await _dataService.calculator.updateSession(updatedSession.key, updatedSession.name, i);
    }

    await _dataService.calculator.redistributeAllInventoryMaterials();

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
