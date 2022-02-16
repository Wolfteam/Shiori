import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';

part 'calculator_asc_materials_order_bloc.freezed.dart';
part 'calculator_asc_materials_order_event.dart';
part 'calculator_asc_materials_order_state.dart';

const _initialState = CalculatorAscMaterialsOrderState.initial(sessionKey: -1, items: []);

class CalculatorAscMaterialsOrderBloc extends Bloc<CalculatorAscMaterialsOrderEvent, CalculatorAscMaterialsOrderState> {
  final DataService _dataService;
  final CalculatorAscMaterialsBloc _calculatorAscMaterialsBloc;

  CalculatorAscMaterialsOrderBloc(this._dataService, this._calculatorAscMaterialsBloc) : super(_initialState);

  @override
  Stream<CalculatorAscMaterialsOrderState> mapEventToState(CalculatorAscMaterialsOrderEvent event) async* {
    final s = await event.map(
      init: (e) async => state.copyWith.call(sessionKey: e.sessionKey, items: [...e.items]),
      positionChanged: (e) async {
        final updatedItems = state.items.moveTo(e.oldIndex, e.newIndex);
        return state.copyWith.call(items: updatedItems);
      },
      applyChanges: (_) async {
        for (var i = 0; i < state.items.length; i++) {
          final item = state.items[i];
          await _dataService.updateCalAscMatSessionItem(state.sessionKey, i, item, redistribute: false);
        }

        await _dataService.redistributeAllInventoryMaterials();

        _calculatorAscMaterialsBloc.add(CalculatorAscMaterialsEvent.init(sessionKey: state.sessionKey));

        return state;
      },
    );

    yield s;
  }
}
