import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';

part 'calculator_asc_materials_sessions_order_bloc.freezed.dart';
part 'calculator_asc_materials_sessions_order_event.dart';
part 'calculator_asc_materials_sessions_order_state.dart';

const _initialState = CalculatorAscMaterialsSessionsOrderState.initial(sessions: []);

class CalculatorAscMaterialsSessionsOrderBloc extends Bloc<CalculatorAscMaterialsSessionsOrderEvent, CalculatorAscMaterialsSessionsOrderState> {
  final DataService _dataService;
  final CalculatorAscMaterialsSessionsBloc _sessionsBloc;

  CalculatorAscMaterialsSessionsOrderBloc(this._dataService, this._sessionsBloc) : super(_initialState) {
    on<CalculatorAscMaterialsSessionsOrderEvent>((event, emit) => _mapEventToState(event, emit));
  }

  Future<void> _mapEventToState(CalculatorAscMaterialsSessionsOrderEvent event, Emitter<CalculatorAscMaterialsSessionsOrderState> emit) async {
    final s = await event.map(
      init: (e) async => state.copyWith.call(sessions: [...e.sessions]),
      positionChanged: (e) async {
        final updatedSessions = <CalculatorSessionModel>[];
        final session = state.sessions.elementAt(e.oldIndex);
        for (int i = 0; i < state.sessions.length; i++) {
          if (i == e.oldIndex) {
            continue;
          }
          final item = state.sessions[i];
          updatedSessions.add(item);
        }

        final newIndex = e.newIndex >= state.sessions.length ? state.sessions.length - 1 : e.newIndex;
        updatedSessions.insert(newIndex, session);
        return state.copyWith.call(sessions: updatedSessions);
      },
      applyChanges: (_) async {
        for (var i = 0; i < state.sessions.length; i++) {
          final session = state.sessions[i];
          await _dataService.calculator.updateCalAscMatSession(session.key, session.name, i);
        }

        await _dataService.calculator.redistributeAllInventoryMaterials();

        _sessionsBloc.add(const CalculatorAscMaterialsSessionsEvent.init());

        return state;
      },
    );

    emit(s);
  }
}
