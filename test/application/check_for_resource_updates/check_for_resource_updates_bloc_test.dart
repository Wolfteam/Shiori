import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

import '../../mocks.mocks.dart';

void main() {
  CheckForResourceUpdatesBloc _getBloc({
    String appVersion = '1.0.0',
    int currentResourcesVersion = -1,
    CheckForUpdatesResult? checkForUpdateResult,
  }) {
    final result = checkForUpdateResult ??
        CheckForUpdatesResult(
          resourceVersion: currentResourcesVersion,
          type: AppResourceUpdateResultType.noUpdatesAvailable,
        );
    final deviceInfoService = MockDeviceInfoService();
    when(deviceInfoService.version).thenReturn(appVersion);
    final resourceService = MockResourceService();
    when(resourceService.checkForUpdates(appVersion, currentResourcesVersion)).thenAnswer((_) => Future.value(result));
    final settingsService = MockSettingsService();
    when(settingsService.resourceVersion).thenReturn(currentResourcesVersion);
    return CheckForResourceUpdatesBloc(resourceService, settingsService, deviceInfoService, MockTelemetryService());
  }

  test('Initial state', () => expect(_getBloc().state, const CheckForResourceUpdatesState.loading()));

  group('Init', () {
    void _checkState(CheckForResourceUpdatesState state, AppResourceUpdateResultType resultType, int currentResourcesVersion,
        {int? targetResourceVersion}) {
      state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          expect(state.updateResultType, resultType);
          expect(state.currentResourceVersion, currentResourcesVersion);
          expect(state.targetResourceVersion, targetResourceVersion);
        },
      );
    }

    blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
      'unknown error',
      build: () => _getBloc(
        checkForUpdateResult: const CheckForUpdatesResult(
          type: AppResourceUpdateResultType.unknownError,
          resourceVersion: -1,
        ),
      ),
      act: (bloc) => bloc.add(const CheckForResourceUpdatesEvent.init()),
      verify: (bloc) => _checkState(bloc.state, AppResourceUpdateResultType.unknownError, -1),
    );

    blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
      'no updates available',
      build: () => _getBloc(),
      act: (bloc) => bloc.add(const CheckForResourceUpdatesEvent.init()),
      verify: (bloc) => _checkState(bloc.state, AppResourceUpdateResultType.noUpdatesAvailable, -1),
    );

    blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
      'needs latest app version',
      build: () => _getBloc(
        checkForUpdateResult: const CheckForUpdatesResult(
          type: AppResourceUpdateResultType.needsLatestAppVersion,
          resourceVersion: 2,
        ),
      ),
      act: (bloc) => bloc.add(const CheckForResourceUpdatesEvent.init()),
      verify: (bloc) => _checkState(bloc.state, AppResourceUpdateResultType.needsLatestAppVersion, -1, targetResourceVersion: 2),
    );

    blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
      'needs latest app version',
      build: () => _getBloc(
        checkForUpdateResult: const CheckForUpdatesResult(
          type: AppResourceUpdateResultType.noInternetConnectionForFirstInstall,
          resourceVersion: 2,
        ),
      ),
      act: (bloc) => bloc.add(const CheckForResourceUpdatesEvent.init()),
      verify: (bloc) => _checkState(bloc.state, AppResourceUpdateResultType.noInternetConnectionForFirstInstall, -1, targetResourceVersion: 2),
    );

    blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
      'updates available',
      build: () => _getBloc(
        checkForUpdateResult: const CheckForUpdatesResult(
          type: AppResourceUpdateResultType.updatesAvailable,
          resourceVersion: 2,
        ),
      ),
      act: (bloc) => bloc.add(const CheckForResourceUpdatesEvent.init()),
      verify: (bloc) => _checkState(bloc.state, AppResourceUpdateResultType.updatesAvailable, -1, targetResourceVersion: 2),
    );
  });
}
