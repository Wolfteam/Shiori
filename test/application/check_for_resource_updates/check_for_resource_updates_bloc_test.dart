import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/models.dart';

import '../../mocks.mocks.dart';

void main() {
  CheckForResourceUpdatesBloc getBloc({
    String appVersion = '1.0.0',
    int currentResourcesVersion = -1,
    CheckForUpdatesResult? checkForUpdateResult,
    bool updateResourceCheckedDate = false,
    bool noResourcesHaveBeenDownloaded = false,
  }) {
    final result =
        checkForUpdateResult ??
        CheckForUpdatesResult(
          resourceVersion: currentResourcesVersion,
          type: AppResourceUpdateResultType.noUpdatesAvailable,
        );
    final deviceInfoService = MockDeviceInfoService();
    when(deviceInfoService.version).thenReturn(appVersion);
    final resourceService = MockResourceService();
    when(
      resourceService.checkForUpdates(appVersion, currentResourcesVersion, updateResourceCheckedDate: updateResourceCheckedDate),
    ).thenAnswer((_) => Future.value(result));
    final settingsService = MockSettingsService();
    when(settingsService.resourceVersion).thenReturn(currentResourcesVersion);
    when(settingsService.noResourcesHasBeenDownloaded).thenReturn(noResourcesHaveBeenDownloaded);
    return CheckForResourceUpdatesBloc(resourceService, settingsService, deviceInfoService, MockTelemetryService());
  }

  test('Initial state', () => expect(getBloc().state, const CheckForResourceUpdatesState.loading(), reason: 'A freshly built CheckForResourceUpdatesBloc must start in loading before init'));

  blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
    'Init',
    build: () => getBloc(),
    act: (bloc) => bloc.add(const CheckForResourceUpdatesEvent.init()),
    verify: (bloc) {
      final state = bloc.state;
      switch (state) {
        case CheckForResourceUpdatesStateLoading():
          throw InvalidStateError();
        case CheckForResourceUpdatesStateLoaded():
          expect(state.updateResultType, isNull, reason: 'After init, no check has run yet so updateResultType must be null');
          expect(state.currentResourceVersion, -1, reason: 'After init, currentResourceVersion must reflect the settings value (-1)');
          expect(state.targetResourceVersion, isNull, reason: 'After init, no target version is known yet so targetResourceVersion must be null');
      }
    },
  );

  group('Check for updates', () {
    void checkState(
      CheckForResourceUpdatesState state,
      AppResourceUpdateResultType resultType,
      int currentResourcesVersion, {
      int? targetResourceVersion,
    }) {
      switch (state) {
        case CheckForResourceUpdatesStateLoading():
          throw InvalidStateError();
        case CheckForResourceUpdatesStateLoaded():
          expect(state.updateResultType, resultType, reason: 'After checkForUpdates, updateResultType must be $resultType');
          expect(state.currentResourceVersion, currentResourcesVersion, reason: 'After checkForUpdates, currentResourceVersion must be $currentResourcesVersion');
          expect(state.targetResourceVersion, targetResourceVersion, reason: 'After checkForUpdates, targetResourceVersion must be $targetResourceVersion');
      }
    }

    blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
      'unknown error',
      build: () => getBloc(
        checkForUpdateResult: const CheckForUpdatesResult(
          type: AppResourceUpdateResultType.unknownError,
          resourceVersion: -1,
        ),
      ),
      act: (bloc) => bloc
        ..add(const CheckForResourceUpdatesEvent.init())
        ..add(const CheckForResourceUpdatesEvent.checkForUpdates()),
      verify: (bloc) => checkState(bloc.state, AppResourceUpdateResultType.unknownError, -1),
    );

    blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
      'no updates available',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CheckForResourceUpdatesEvent.init())
        ..add(const CheckForResourceUpdatesEvent.checkForUpdates()),
      verify: (bloc) => checkState(bloc.state, AppResourceUpdateResultType.noUpdatesAvailable, -1),
    );

    blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
      'needs latest app version',
      build: () => getBloc(
        checkForUpdateResult: const CheckForUpdatesResult(
          type: AppResourceUpdateResultType.needsLatestAppVersion,
          resourceVersion: 2,
        ),
      ),
      act: (bloc) => bloc
        ..add(const CheckForResourceUpdatesEvent.init())
        ..add(const CheckForResourceUpdatesEvent.checkForUpdates()),
      verify: (bloc) => checkState(bloc.state, AppResourceUpdateResultType.needsLatestAppVersion, -1),
    );

    blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
      'needs latest app version',
      build: () => getBloc(
        checkForUpdateResult: const CheckForUpdatesResult(
          type: AppResourceUpdateResultType.noInternetConnectionForFirstInstall,
          resourceVersion: 2,
        ),
      ),
      act: (bloc) => bloc
        ..add(const CheckForResourceUpdatesEvent.init())
        ..add(const CheckForResourceUpdatesEvent.checkForUpdates()),
      verify: (bloc) => checkState(bloc.state, AppResourceUpdateResultType.noInternetConnectionForFirstInstall, -1),
    );

    blocTest<CheckForResourceUpdatesBloc, CheckForResourceUpdatesState>(
      'updates available',
      build: () => getBloc(
        checkForUpdateResult: const CheckForUpdatesResult(
          type: AppResourceUpdateResultType.updatesAvailable,
          resourceVersion: 2,
        ),
      ),
      act: (bloc) => bloc
        ..add(const CheckForResourceUpdatesEvent.init())
        ..add(const CheckForResourceUpdatesEvent.checkForUpdates()),
      verify: (bloc) => checkState(bloc.state, AppResourceUpdateResultType.updatesAvailable, -1, targetResourceVersion: 2),
    );
  });
}
