import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:meta/meta.dart';

part 'calculator_asc_materials_session_form_bloc.freezed.dart';
part 'calculator_asc_materials_session_form_event.dart';
part 'calculator_asc_materials_session_form_state.dart';

class CalculatorAscMaterialsSessionFormBloc extends Bloc<CalculatorAscMaterialsSessionFormEvent, CalculatorAscMaterialsSessionFormState> {
  CalculatorAscMaterialsSessionFormBloc()
      : super(const CalculatorAscMaterialsSessionFormState.loaded(name: '', isNameDirty: false, isNameValid: false));

  static int nameMaxLength = 25;

  @override
  Stream<CalculatorAscMaterialsSessionFormState> mapEventToState(CalculatorAscMaterialsSessionFormEvent event) async* {
    final s = event.map(
      nameChanged: (e) {
        final isValid = e.name.isNotNullEmptyOrWhitespace && e.name.length <= nameMaxLength;
        final isDirty = e.name != state.name;

        return state.copyWith.call(name: e.name, isNameDirty: isDirty, isNameValid: isValid);
      },
      close: (_) => const CalculatorAscMaterialsSessionFormState.loaded(name: '', isNameDirty: false, isNameValid: false),
    );

    yield s;
  }
}
