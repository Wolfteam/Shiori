import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_quantity_form_bloc.freezed.dart';
part 'item_quantity_form_event.dart';
part 'item_quantity_form_state.dart';

const _defaultState = ItemQuantityFormState.loaded(quantity: 0, isQuantityDirty: false, isQuantityValid: true);

class ItemQuantityFormBloc extends Bloc<ItemQuantityFormEvent, ItemQuantityFormState> {
  ItemQuantityFormBloc() : super(_defaultState) {
    on<ItemQuantityFormEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  static int maxQuantity = 9999999999;

  Future<void> _mapEventToState(ItemQuantityFormEvent event, Emitter<ItemQuantityFormState> emit) async {
    switch (event) {
      case ItemQuantityFormEventQuantityChange():
        final isValid = event.quantity >= 0 && event.quantity <= maxQuantity;
        final isDirty = event.quantity != state.quantity;

        final newState = state.copyWith.call(quantity: event.quantity, isQuantityDirty: isDirty, isQuantityValid: isValid);
        emit(newState);
    }
  }
}
