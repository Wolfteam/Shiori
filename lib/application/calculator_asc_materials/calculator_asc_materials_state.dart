part of 'calculator_asc_materials_bloc.dart';

@freezed
abstract class CalculatorAscMaterialsState with _$CalculatorAscMaterialsState {
  const factory CalculatorAscMaterialsState.initial({
    @required List<ItemAscensionMaterials> items,
    @required List<AscensionMaterialsSummary> summary,
  }) = _InitialState;
}
