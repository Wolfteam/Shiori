import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

void main() {
  const String _defaultAppVersion = '1.0.0';
  const int _defaultResourcesVersion = -1;
  const String _jsonFileKeyName = 'all.json';
  const List<String> _keyNames = ['characters/keqing.png'];
  final LanguageModel _language = languagesMap.entries.firstWhere((el) => el.key == AppLanguageType.english).value;

  SplashBloc _getBloc(
    ResourceService resourceService, {
    SettingsService? settingsService,
    String appVersion = _defaultAppVersion,
    int currentResourcesVersion = _defaultResourcesVersion,
  }) {
    final deviceInfoService = MockDeviceInfoService();
    when(deviceInfoService.version).thenReturn(appVersion);

    final settings = settingsService ?? MockSettingsService();
    if (settingsService == null) {
      when(settings.resourceVersion).thenReturn(currentResourcesVersion);
      when(settings.noResourcesHasBeenDownloaded).thenReturn(false);
    }

    final localeService = getLocaleService(AppLanguageType.english);

    return SplashBloc(resourceService, settings, deviceInfoService, MockTelemetryService(), localeService);
  }

  CheckForUpdatesResult _getUpdateResult(
    AppResourceUpdateResultType type, {
    int resourceVersion = _defaultResourcesVersion,
    String? jsonFileName,
    List<String> keyNames = const <String>[],
  }) =>
      CheckForUpdatesResult(resourceVersion: resourceVersion, type: type, jsonFileKeyName: jsonFileName, keyNames: keyNames);

  test('Initial state', () => expect(_getBloc(MockResourceService()).state, const SplashState.loading()));

  group('Init', () {
    blocTest<SplashBloc, SplashState>(
      'unknown error',
      build: () {
        final result = _getUpdateResult(AppResourceUpdateResultType.unknownError);
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        return _getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.unknownError,
          language: _language,
          result: _getUpdateResult(AppResourceUpdateResultType.unknownError),
          noResourcesHasBeenDownloaded: false,
        )
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'unknown error and no resources has been downloaded',
      build: () {
        final result = _getUpdateResult(AppResourceUpdateResultType.unknownError);
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(true);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        return _getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.unknownErrorOnFirstInstall,
          language: _language,
          result: _getUpdateResult(AppResourceUpdateResultType.unknownError),
          noResourcesHasBeenDownloaded: true,
        )
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'no updates available',
      build: () {
        final result = _getUpdateResult(AppResourceUpdateResultType.noUpdatesAvailable);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        return _getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.noUpdatesAvailable,
          language: _language,
          result: _getUpdateResult(AppResourceUpdateResultType.noUpdatesAvailable),
          noResourcesHasBeenDownloaded: false,
        )
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'needs latest app version',
      build: () {
        final result = _getUpdateResult(AppResourceUpdateResultType.needsLatestAppVersion);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        return _getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.needsLatestAppVersion,
          language: _language,
          result: _getUpdateResult(AppResourceUpdateResultType.needsLatestAppVersion),
          noResourcesHasBeenDownloaded: false,
        )
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'no internet connection for first install',
      build: () {
        final result = _getUpdateResult(AppResourceUpdateResultType.noInternetConnectionForFirstInstall);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        return _getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.noInternetConnectionForFirstInstall,
          language: _language,
          result: _getUpdateResult(AppResourceUpdateResultType.noInternetConnectionForFirstInstall),
          noResourcesHasBeenDownloaded: false,
        )
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'updates available',
      build: () {
        final result = _getUpdateResult(
          AppResourceUpdateResultType.updatesAvailable,
          resourceVersion: 2,
          jsonFileName: _jsonFileKeyName,
          keyNames: _keyNames,
        );
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        when(resourceService.downloadAndApplyUpdates(result.resourceVersion, _jsonFileKeyName, keyNames: _keyNames))
            .thenAnswer((_) => Future.value(true));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        return _getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: _language,
          result: _getUpdateResult(
            AppResourceUpdateResultType.updatesAvailable,
            resourceVersion: 2,
            jsonFileName: _jsonFileKeyName,
            keyNames: _keyNames,
          ),
          noResourcesHasBeenDownloaded: false,
        )
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'retry',
      build: () {
        final result = _getUpdateResult(
          AppResourceUpdateResultType.updatesAvailable,
          resourceVersion: 2,
          jsonFileName: _jsonFileKeyName,
          keyNames: _keyNames,
        );
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        when(resourceService.downloadAndApplyUpdates(result.resourceVersion, _jsonFileKeyName, keyNames: _keyNames))
            .thenAnswer((_) => Future.value(true));
        final settingsService = MockSettingsService();
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        return _getBloc(resourceService, settingsService: settingsService);
      },
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: _language,
        result: _getUpdateResult(
          AppResourceUpdateResultType.updatesAvailable,
          resourceVersion: 2,
          jsonFileName: _jsonFileKeyName,
          keyNames: _keyNames,
        ),
        noResourcesHasBeenDownloaded: false,
      ),
      act: (bloc) => bloc.add(const SplashEvent.init(retry: true)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.retrying,
          language: _language,
          noResourcesHasBeenDownloaded: false,
        ),
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: _language,
          result: _getUpdateResult(
            AppResourceUpdateResultType.updatesAvailable,
            resourceVersion: 2,
            jsonFileName: _jsonFileKeyName,
            keyNames: _keyNames,
          ),
          noResourcesHasBeenDownloaded: false,
        ),
      ],
    );
  });

  group('Progress changed', () {
    blocTest<SplashBloc, SplashState>(
      'valid value',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: _language,
        result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
        noResourcesHasBeenDownloaded: false,
      ),
      build: () => _getBloc(MockResourceService()),
      act: (bloc) => bloc
        ..add(const SplashEvent.progressChanged(progress: 10))
        ..add(const SplashEvent.progressChanged(progress: 50))
        ..add(const SplashEvent.progressChanged(progress: 100)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: _language,
          progress: 10,
          result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: false,
        ),
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: _language,
          progress: 50,
          result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: false,
        ),
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: _language,
          progress: 100,
          result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: false,
        ),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'value exceeds 100 percent, thus not emitting new states',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: _language,
        result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
        noResourcesHasBeenDownloaded: false,
      ),
      build: () => _getBloc(MockResourceService()),
      act: (bloc) => bloc
        ..add(const SplashEvent.progressChanged(progress: 100))
        ..add(const SplashEvent.progressChanged(progress: 110)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: _language,
          progress: 100,
          result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: false,
        )
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'value is too small to emit a change',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: _language,
        result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
        noResourcesHasBeenDownloaded: false,
      ),
      build: () => _getBloc(MockResourceService()),
      act: (bloc) => bloc
        ..add(const SplashEvent.progressChanged(progress: 10))
        ..add(const SplashEvent.progressChanged(progress: 10.1)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updatesAvailable,
          language: _language,
          progress: 10,
          result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
          noResourcesHasBeenDownloaded: false,
        )
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'invalid value',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: _language,
        result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable),
        noResourcesHasBeenDownloaded: false,
      ),
      build: () => _getBloc(MockResourceService()),
      act: (bloc) => bloc.add(const SplashEvent.progressChanged(progress: -1)),
      errors: () => [isA<Exception>()],
    );
  });

  group('Update completed', () {
    blocTest<SplashBloc, SplashState>(
      'and was applied',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: _language,
        result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable, resourceVersion: 2),
        noResourcesHasBeenDownloaded: false,
      ),
      build: () => _getBloc(MockResourceService()),
      act: (bloc) => bloc.add(const SplashEvent.updateCompleted(applied: true, resourceVersion: 2)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.updated,
          language: _language,
          progress: 100,
          noResourcesHasBeenDownloaded: false,
        )
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'and was not applied',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: _language,
        result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable, resourceVersion: 2),
        noResourcesHasBeenDownloaded: false,
      ),
      build: () {
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        return _getBloc(MockResourceService(), settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.updateCompleted(applied: false, resourceVersion: 2)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.unknownError,
          language: _language,
          progress: 100,
          noResourcesHasBeenDownloaded: false,
        )
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'and was not applied and no resources has been downloaded',
      seed: () => SplashState.loaded(
        updateResultType: AppResourceUpdateResultType.updatesAvailable,
        language: _language,
        result: _getUpdateResult(AppResourceUpdateResultType.updatesAvailable, resourceVersion: 2),
        noResourcesHasBeenDownloaded: true,
      ),
      build: () {
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(true);
        return _getBloc(MockResourceService(), settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.updateCompleted(applied: false, resourceVersion: 2)),
      expect: () => [
        SplashState.loaded(
          updateResultType: AppResourceUpdateResultType.unknownErrorOnFirstInstall,
          language: _language,
          progress: 100,
          noResourcesHasBeenDownloaded: true,
        ),
      ],
    );
  });
}
