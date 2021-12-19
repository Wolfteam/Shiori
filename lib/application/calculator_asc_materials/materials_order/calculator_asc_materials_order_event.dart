part of 'calculator_asc_materials_order_bloc.dart';

@freezed
class CalculatorAscMaterialsOrderEvent with _$CalculatorAscMaterialsOrderEvent {
  const factory CalculatorAscMaterialsOrderEvent.init({
    required int sessionKey,
    required List<ItemAscensionMaterials> items,
  }) = _Init;

  const factory CalculatorAscMaterialsOrderEvent.positionChanged({
    required int oldIndex,
    required int newIndex,
  }) = _PositionChanged;

  const factory CalculatorAscMaterialsOrderEvent.applyChanges() = _ApplyChanges;
}
