import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/changelog/changelog_bloc.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../mocks.mocks.dart';

void main() {
  const _customChangelog = '''
        ### Changelog
        #### 1.6.0
        ''';

  ChangelogBloc _getBloc({ApiService? apiService, bool noInternetConnection = false}) {
    final networkService = MockNetworkService();
    when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(!noInternetConnection));
    final changelogProvider = ChangelogProviderImpl(MockLoggingService(), networkService, apiService ?? MockApiService());
    return ChangelogBloc(changelogProvider);
  }

  test('Initial state', () => expect(_getBloc().state, const ChangelogState.loading()));

  group('changelog', () {
    void _checkState(ChangelogState state, {String expectedChangelog = ChangelogProviderImpl.defaultChangelog}) {
      state.map(
        loading: (_) => throw Exception('Invalid state'),
        loadedState: (state) {
          expect(state.changelog == expectedChangelog, isTrue);
        },
      );
    }

    blocTest<ChangelogBloc, ChangelogState>(
      'default value retrieved',
      build: () => _getBloc(),
      act: (bloc) => bloc.add(const ChangelogEvent.init()),
      verify: (bloc) => _checkState(bloc.state),
    );

    blocTest<ChangelogBloc, ChangelogState>(
      'no internet connection',
      build: () => _getBloc(noInternetConnection: true),
      act: (bloc) => bloc.add(const ChangelogEvent.init()),
      verify: (bloc) => _checkState(bloc.state),
    );

    blocTest<ChangelogBloc, ChangelogState>(
      'api fails, returns default value',
      build: () {
        final apiService = MockApiService();
        when(apiService.getChangelog(ChangelogProviderImpl.defaultChangelog)).thenAnswer((_) => throw Exception('Unknown error'));
        return _getBloc();
      },
      act: (bloc) => bloc.add(const ChangelogEvent.init()),
      verify: (bloc) => _checkState(bloc.state),
    );

    blocTest<ChangelogBloc, ChangelogState>(
      'api succeeds, returns custom value',
      build: () {
        final apiService = MockApiService();
        when(apiService.getChangelog(ChangelogProviderImpl.defaultChangelog)).thenAnswer((_) => Future.value(_customChangelog));
        return _getBloc(apiService: apiService);
      },
      act: (bloc) => bloc.add(const ChangelogEvent.init()),
      verify: (bloc) => _checkState(bloc.state, expectedChangelog: _customChangelog),
    );
  });
}
