import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_quantity_form_bloc.freezed.dart';
part 'item_quantity_form_event.dart';
part 'item_quantity_form_state.dart';

const _defaultState = ItemQuantityFormState.loaded(quantity: 0, isQuantityDirty: false, isQuantityValid: true);

class ItemQuantityFormBloc extends Bloc<ItemQuantityFormEvent, ItemQuantityFormState> {
  ItemQuantityFormBloc() : super(_defaultState);

  static int maxQuantity = 9999999999;

  @override
  Stream<ItemQuantityFormState> mapEventToState(ItemQuantityFormEvent event) async* {
    switch (event) {
      case ItemQuantityFormEventQuantityChange():
        final isValid = event.quantity >= 0 && event.quantity <= maxQuantity;
        final isDirty = event.quantity != state.quantity;

        yield state.copyWith.call(quantity: event.quantity, isQuantityDirty: isDirty, isQuantityValid: isValid);
    }
  }
}
