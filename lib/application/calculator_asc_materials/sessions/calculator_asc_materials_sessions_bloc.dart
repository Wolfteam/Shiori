import 'dart:async';

import 'package:bloc/bloc.dart';
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

  _LoadedState get currentState => state as _LoadedState;

  CalculatorAscMaterialsSessionsBloc(this._dataService, this._telemetryService) : super(const CalculatorAscMaterialsSessionsState.loading());

  @override
  Stream<CalculatorAscMaterialsSessionsState> mapEventToState(CalculatorAscMaterialsSessionsEvent event) async* {
    final s = await event.map(
      init: (_) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsLoaded();
        final sessions = _dataService.calculator.getAllCalAscMatSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      createSession: (e) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsCreated();
        await _dataService.calculator.createCalAscMatSession(e.name.trim(), currentState.sessions.length);
        final sessions = _dataService.calculator.getAllCalAscMatSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      updateSession: (e) async {
        final position = currentState.sessions.firstWhere((el) => el.key == e.key).position;
        await _telemetryService.trackCalculatorAscMaterialsSessionsUpdated();
        await _dataService.calculator.updateCalAscMatSession(e.key, e.name.trim(), position);
        final sessions = _dataService.calculator.getAllCalAscMatSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      deleteSession: (e) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsDeleted();
        await _dataService.calculator.deleteCalAscMatSession(e.key);
        final sessions = _dataService.calculator.getAllCalAscMatSessions();
        return CalculatorAscMaterialsSessionsState.loaded(sessions: sessions);
      },
      deleteAllSessions: (_) async {
        await _telemetryService.trackCalculatorAscMaterialsSessionsDeleted(all: true);
        await _dataService.calculator.deleteAllCalAscMatSession();
        return const CalculatorAscMaterialsSessionsState.loaded(sessions: []);
      },
    );

    yield s;
  }
}
