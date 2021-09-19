part of 'calculator_asc_materials_item_update_quantity_bloc.dart';

@freezed
class CalculatorAscMaterialsItemUpdateQuantityState with _$CalculatorAscMaterialsItemUpdateQuantityState {
  const factory CalculatorAscMaterialsItemUpdateQuantityState.loading() = _LoadingState;

  const factory CalculatorAscMaterialsItemUpdateQuantityState.loaded({
    required String key,
    required int quantity,
  }) = _LoadedState;

  const factory CalculatorAscMaterialsItemUpdateQuantityState.saved({
    required String key,
    required int quantity,
  }) = _SavedState;
}
