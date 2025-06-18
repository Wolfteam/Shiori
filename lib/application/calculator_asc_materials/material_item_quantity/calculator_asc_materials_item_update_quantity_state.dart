part of 'calculator_asc_materials_item_update_quantity_bloc.dart';

@freezed
sealed class CalculatorAscMaterialsItemUpdateQuantityState with _$CalculatorAscMaterialsItemUpdateQuantityState {
  const factory CalculatorAscMaterialsItemUpdateQuantityState.loading() = CalculatorAscMaterialsItemUpdateQuantityStateLoading;

  const factory CalculatorAscMaterialsItemUpdateQuantityState.loaded({
    required String key,
    required int quantity,
  }) = CalculatorAscMaterialsItemUpdateQuantityStateLoaded;

  const factory CalculatorAscMaterialsItemUpdateQuantityState.saved({
    required String key,
    required int quantity,
  }) = CalculatorAscMaterialsItemUpdateQuantityStateSaved;
}
