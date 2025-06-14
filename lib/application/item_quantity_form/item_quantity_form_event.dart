part of 'item_quantity_form_bloc.dart';

@freezed
sealed class ItemQuantityFormEvent with _$ItemQuantityFormEvent {
  const factory ItemQuantityFormEvent.quantityChanged({
    required int quantity,
  }) = ItemQuantityFormEventQuantityChange;
}
