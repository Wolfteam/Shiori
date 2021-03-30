part of 'calculator_asc_materials_order_bloc.dart';

@freezed
abstract class CalculatorAscMaterialsOrderState implements _$CalculatorAscMaterialsOrderState {
  const factory CalculatorAscMaterialsOrderState.initial({
    @required int sessionKey,
    @required List<ItemAscensionMaterials> items,
  }) = _InitialState;
}
