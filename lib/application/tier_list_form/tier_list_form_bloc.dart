import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';

part 'tier_list_form_bloc.freezed.dart';
part 'tier_list_form_event.dart';
part 'tier_list_form_state.dart';

const _initialState = TierListFormState.loaded(name: '', isNameDirty: false, isNameValid: false);

class TierListFormBloc extends Bloc<TierListFormEvent, TierListFormState> {
  TierListFormBloc() : super(_initialState);

  static int nameMaxLength = 25;

  @override
  Stream<TierListFormState> mapEventToState(TierListFormEvent event) async* {
    switch (event) {
      case TierListFormEventNameChanged():
        final isValid = event.name.isNotNullEmptyOrWhitespace && event.name.length <= nameMaxLength;
        final isDirty = event.name != state.name;

        yield state.copyWith.call(name: event.name, isNameDirty: isDirty, isNameValid: isValid);
    }
  }
}
