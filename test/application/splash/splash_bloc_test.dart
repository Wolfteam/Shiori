import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/env.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  const String defaultAppVersion = '1.0.0';
  const int defaultResourcesVersion = -1;
  const String jsonFileKeyName = 'all.json';
  const List<String> keyNames = ['characters/keqing.png'];
  final LanguageModel language = languagesMap.entries.firstWhere((el) => el.key == AppLanguageType.english).value;

  SplashBloc getBloc(
    ResourceService resourceService, {
    SettingsService? settingsService,
    String appVersion = defaultAppVersion,
    int currentResourcesVersion = defaultResourcesVersion,
  }) {
    final deviceInfoService = MockDeviceInfoService();
    when(deviceInfoService.version).thenReturn(appVersion);

    final settings = settingsService ?? MockSettingsService();
    if (settingsService == null) {
      when(settings.resourceVersion).thenReturn(currentResourcesVersion);
      when(settings.noResourcesHasBeenDownloaded).thenReturn(false);
      when(settings.checkForUpdatesOnStartup).thenReturn(true);
    }

    final localeService = getLocaleService(AppLanguageType.english);

    return SplashBloc(resourceService, settings, deviceInfoService, MockTelemetryService(), localeService);
  }

  CheckForUpdatesResult getUpdateResult(
    AppResourceUpdateResultType type, {
    int resourceVersion = defaultResourcesVersion,
    String? jsonFileName,
    List<String> keyNames = const <String>[],
  }) {
    return CheckForUpdatesResult(
      resourceVersion: resourceVersion,
      type: type,
      jsonFileKeyName: jsonFileName,
      keyNames: keyNames,
      downloadTotalSize: 100,
    );
  }

  test('Initial state', () => expect(getBloc(MockResourceService()).state, const SplashState.loading()));

  group('Init', () {
    blocTest<SplashBloc, SplashState>(
      'unknown error',
      build: () {
        final result = getUpdateResult(AppResourceUpdateResultType.unknownError);
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.checkForUpdatesOnStartup).thenReturn(true);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(defaultAppVersion, defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        return getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.unknownError,
          language: language,
          result: getUpdateResult(AppResourceUpdateResultType.unknownError),
          noResourcesHasBeenDownloaded: false,
          isLoading: false,
          isUpdating: false,
          updateFailed: true,
          canSkipUpdate: true,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'unknown error and no resources has been downloaded',
      build: () {
        final result = getUpdateResult(AppResourceUpdateResultType.unknownError);
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(true);
        when(settingsService.checkForUpdatesOnStartup).thenReturn(true);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(defaultAppVersion, defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        return getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.unknownErrorOnFirstInstall,
          language: language,
          result: getUpdateResult(AppResourceUpdateResultType.unknownError),
          noResourcesHasBeenDownloaded: true,
          isLoading: false,
          isUpdating: false,
          updateFailed: true,
          canSkipUpdate: false,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'no updates available',
      build: () {
        final result = getUpdateResult(AppResourceUpdateResultType.noUpdatesAvailable);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(defaultAppVersion, defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.checkForUpdatesOnStartup).thenReturn(true);
        return getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.noUpdatesAvailable,
          language: language,
          result: getUpdateResult(AppResourceUpdateResultType.noUpdatesAvailable),
          noResourcesHasBeenDownloaded: false,
          isLoading: true,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: true,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'needs latest app version',
      build: () {
        final result = getUpdateResult(AppResourceUpdateResultType.needsLatestAppVersion);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(defaultAppVersion, defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.checkForUpdatesOnStartup).thenReturn(true);
        return getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.needsLatestAppVersion,
          language: language,
          result: getUpdateResult(AppResourceUpdateResultType.needsLatestAppVersion),
          noResourcesHasBeenDownloaded: false,
          isLoading: false,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: true,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'needs latest app version on first install',
      build: () {
        final result = getUpdateResult(AppResourceUpdateResultType.needsLatestAppVersion);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(defaultAppVersion, defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(true);
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.checkForUpdatesOnStartup).thenReturn(true);
        return getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.needsLatestAppVersion,
          language: language,
          result: getUpdateResult(AppResourceUpdateResultType.needsLatestAppVersion),
          noResourcesHasBeenDownloaded: true,
          isLoading: false,
          isUpdating: false,
          updateFailed: true,
          canSkipUpdate: false,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: true,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'no internet connection for first install',
      build: () {
        final result = getUpdateResult(AppResourceUpdateResultType.noInternetConnectionForFirstInstall);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(defaultAppVersion, defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(true);
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.checkForUpdatesOnStartup).thenReturn(true);
        return getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.noInternetConnectionForFirstInstall,
          language: language,
          result: getUpdateResult(AppResourceUpdateResultType.noInternetConnectionForFirstInstall),
          noResourcesHasBeenDownloaded: true,
          isLoading: false,
          isUpdating: false,
          updateFailed: true,
          canSkipUpdate: false,
          noInternetConnectionOnFirstInstall: true,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'updates available',
      build: () {
        final result = getUpdateResult(
          AppResourceUpdateResultType.updatesAvailable,
          resourceVersion: 2,
          jsonFileName: jsonFileKeyName,
          keyNames: keyNames,
        );
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(defaultAppVersion, defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        when(resourceService.downloadAndApplyUpdates(result.resourceVersion, jsonFileKeyName, keyNames: keyNames))
            .thenAnswer((_) => Future.value(true));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.checkForUpdatesOnStartup).thenReturn(true);
        return getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: language,
          result: getUpdateResult(
            AppResourceUpdateResultType.updatesAvailable,
            resourceVersion: 2,
            jsonFileName: jsonFileKeyName,
            keyNames: keyNames,
          ),
          noResourcesHasBeenDownloaded: false,
          isLoading: false,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: true,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'retry',
      build: () {
        final result = getUpdateResult(
          AppResourceUpdateResultType.updatesAvailable,
          resourceVersion: 2,
          jsonFileName: jsonFileKeyName,
          keyNames: keyNames,
        );
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(defaultAppVersion, defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        when(resourceService.downloadAndApplyUpdates(result.resourceVersion, jsonFileKeyName, keyNames: keyNames))
            .thenAnswer((_) => Future.value(true));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.checkForUpdatesOnStartup).thenReturn(true);
        return getBloc(resourceService, settingsService: settingsService);
      },
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: language,
        result: getUpdateResult(
          AppResourceUpdateResultType.updatesAvailable,
          resourceVersion: 2,
          jsonFileName: jsonFileKeyName,
          keyNames: keyNames,
        ),
        noResourcesHasBeenDownloaded: false,
        isLoading: false,
        isUpdating: false,
        updateFailed: false,
        canSkipUpdate: true,
        noInternetConnectionOnFirstInstall: false,
        needsLatestAppVersionOnFirstInstall: false,
      ),
      act: (bloc) => bloc.add(const SplashEvent.init(retry: true)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.retrying,
          language: language,
          noResourcesHasBeenDownloaded: false,
          isLoading: true,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: true,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: language,
          result: getUpdateResult(
            AppResourceUpdateResultType.updatesAvailable,
            resourceVersion: 2,
            jsonFileName: jsonFileKeyName,
            keyNames: keyNames,
          ),
          noResourcesHasBeenDownloaded: false,
          isLoading: false,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: true,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'resources have been downloaded and the setting to check for updates is disabled and the '
      'current resource version is greater than the min thus update check is skipped',
      build: () {
        final resourceService = MockResourceService();
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.resourceVersion).thenReturn(Env.minResourceVersion);
        when(settingsService.checkForUpdatesOnStartup).thenReturn(false);
        return getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init(restarted: true)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.noUpdatesAvailable,
          language: language,
          noResourcesHasBeenDownloaded: false,
          isLoading: true,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: true,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'no resources have been downloaded and the setting to check for updates is enabled thus updates are available',
      build: () {
        final result = getUpdateResult(AppResourceUpdateResultType.updatesAvailable);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(defaultAppVersion, defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(true);
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.checkForUpdatesOnStartup).thenReturn(true);
        return getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init(restarted: true)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: language,
          result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: true,
          isLoading: false,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: false,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );
  });

  group('Progress changed', () {
    blocTest<SplashBloc, SplashState>(
      'valid value',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: language,
        result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
        noResourcesHasBeenDownloaded: false,
        isLoading: false,
        isUpdating: false,
        updateFailed: false,
        canSkipUpdate: false,
        noInternetConnectionOnFirstInstall: false,
        needsLatestAppVersionOnFirstInstall: false,
      ),
      build: () => getBloc(MockResourceService()),
      act: (bloc) => bloc
        ..add(const SplashEvent.progressChanged(progress: 10, downloadedBytes: 10))
        ..add(const SplashEvent.progressChanged(progress: 50, downloadedBytes: 50))
        ..add(const SplashEvent.progressChanged(progress: 100, downloadedBytes: 100)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: language,
          progress: 10,
          downloadedBytes: 10,
          result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: false,
          isLoading: false,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: false,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: language,
          progress: 50,
          downloadedBytes: 50,
          result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: false,
          isLoading: false,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: false,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: language,
          progress: 100,
          downloadedBytes: 100,
          result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: false,
          isLoading: false,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: false,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'value exceeds 100 percent, thus not emitting new states',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: language,
        result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
        noResourcesHasBeenDownloaded: false,
        isLoading: false,
        isUpdating: false,
        updateFailed: false,
        canSkipUpdate: false,
        noInternetConnectionOnFirstInstall: false,
        needsLatestAppVersionOnFirstInstall: false,
      ),
      build: () => getBloc(MockResourceService()),
      act: (bloc) => bloc
        ..add(const SplashEvent.progressChanged(progress: 100, downloadedBytes: 100))
        ..add(const SplashEvent.progressChanged(progress: 110, downloadedBytes: 110)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: language,
          progress: 100,
          downloadedBytes: 100,
          result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: false,
          isLoading: false,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: false,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'value is too small to emit a change',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: language,
        result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
        noResourcesHasBeenDownloaded: false,
        isLoading: false,
        isUpdating: false,
        updateFailed: false,
        canSkipUpdate: false,
        noInternetConnectionOnFirstInstall: false,
        needsLatestAppVersionOnFirstInstall: false,
      ),
      build: () => getBloc(MockResourceService()),
      act: (bloc) => bloc
        ..add(const SplashEvent.progressChanged(progress: 10, downloadedBytes: 10))
        ..add(const SplashEvent.progressChanged(progress: 10.1, downloadedBytes: 10)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: language,
          progress: 10,
          downloadedBytes: 10,
          result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: false,
          isLoading: false,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: false,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'invalid value',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: language,
        result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
        noResourcesHasBeenDownloaded: false,
        isLoading: false,
        isUpdating: false,
        updateFailed: false,
        canSkipUpdate: false,
        noInternetConnectionOnFirstInstall: false,
        needsLatestAppVersionOnFirstInstall: false,
      ),
      build: () => getBloc(MockResourceService()),
      act: (bloc) => bloc.add(const SplashEvent.progressChanged(progress: -1, downloadedBytes: 0)),
      errors: () => [isA<Exception>()],
    );
  });

  group('Update completed', () {
    blocTest<SplashBloc, SplashState>(
      'and was applied',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: language,
        result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable, resourceVersion: 2),
        noResourcesHasBeenDownloaded: false,
        isLoading: false,
        isUpdating: false,
        updateFailed: false,
        canSkipUpdate: false,
        noInternetConnectionOnFirstInstall: false,
        needsLatestAppVersionOnFirstInstall: false,
      ),
      build: () => getBloc(MockResourceService()),
      act: (bloc) => bloc.add(const SplashEvent.updateCompleted(applied: true, resourceVersion: 2)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updated,
          language: language,
          progress: 100,
          noResourcesHasBeenDownloaded: false,
          isLoading: true,
          isUpdating: false,
          updateFailed: false,
          canSkipUpdate: true,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'and was not applied',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: language,
        result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable, resourceVersion: 2),
        noResourcesHasBeenDownloaded: false,
        isLoading: false,
        isUpdating: false,
        updateFailed: false,
        canSkipUpdate: false,
        noInternetConnectionOnFirstInstall: false,
        needsLatestAppVersionOnFirstInstall: false,
      ),
      build: () {
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        return getBloc(MockResourceService(), settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.updateCompleted(applied: false, resourceVersion: 2)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.unknownError,
          language: language,
          progress: 100,
          noResourcesHasBeenDownloaded: false,
          isLoading: false,
          isUpdating: false,
          updateFailed: true,
          canSkipUpdate: true,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'and was not applied and no resources has been downloaded',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: language,
        result: getUpdateResult(AppResourceUpdateResultType.updatesAvailable, resourceVersion: 2),
        noResourcesHasBeenDownloaded: true,
        isLoading: false,
        isUpdating: false,
        updateFailed: false,
        canSkipUpdate: false,
        noInternetConnectionOnFirstInstall: false,
        needsLatestAppVersionOnFirstInstall: false,
      ),
      build: () {
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(true);
        return getBloc(MockResourceService(), settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.updateCompleted(applied: false, resourceVersion: 2)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.unknownErrorOnFirstInstall,
          language: language,
          progress: 100,
          noResourcesHasBeenDownloaded: true,
          isLoading: false,
          isUpdating: false,
          updateFailed: true,
          canSkipUpdate: false,
          noInternetConnectionOnFirstInstall: false,
          needsLatestAppVersionOnFirstInstall: false,
        ),
      ],
    );
  });
}
