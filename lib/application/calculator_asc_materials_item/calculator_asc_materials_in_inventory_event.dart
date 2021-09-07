part of 'calculator_asc_materials_in_inventory_bloc.dart';

@freezed
class CalculatorAscMaterialsInInventoryEvent with _$CalculatorAscMaterialsInInventoryEvent {
  const factory CalculatorAscMaterialsInInventoryEvent.load({
    required String image,
  }) = _Load;

  const factory CalculatorAscMaterialsInInventoryEvent.update({
    required String key,
    required int quantity,
  }) = _Update;

  const factory CalculatorAscMaterialsInInventoryEvent.close() = _Close;
}