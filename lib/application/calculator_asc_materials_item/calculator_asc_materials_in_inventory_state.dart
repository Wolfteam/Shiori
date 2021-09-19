part of 'calculator_asc_materials_in_inventory_bloc.dart';

@freezed
class CalculatorAscMaterialsInInventoryState with _$CalculatorAscMaterialsInInventoryState {
  const factory CalculatorAscMaterialsInInventoryState.loading() = _LoadingState;

  const factory CalculatorAscMaterialsInInventoryState.loaded({
    required String key,
    required int quantity,
  }) = _LoadedState;

  const factory CalculatorAscMaterialsInInventoryState.saved({
    required String key,
    required int quantity,
  }) = _SavedState;
}