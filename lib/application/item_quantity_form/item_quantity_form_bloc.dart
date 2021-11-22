import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

part 'item_quantity_form_bloc.freezed.dart';
part 'item_quantity_form_event.dart';
part 'item_quantity_form_state.dart';

const _defaultState = ItemQuantityFormState.loaded(quantity: 0, isQuantityDirty: false, isQuantityValid: true);

class ItemQuantityFormBloc extends Bloc<ItemQuantityFormEvent, ItemQuantityFormState> {
  ItemQuantityFormBloc() : super(_defaultState);

  static int maxQuantity = 9999999999;

  @override
  Stream<ItemQuantityFormState> mapEventToState(ItemQuantityFormEvent event) async* {
    final s = event.map(
      quantityChanged: (e) {
        final isValid = e.quantity >= 0 && e.quantity <= maxQuantity;
        final isDirty = e.quantity != state.quantity;

        return state.copyWith.call(quantity: e.quantity, isQuantityDirty: isDirty, isQuantityValid: isValid);
      },
    );

    yield s;
  }
}
