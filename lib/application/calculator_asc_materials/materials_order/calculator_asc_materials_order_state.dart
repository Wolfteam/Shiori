part of 'calculator_asc_materials_order_bloc.dart';

@freezed
class CalculatorAscMaterialsOrderState with _$CalculatorAscMaterialsOrderState {
  const factory CalculatorAscMaterialsOrderState.initial({
    required int sessionKey,
    required List<ItemAscensionMaterials> items,
  }) = _InitialState;
}
