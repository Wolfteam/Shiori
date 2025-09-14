import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';

part 'tier_list_form_bloc.freezed.dart';
part 'tier_list_form_event.dart';
part 'tier_list_form_state.dart';

const _initialState = TierListFormState.loaded(name: '', isNameDirty: false, isNameValid: false);

class TierListFormBloc extends Bloc<TierListFormEvent, TierListFormState> {
  TierListFormBloc() : super(_initialState) {
    on<TierListFormEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  static int nameMaxLength = 25;

  Future<void> _mapEventToState(TierListFormEvent event, Emitter<TierListFormState> emit) async {
    switch (event) {
      case TierListFormEventNameChanged():
        final isValid = event.name.isNotNullEmptyOrWhitespace && event.name.length <= nameMaxLength;
        final isDirty = event.name != state.name;

        emit(state.copyWith.call(name: event.name, isNameDirty: isDirty, isNameValid: isValid));
    }
  }
}
