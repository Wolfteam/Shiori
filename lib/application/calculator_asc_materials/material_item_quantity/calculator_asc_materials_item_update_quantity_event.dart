part of 'calculator_asc_materials_item_update_quantity_bloc.dart';

@freezed
class CalculatorAscMaterialsItemUpdateQuantityEvent with _$CalculatorAscMaterialsItemUpdateQuantityEvent {
  const factory CalculatorAscMaterialsItemUpdateQuantityEvent.load({
    required String key,
  }) = _Load;

  const factory CalculatorAscMaterialsItemUpdateQuantityEvent.update({
    required String key,
    required int quantity,
  }) = _Update;
}
