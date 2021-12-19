import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';

void main() {
  test('Initial state', () => expect(TierListFormBloc().state, const TierListFormState.loaded(name: '', isNameDirty: false, isNameValid: false)));

  group('Name changed', () {
    blocTest<TierListFormBloc, TierListFormState>(
      'valid value',
      build: () => TierListFormBloc(),
      act: (bloc) => bloc.add(const TierListFormEvent.nameChanged(name: 'SSS')),
      expect: () => const [
        TierListFormState.loaded(name: 'SSS', isNameDirty: true, isNameValid: true),
      ],
    );

    blocTest<TierListFormBloc, TierListFormState>(
      'invalid value',
      build: () => TierListFormBloc(),
      act: (bloc) => bloc
        ..add(const TierListFormEvent.nameChanged(name: 'SSS'))
        ..add(const TierListFormEvent.nameChanged(name: '')),
      skip: 1,
      expect: () => const [
        TierListFormState.loaded(name: '', isNameDirty: true, isNameValid: false),
      ],
    );
  });
}
