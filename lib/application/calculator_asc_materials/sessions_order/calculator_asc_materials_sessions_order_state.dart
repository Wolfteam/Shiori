part of 'calculator_asc_materials_sessions_order_bloc.dart';

@freezed
class CalculatorAscMaterialsSessionsOrderState with _$CalculatorAscMaterialsSessionsOrderState {
  const factory CalculatorAscMaterialsSessionsOrderState.initial({
    required List<CalculatorSessionModel> sessions,
  }) = _InitialState;
}
