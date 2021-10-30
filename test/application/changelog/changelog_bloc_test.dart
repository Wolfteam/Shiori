import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/changelog/changelog_bloc.dart';
import 'package:shiori/domain/services/changelog_provider.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../mocks.mocks.dart';

void main() {
  late ChangelogProvider _changelogProvider;
  late ChangelogBloc _changelogBloc;

  setUpAll(() {
    _changelogProvider = ChangelogProviderImpl(MockLoggingService(), NetworkServiceImpl());
    _changelogBloc = ChangelogBloc(_changelogProvider);
  });

  test('Initial state', () => expect(_changelogBloc.state, const ChangelogState.loading()));

  blocTest<ChangelogBloc, ChangelogState>(
    'Retrieve changelog',
    build: () => ChangelogBloc(_changelogProvider),
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
}
