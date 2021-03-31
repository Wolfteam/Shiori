part of 'calculator_asc_materials_session_form_bloc.dart';

@freezed
abstract class CalculatorAscMaterialsSessionFormEvent implements _$CalculatorAscMaterialsSessionFormEvent {
  const factory CalculatorAscMaterialsSessionFormEvent.nameChanged({
    @required String name,
  }) = _NameChanged;

  const factory CalculatorAscMaterialsSessionFormEvent.close() = _Close;
}
