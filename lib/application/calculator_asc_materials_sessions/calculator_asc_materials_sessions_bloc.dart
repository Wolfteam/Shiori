import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';
import 'package:meta/meta.dart';

part 'calculator_asc_materials_sessions_bloc.freezed.dart';
part 'calculator_asc_materials_sessions_event.dart';
part 'calculator_asc_materials_sessions_state.dart';

class CalculatorAscMaterialsSessionsBloc extends Bloc<CalculatorAscMaterialsSessionsEvent, CalculatorAscMaterialsSessionsState> {
  final DataService _dataService;
  final TelemetryService _telemetryService;

  _LoadedState get currentState => state as _LoadedState;

  CalculatorAscMaterialsSessionsBloc(this._dataService, this._telemetryService) : super(const CalculatorAscMaterialsSessionsState.loading());

  @override
  Stream<CalculatorAscMaterialsSessionsState> mapEventToState(CalculatorAscMaterialsSessionsEvent event) async* {
    final s = await event.map(
      init: (_) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsLoaded();
        final sessions = _dataService.getAllCalAscMatSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      createSession: (e) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsCreated();
        await _dataService.createCalAscMatSession(e.name.trim(), currentState.sessions.length);
        final sessions = _dataService.getAllCalAscMatSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      updateSession: (e) async {
        final position = currentState.sessions.firstWhere((el) => el.key == e.key).position;
        await _telemetryService.trackCalculatorAscMaterialsSessionsUpdated();
        await _dataService.updateCalAscMatSession(e.key, e.name.trim(), position);
        final sessions = _dataService.getAllCalAscMatSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      deleteSession: (e) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsDeleted();
        await _dataService.deleteCalAscMatSession(e.key);
        final sessions = _dataService.getAllCalAscMatSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      close: (e) async => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      deleteAllSessions: (_) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsDeleted(all: true);
        await _dataService.deleteAllCalAscMatSession();
        return const CalculatorAscMaterialsSessionsState.loaded(sessions: []);
      },
    );

    yield s;
  }
}
