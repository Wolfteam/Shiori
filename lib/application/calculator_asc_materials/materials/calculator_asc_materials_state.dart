part of 'calculator_asc_materials_bloc.dart';

@freezed
sealed class CalculatorAscMaterialsState with _$CalculatorAscMaterialsState {
  const factory CalculatorAscMaterialsState.initial({
    required int sessionKey,
    required bool showMaterialUsage,
    required List<ItemAscensionMaterials> items,
    required List<AscensionMaterialsSummary> summary,
  }) = CalculatorAscMaterialsStateInitial;
}
