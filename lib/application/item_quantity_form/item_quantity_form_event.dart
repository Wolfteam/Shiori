part of 'item_quantity_form_bloc.dart';

@freezed
abstract class ItemQuantityFormEvent implements _$ItemQuantityFormEvent {
  const factory ItemQuantityFormEvent.quantityChanged({
    @required int quantity,
  }) = _QuantityChange;

  const factory ItemQuantityFormEvent.close() = _Close;
}
