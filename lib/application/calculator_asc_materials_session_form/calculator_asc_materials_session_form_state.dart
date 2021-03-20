part of 'calculator_asc_materials_session_form_bloc.dart';

@freezed
abstract class CalculatorAscMaterialsSessionFormState implements _$CalculatorAscMaterialsSessionFormState {
  const factory CalculatorAscMaterialsSessionFormState.loaded({
    @required String name,
    @required bool isNameDirty,
    @required bool isNameValid,
  }) = _LoadedState;
}
