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
  const String _zipFileKeyName = 'all.zip';
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
    }

    final localeService = getLocaleService(AppLanguageType.english);

    return SplashBloc(resourceService, settings, deviceInfoService, MockTelemetryService(), localeService);
  }

  test('Initial state', () => expect(_getBloc(MockResourceService()).state, const SplashState.loading()));

  group('Init', () {
    blocTest<SplashBloc, SplashState>(
      'unknown error',
      build: () {
        const result = CheckForUpdatesResult(
          resourceVersion: _defaultResourcesVersion,
          type: AppResourceUpdateResultType.unknownError,
        );
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        return _getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [SplashState.loaded(updateResultType: AppResourceUpdateResultType.unknownError, language: _language)],
    );

    blocTest<SplashBloc, SplashState>(
      'unknown error and no resources has been downloaded',
      build: () {
        const result = CheckForUpdatesResult(
          resourceVersion: _defaultResourcesVersion,
          type: AppResourceUpdateResultType.unknownError,
        );
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(true);
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        return _getBloc(resourceService, settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [SplashState.loaded(updateResultType: AppResourceUpdateResultType.unknownErrorOnFirstInstall, language: _language)],
    );

    blocTest<SplashBloc, SplashState>(
      'no updates available',
      build: () {
        const result = CheckForUpdatesResult(
          resourceVersion: _defaultResourcesVersion,
          type: AppResourceUpdateResultType.noUpdatesAvailable,
        );
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        return _getBloc(resourceService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [SplashState.loaded(updateResultType: AppResourceUpdateResultType.noUpdatesAvailable, language: _language)],
    );

    blocTest<SplashBloc, SplashState>(
      'needs latest app version',
      build: () {
        const result = CheckForUpdatesResult(
          resourceVersion: _defaultResourcesVersion,
          type: AppResourceUpdateResultType.needsLatestAppVersion,
        );
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        return _getBloc(resourceService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [SplashState.loaded(updateResultType: AppResourceUpdateResultType.needsLatestAppVersion, language: _language)],
    );

    blocTest<SplashBloc, SplashState>(
      'no internet connection for first install',
      build: () {
        const result = CheckForUpdatesResult(
          resourceVersion: _defaultResourcesVersion,
          type: AppResourceUpdateResultType.noInternetConnectionForFirstInstall,
        );
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        return _getBloc(resourceService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [SplashState.loaded(updateResultType: AppResourceUpdateResultType.noInternetConnectionForFirstInstall, language: _language)],
    );

    blocTest<SplashBloc, SplashState>(
      'updates available',
      build: () {
        const result = CheckForUpdatesResult(
          resourceVersion: 2,
          type: AppResourceUpdateResultType.updatesAvailable,
          zipFileKeyName: _zipFileKeyName,
          jsonFileKeyName: _jsonFileKeyName,
          keyNames: _keyNames,
        );
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        when(resourceService.downloadAndApplyUpdates(result.resourceVersion, _zipFileKeyName, _jsonFileKeyName, keyNames: _keyNames))
            .thenAnswer((_) => Future.value(true));
        return _getBloc(resourceService);
      },
      act: (bloc) => bloc.add(const SplashEvent.init()),
      expect: () => [SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language)],
    );

    blocTest<SplashBloc, SplashState>(
      'retry',
      build: () {
        const result = CheckForUpdatesResult(
          resourceVersion: 2,
          type: AppResourceUpdateResultType.updatesAvailable,
          zipFileKeyName: _zipFileKeyName,
          jsonFileKeyName: _jsonFileKeyName,
          keyNames: _keyNames,
        );
        final resourceService = MockResourceService();
        when(resourceService.checkForUpdates(_defaultAppVersion, _defaultResourcesVersion)).thenAnswer((_) => Future.value(result));
        when(resourceService.downloadAndApplyUpdates(result.resourceVersion, _zipFileKeyName, _jsonFileKeyName, keyNames: _keyNames))
            .thenAnswer((_) => Future.value(true));
        return _getBloc(resourceService);
      },
      seed: () => SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language),
      act: (bloc) => bloc.add(const SplashEvent.init(retry: true)),
      expect: () => [
        SplashState.loaded(updateResultType: AppResourceUpdateResultType.retrying, language: _language),
        SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language),
      ],
    );
  });

  group('Progress changed', () {
    blocTest<SplashBloc, SplashState>(
      'valid value',
      seed: () => SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language),
      build: () => _getBloc(MockResourceService()),
      act: (bloc) => bloc
        ..add(const SplashEvent.progressChanged(progress: 10))
        ..add(const SplashEvent.progressChanged(progress: 50))
        ..add(const SplashEvent.progressChanged(progress: 100)),
      expect: () => [
        SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language, progress: 10),
        SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language, progress: 50),
        SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language, progress: 100),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'value exceeds 100 percent, thus not emitting new states',
      seed: () => SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language),
      build: () => _getBloc(MockResourceService()),
      act: (bloc) => bloc
        ..add(const SplashEvent.progressChanged(progress: 100))
        ..add(const SplashEvent.progressChanged(progress: 110)),
      expect: () => [SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language, progress: 100)],
    );

    blocTest<SplashBloc, SplashState>(
      'value is too small to emit a change',
      seed: () => SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language),
      build: () => _getBloc(MockResourceService()),
      act: (bloc) => bloc
        ..add(const SplashEvent.progressChanged(progress: 10))
        ..add(const SplashEvent.progressChanged(progress: 10.1)),
      expect: () => [SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language, progress: 10)],
    );

    blocTest<SplashBloc, SplashState>(
      'invalid value',
      seed: () => SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language),
      build: () => _getBloc(MockResourceService()),
      act: (bloc) => bloc.add(const SplashEvent.progressChanged(progress: -1)),
      errors: () => [isA<Exception>()],
    );
  });

  group('Update completed', () {
    blocTest<SplashBloc, SplashState>(
      'and was applied',
      seed: () => SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language),
      build: () => _getBloc(MockResourceService()),
      act: (bloc) => bloc.add(const SplashEvent.updateCompleted(applied: true, resourceVersion: 2)),
      expect: () => [SplashState.loaded(updateResultType: AppResourceUpdateResultType.updated, language: _language, progress: 100)],
    );

    blocTest<SplashBloc, SplashState>(
      'and was not applied',
      seed: () => SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language),
      build: () {
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
        return _getBloc(MockResourceService(), settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.updateCompleted(applied: false, resourceVersion: 2)),
      expect: () => [SplashState.loaded(updateResultType: AppResourceUpdateResultType.unknownError, language: _language, progress: 100)],
    );

    blocTest<SplashBloc, SplashState>(
      'and was not applied and no resources has been downloaded',
      seed: () => SplashState.loaded(updateResultType: AppResourceUpdateResultType.updatesAvailable, language: _language),
      build: () {
        final settingsService = MockSettingsService();
        when(settingsService.resourceVersion).thenReturn(_defaultResourcesVersion);
        when(settingsService.noResourcesHasBeenDownloaded).thenReturn(true);
        return _getBloc(MockResourceService(), settingsService: settingsService);
      },
      act: (bloc) => bloc.add(const SplashEvent.updateCompleted(applied: false, resourceVersion: 2)),
      expect: () => [
        SplashState.loaded(updateResultType: AppResourceUpdateResultType.unknownErrorOnFirstInstall, language: _language, progress: 100),
      ],
    );
  });
}
