part of 'calculator_asc_materials_sessions_order_bloc.dart';

@freezed
class CalculatorAscMaterialsSessionsOrderEvent with _$CalculatorAscMaterialsSessionsOrderEvent {
  const factory CalculatorAscMaterialsSessionsOrderEvent.init({
    required List<CalculatorSessionModel> sessions,
  }) = _Init;

  const factory CalculatorAscMaterialsSessionsOrderEvent.positionChanged({
    required int oldIndex,
    required int newIndex,
  }) = _PositionChanged;

  const factory CalculatorAscMaterialsSessionsOrderEvent.applyChanges() = _ApplyChanges;

  const factory CalculatorAscMaterialsSessionsOrderEvent.discardChanges() = _DiscardChanged;
}
