part of 'calculator_asc_materials_sessions_bloc.dart';

@freezed
class CalculatorAscMaterialsSessionsState with _$CalculatorAscMaterialsSessionsState {
  const factory CalculatorAscMaterialsSessionsState.loading() = _LoadingState;

  const factory CalculatorAscMaterialsSessionsState.loaded({
    required List<CalculatorSessionModel> sessions,
  }) = _LoadedState;
}
