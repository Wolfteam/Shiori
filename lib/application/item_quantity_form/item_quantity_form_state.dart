part of 'item_quantity_form_bloc.dart';

@freezed
sealed class ItemQuantityFormState with _$ItemQuantityFormState {
  const factory ItemQuantityFormState.loaded({
    required int quantity,
    required bool isQuantityDirty,
    required bool isQuantityValid,
  }) = ItemQuantityFormStateLoaded;
}
