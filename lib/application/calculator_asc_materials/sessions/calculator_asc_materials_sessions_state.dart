part of 'calculator_asc_materials_sessions_bloc.dart';

@freezed
sealed class CalculatorAscMaterialsSessionsState with _$CalculatorAscMaterialsSessionsState {
  const factory CalculatorAscMaterialsSessionsState.loading() = CalculatorAscMaterialsSessionsStateLoading;

  const factory CalculatorAscMaterialsSessionsState.loaded({
    required List<CalculatorSessionModel> sessions,
  }) = CalculatorAscMaterialsSessionsStateLoaded;
}
