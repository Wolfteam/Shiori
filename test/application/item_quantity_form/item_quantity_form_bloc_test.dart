import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';

void main() {
  const _defaultState = ItemQuantityFormState.loaded(quantity: 0, isQuantityDirty: false, isQuantityValid: true);

  test('Initial state', () => expect(ItemQuantityFormBloc().state, _defaultState));

  group('Quantity changed', () {
    blocTest<ItemQuantityFormBloc, ItemQuantityFormState>(
      'quantity should be valid',
      build: () => ItemQuantityFormBloc(),
      act: (bloc) => bloc.add(const ItemQuantityFormEvent.quantityChanged(quantity: 100)),
      expect: () => const [ItemQuantityFormState.loaded(quantity: 100, isQuantityDirty: true, isQuantityValid: true)],
    );

    blocTest<ItemQuantityFormBloc, ItemQuantityFormState>(
      'quantity should not be valid',
      build: () => ItemQuantityFormBloc(),
      act: (bloc) => bloc.add(const ItemQuantityFormEvent.quantityChanged(quantity: -100)),
      expect: () => const [ItemQuantityFormState.loaded(quantity: -100, isQuantityDirty: true, isQuantityValid: false)],
    );

    blocTest<ItemQuantityFormBloc, ItemQuantityFormState>(
      'quantity exceeds the max allowed value and should not be valid',
      build: () => ItemQuantityFormBloc(),
      act: (bloc) => bloc.add(ItemQuantityFormEvent.quantityChanged(quantity: ItemQuantityFormBloc.maxQuantity + 1)),
      expect: () => [ItemQuantityFormState.loaded(quantity: ItemQuantityFormBloc.maxQuantity + 1, isQuantityDirty: true, isQuantityValid: false)],
    );
  });
}
