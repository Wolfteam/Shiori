import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';

void main() {
  test('Initial state', () => expect(MainTabBloc().state, const MainTabState.initial(2)));

  group('Tab changed', () {
    blocTest<MainTabBloc, MainTabState>(
      'Tab changed and is valid',
      build: () => MainTabBloc(),
      act: (bloc) => bloc.add(const MainTabEvent.goToTab(index: 1)),
      expect: () => const [MainTabState.initial(1)],
    );

    blocTest<MainTabBloc, MainTabState>(
      'Tab changed and is not valid',
      build: () => MainTabBloc(),
      act: (bloc) => bloc..add(const MainTabEvent.goToTab(index: 1))..add(const MainTabEvent.goToTab(index: -1)),
      expect: () => const [MainTabState.initial(1)],
    );
  });
}
