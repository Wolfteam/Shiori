part of 'calculator_asc_materials_session_form_bloc.dart';

@freezed
class CalculatorAscMaterialsSessionFormEvent with _$CalculatorAscMaterialsSessionFormEvent {
  const factory CalculatorAscMaterialsSessionFormEvent.nameChanged({
    required String name,
  }) = _NameChanged;
}
