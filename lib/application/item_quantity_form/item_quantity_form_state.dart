part of 'item_quantity_form_bloc.dart';

@freezed
abstract class ItemQuantityFormState implements _$ItemQuantityFormState {
  const factory ItemQuantityFormState.loaded({
    @required int quantity,
    @required bool isQuantityDirty,
    @required bool isQuantityValid,
  }) = _LoadedState;
}
