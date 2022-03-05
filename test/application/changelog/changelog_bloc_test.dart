import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/changelog/changelog_bloc.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../mocks.mocks.dart';

void main() {
  ChangelogBloc _getBloc({bool noInternetConnection = false}) {
    final networkService = MockNetworkService();
    when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(!noInternetConnection));
    final changelogProvider = ChangelogProviderImpl(MockLoggingService(), networkService);
    return ChangelogBloc(changelogProvider);
  }

  test('Initial state', () => expect(_getBloc().state, const ChangelogState.loading()));

  group('changelog', () {
    blocTest<ChangelogBloc, ChangelogState>(
      'retrieved',
      build: () => _getBloc(),
      act: (bloc) => bloc.add(const ChangelogEvent.init()),
      verify: (bloc) {
        bloc.state.map(
          loading: (_) => throw Exception('Invalid state'),
          loadedState: (state) {
            expect(state.changelog, isNotEmpty);
          },
        );
      },
    );

    blocTest<ChangelogBloc, ChangelogState>(
      'no internet connection',
      build: () => _getBloc(noInternetConnection: true),
      act: (bloc) => bloc.add(const ChangelogEvent.init()),
      verify: (bloc) {
        bloc.state.map(
          loading: (_) => throw Exception('Invalid state'),
          loadedState: (state) {
            expect(state.changelog, isNotEmpty);
          },
        );
      },
    );
  });
}
