import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../common.dart';
import '../mocks.mocks.dart';

void main() {
  const allJson = 'all.json';

  group('Get json file types', () {
    test('translation not loaded due to missing language', () {
      final service = getResourceService(MockSettingsService());
      expect(() => service.getJsonFilePath(AppJsonFileType.translations), throwsA(isA<Exception>()));
    });

    test('translation not loaded due to invalid file type', () {
      final service = getResourceService(MockSettingsService());
      final types = AppJsonFileType.values.where((el) => el != AppJsonFileType.translations).toList();
      for (final type in types) {
        expect(() => service.getJsonFilePath(type, language: AppLanguageType.english), throwsA(isA<Exception>()));
      }
    });

    test('all files exist', () {
      final service = getResourceService(MockSettingsService());
      final types = AppJsonFileType.values.toList();
      final paths = <String>[];
      for (final type in types) {
        if (type == AppJsonFileType.translations) {
          for (final lang in AppLanguageType.values) {
            final path = service.getJsonFilePath(type, language: lang);
            paths.add(path);
          }
        } else {
          final path = service.getJsonFilePath(type);
          paths.add(path);
        }
      }
      checkAssets(paths);
    });
  });

  group('Image paths', () {
    test('valid artifact image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getArtifactImagePath('glacier-and-snowfield_4$imageFileExtension');
      checkAsset(path);
    });

    test('valid character image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getCharacterImagePath('keqing$imageFileExtension');
      checkAsset(path);
    });

    test('valid character full image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getCharacterFullImagePath('keqing$imageFileExtension');
      checkAsset(path);
    });

    test('valid furniture image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getFurnitureImagePath('mondstadt-mansion-windward-manor$imageFileExtension');
      checkAsset(path);
    });

    test('valid gadget image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getGadgetImagePath('parametric-transformer$imageFileExtension');
      checkAsset(path);
    });

    test('valid monster image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getMonsterImagePath('electro-specter$imageFileExtension');
      checkAsset(path);
    });

    test('valid skill image path', () {
      final service = getResourceService(MockSettingsService());
      final paths = [
        service.getSkillImagePath('keqing_s1$imageFileExtension'),
        service.getSkillImagePath('keqing_c1$imageFileExtension'),
        service.getSkillImagePath('keqing_p1$imageFileExtension'),
        service.getSkillImagePath(null),
      ];
      checkAssets(paths);
    });

    test('valid weapon image path', () {
      final service = getResourceService(MockSettingsService());
      final paths = [
        service.getWeaponImagePath('predator$imageFileExtension', WeaponType.bow),
        service.getWeaponImagePath('the-widsith$imageFileExtension', WeaponType.catalyst),
        service.getWeaponImagePath('akuoumaru$imageFileExtension', WeaponType.claymore),
        service.getWeaponImagePath('the-catch$imageFileExtension', WeaponType.polearm),
        service.getWeaponImagePath('the-flute$imageFileExtension', WeaponType.sword),
      ];
      checkAssets(paths);
    });

    test('valid material image path', () {
      final service = getResourceService(MockSettingsService());
      final paths = [
        service.getMaterialImagePath('firm-arrowhead$imageFileExtension', MaterialType.common),
        service.getMaterialImagePath('mora$imageFileExtension', MaterialType.currency),
        service.getMaterialImagePath('storm-beads$imageFileExtension', MaterialType.elementalStone),
        service.getMaterialImagePath('wanderers-advice$imageFileExtension', MaterialType.expCharacter),
        service.getMaterialImagePath('fine-enhancement-ore$imageFileExtension', MaterialType.expWeapon),
        service.getMaterialImagePath('ham$imageFileExtension', MaterialType.ingredient),
        service.getMaterialImagePath('agnidus-agate-gemstone$imageFileExtension', MaterialType.jewels),
        service.getMaterialImagePath('amakumo-fruit$imageFileExtension', MaterialType.local),
        service.getMaterialImagePath('crown-of-insight$imageFileExtension', MaterialType.talents),
        service.getMaterialImagePath('heavy-horn$imageFileExtension', MaterialType.weapon),
        service.getMaterialImagePath('narukamis-wisdom$imageFileExtension', MaterialType.weaponPrimary),
      ];
      checkAssets(paths);
    });
  });

  group('Check for updates', () {
    void _checkEmptyUpdateResult(AppResourceUpdateResultType expectedResultType, int expectedResourceVersion, CheckForUpdatesResult result) {
      expect(result.type == expectedResultType, isTrue);
      expect(result.resourceVersion == expectedResourceVersion, isTrue);
      expect(result.jsonFileKeyName, isNull);
      expect(result.keyNames, isEmpty);
    }

    void _checkUpdateResult(
      AppResourceUpdateResultType expectedResultType,
      int expectedResourceVersion,
      CheckForUpdatesResult result,
      ResourceDiffResponseDto? apiResponse,
    ) {
      expect(result.type == expectedResultType, isTrue);
      expect(result.resourceVersion == expectedResourceVersion, isTrue);
      if (apiResponse != null) {
        expect(result.jsonFileKeyName == apiResponse.jsonFileKeyName, isTrue);
        expect(result.keyNames, apiResponse.keyNames);
      } else {
        _checkEmptyUpdateResult(expectedResultType, expectedResourceVersion, result);
      }
    }

    ResourceService _getService({
      String appVersion = '1.0.0',
      int currentResourceVersion = -1,
      bool isInternetAvailable = false,
      ApiResponseDto<ResourceDiffResponseDto?>? apiResult,
    }) {
      final settingsService = MockSettingsService();
      when(settingsService.lastResourcesCheckedDate).thenReturn(null);
      when(settingsService.noResourcesHasBeenDownloaded).thenReturn(true);

      final networkService = MockNetworkService();
      when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(isInternetAvailable));
      final apiService = MockApiService();
      when(apiService.checkForUpdates(appVersion, currentResourceVersion)).thenAnswer((_) => Future.value(apiResult));

      return ResourceServiceImpl(MockLoggingService(), settingsService, networkService, apiService);
    }

    test('invalid app version', () {
      final service = ResourceServiceImpl(MockLoggingService(), MockSettingsService(), MockNetworkService(), MockApiService());
      expect(() => service.checkForUpdates('', -1), throwsA(isA<Exception>()));
      expect(() => service.checkForUpdates('1,0,2', -1), throwsA(isA<Exception>()));
    });

    test('no updates available because not enough time has passed', () async {
      final settingsService = MockSettingsService();
      when(settingsService.lastResourcesCheckedDate).thenReturn(DateTime.now());

      final service = ResourceServiceImpl(MockLoggingService(), settingsService, MockNetworkService(), MockApiService());

      final result = await service.checkForUpdates('1.0.0', -1);
      _checkEmptyUpdateResult(AppResourceUpdateResultType.noUpdatesAvailable, -1, result);
    });

    test('no internet connection on first install', () async {
      final service = _getService();
      final result = await service.checkForUpdates('1.0.0', -1);
      _checkEmptyUpdateResult(AppResourceUpdateResultType.noInternetConnectionForFirstInstall, -1, result);
    });

    test('api returns that there is a new app version', () async {
      final service = _getService(
        isInternetAvailable: true,
        currentResourceVersion: 1,
        apiResult: ApiResponseDto<ResourceDiffResponseDto?>(succeed: true, messageId: '3'),
      );
      final result = await service.checkForUpdates('1.0.0', 1);
      _checkEmptyUpdateResult(AppResourceUpdateResultType.needsLatestAppVersion, 1, result);
    });

    test('api returns that there are no updates available', () async {
      final service = _getService(
        isInternetAvailable: true,
        currentResourceVersion: 1,
        apiResult: ApiResponseDto<ResourceDiffResponseDto?>(succeed: true, messageId: '4'),
      );
      final result = await service.checkForUpdates('1.0.0', 1);
      _checkEmptyUpdateResult(AppResourceUpdateResultType.noUpdatesAvailable, 1, result);
    });

    test('api returns unknown message id', () async {
      final service = _getService(
        isInternetAvailable: true,
        currentResourceVersion: 1,
        apiResult: ApiResponseDto<ResourceDiffResponseDto?>(succeed: true, messageId: 'XXX'),
      );
      final result = await service.checkForUpdates('1.0.0', 1);
      _checkEmptyUpdateResult(AppResourceUpdateResultType.unknownError, 1, result);
    });

    test('api returns that main files must be downloaded', () async {
      final apiResult = ApiResponseDto<ResourceDiffResponseDto?>(
        succeed: true,
        result: ResourceDiffResponseDto(
          currentResourceVersion: 1,
          targetResourceVersion: 2,
          jsonFileKeyName: allJson,
          keyNames: [],
        ),
      );
      final service = _getService(
        isInternetAvailable: true,
        currentResourceVersion: 1,
        apiResult: apiResult,
      );
      final result = await service.checkForUpdates('1.0.0', 1);
      _checkUpdateResult(AppResourceUpdateResultType.updatesAvailable, 2, result, apiResult.result!);
    });

    test('api returns that partial files must be downloaded', () async {
      final apiResult = ApiResponseDto<ResourceDiffResponseDto?>(
        succeed: true,
        result: ResourceDiffResponseDto(currentResourceVersion: 1, targetResourceVersion: 2, keyNames: ['characters/keqing$imageFileExtension']),
      );
      final service = _getService(
        isInternetAvailable: true,
        currentResourceVersion: 1,
        apiResult: apiResult,
      );
      final result = await service.checkForUpdates('1.0.0', 1);
      _checkUpdateResult(AppResourceUpdateResultType.updatesAvailable, 2, result, apiResult.result!);
    });

    test('api returns no files to be downloaded, hence no updates available', () async {
      final apiResult = ApiResponseDto<ResourceDiffResponseDto?>(
        succeed: true,
        result: ResourceDiffResponseDto(currentResourceVersion: 1, targetResourceVersion: 2, keyNames: []),
      );
      final service = _getService(
        isInternetAvailable: true,
        currentResourceVersion: 1,
        apiResult: apiResult,
      );
      final result = await service.checkForUpdates('1.0.0', 1);
      _checkUpdateResult(AppResourceUpdateResultType.noUpdatesAvailable, 1, result, apiResult.result!);
    });

    test('api returns same resource version, hence no updates available', () async {
      final apiResult = ApiResponseDto<ResourceDiffResponseDto?>(
        succeed: true,
        result: ResourceDiffResponseDto(currentResourceVersion: 1, targetResourceVersion: 1, keyNames: []),
      );
      final service = _getService(
        isInternetAvailable: true,
        currentResourceVersion: 1,
        apiResult: apiResult,
      );
      final result = await service.checkForUpdates('1.0.0', 1);
      _checkUpdateResult(AppResourceUpdateResultType.noUpdatesAvailable, 1, result, apiResult.result!);
    });

    test('api returns lower resource version, hence no updates available', () async {
      final apiResult = ApiResponseDto<ResourceDiffResponseDto?>(
        succeed: true,
        result: ResourceDiffResponseDto(currentResourceVersion: 1, targetResourceVersion: 0, keyNames: ['characters/keqing$imageFileExtension']),
      );
      final service = _getService(
        isInternetAvailable: true,
        currentResourceVersion: 1,
        apiResult: apiResult,
      );
      final result = await service.checkForUpdates('1.0.0', 1);
      _checkUpdateResult(AppResourceUpdateResultType.noUpdatesAvailable, 1, result, null);
    });

    test('api returns null result, hence no unknown error', () async {
      final apiResult = ApiResponseDto<ResourceDiffResponseDto?>(succeed: true);
      final service = _getService(
        isInternetAvailable: true,
        currentResourceVersion: 1,
        apiResult: apiResult,
      );
      final result = await service.checkForUpdates('1.0.0', 1);
      _checkUpdateResult(AppResourceUpdateResultType.unknownError, 1, result, null);
    });

    test('last resources checked date is not updated', () async {
      final settingsService = MockSettingsService();
      final now = DateTime.now().subtract(const Duration(days: 7));
      when(settingsService.lastResourcesCheckedDate).thenReturn(now);
      when(settingsService.noResourcesHasBeenDownloaded).thenReturn(false);
      final networkService = MockNetworkService();
      when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));
      final apiService = MockApiService();
      when(apiService.checkForUpdates('1.0.0', -1)).thenAnswer(
        (_) => Future.value(
          ApiResponseDto<ResourceDiffResponseDto?>(succeed: true, messageId: '4'),
        ),
      );

      final service = ResourceServiceImpl(MockLoggingService(), settingsService, networkService, apiService);
      await service.checkForUpdates('1.0.0', -1, updateResourceCheckedDate: false);
      await service.checkForUpdates('1.0.0', -1, updateResourceCheckedDate: false);
      expect(settingsService.lastResourcesCheckedDate == now, isTrue);
    });
  });

  group('Download and apply updates', () {
    test('invalid target version', () {
      final service = ResourceServiceImpl(MockLoggingService(), MockSettingsService(), MockNetworkService(), MockApiService());
      expect(
        () => service.downloadAndApplyUpdates(0, null),
        throwsA(isA<Exception>().having((ex) => ex.toString(), 'message', contains('The provided targetResourceVersion = 0 is not valid'))),
      );
    });

    test('neither json file nor keyNames were provided', () {
      final service = ResourceServiceImpl(
        MockLoggingService(),
        MockSettingsService(),
        MockNetworkService(),
        MockApiService(),
      );
      expect(
        () => service.downloadAndApplyUpdates(1, null),
        throwsA(
          isA<Exception>().having(
            (ex) => ex.toString(),
            'message',
            contains('This platform uses either a jsonKeyName or multiple keyNames files but neither were provided'),
          ),
        ),
      );
    });

    test('target resource version already applied', () {
      final settingsService = MockSettingsService();
      when(settingsService.resourceVersion).thenReturn(2);
      final service = ResourceServiceImpl(MockLoggingService(), settingsService, MockNetworkService(), MockApiService());
      expect(
        () => service.downloadAndApplyUpdates(2, null, keyNames: ['characters/keqing$imageFileExtension']),
        throwsA(isA<Exception>().having((error) => error.toString(), 'message', contains('The provided targetResourceVersion = 2 == 2'))),
      );
    });

    test('target resource version is lower than current', () {
      final settingsService = MockSettingsService();
      when(settingsService.resourceVersion).thenReturn(2);
      final service = ResourceServiceImpl(MockLoggingService(), settingsService, MockNetworkService(), MockApiService());
      expect(
        () => service.downloadAndApplyUpdates(1, null, keyNames: ['characters/keqing$imageFileExtension']),
        throwsA(isA<Exception>().having((error) => error.toString(), 'message', contains('The provided targetResourceVersion = 1 < 2'))),
      );
    });

    test('download main json file, cannot check for updates', () async {
      final settingsService = MockSettingsService();
      when(settingsService.lastResourcesCheckedDate).thenReturn(null);
      when(settingsService.resourceVersion).thenReturn(-1);
      final networkService = MockNetworkService();
      when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(false));

      final service = ResourceServiceImpl(
        MockLoggingService(),
        settingsService,
        networkService,
        MockApiService(),
      );
      final appliedA = await service.downloadAndApplyUpdates(1, allJson);
      final appliedB = await service.downloadAndApplyUpdates(1, allJson, keyNames: ['characters/keqing$imageFileExtension']);

      expect(appliedA, isFalse);
      expect(appliedB, isFalse);
    });

    test('download partial files, cannot check for updates', () async {
      final settingsService = MockSettingsService();
      when(settingsService.lastResourcesCheckedDate).thenReturn(null);
      when(settingsService.resourceVersion).thenReturn(-1);
      final networkService = MockNetworkService();
      when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(false));

      final service = ResourceServiceImpl(
        MockLoggingService(),
        settingsService,
        networkService,
        MockApiService(),
      );
      final applied = await service.downloadAndApplyUpdates(1, null, keyNames: ['characters/keqing$imageFileExtension']);

      expect(applied, isFalse);
    });

    test('download main json file, api throws exception while downloading', () async {
      final tempDir = await Directory.systemTemp.createTemp('shiori_resources_${DateTime.now().millisecondsSinceEpoch}');
      final dummyFile = File(path.join(tempDir.path, 'dummy.txt'));
      await dummyFile.create();
      final settingsService = MockSettingsService();
      when(settingsService.lastResourcesCheckedDate).thenReturn(null);
      when(settingsService.resourceVersion).thenReturn(-1);
      final networkService = MockNetworkService();
      when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));
      final apiService = MockApiService();
      when(apiService.downloadAsset(allJson, path.join(tempDir.path, allJson), null)).thenAnswer((_) => Future.value(false));

      final service = ResourceServiceImpl(
        MockLoggingService(),
        settingsService,
        networkService,
        apiService,
        maxItemsPerBatch: 1,
        maxRetryAttempts: 1,
      );
      service.initForTests(tempDir.path, path.join(tempDir.path, 'assets'));

      final applied = await service.downloadAndApplyUpdates(1, allJson);
      expect(applied, isFalse);
      final dirExists = await tempDir.exists();
      expect(dirExists, isFalse);
    });

    test('download partial files, api throws exception while downloading', () async {
      final tempDir = await Directory.systemTemp.createTemp('shiori_resources_${DateTime.now().millisecondsSinceEpoch}');
      final settingsService = MockSettingsService();
      when(settingsService.lastResourcesCheckedDate).thenReturn(null);
      when(settingsService.resourceVersion).thenReturn(-1);
      final networkService = MockNetworkService();
      when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));
      final apiService = MockApiService();
      const keyNames = [
        'characters/keqing$imageFileExtension',
        'characters/kamisato_ayaka$imageFileExtension',
        'characters/ganyu$imageFileExtension',
      ];

      when(apiService.downloadAsset(keyNames[0], path.join(tempDir.path, keyNames[0]), null)).thenAnswer((_) => Future.value(true));
      when(apiService.downloadAsset(keyNames[1], path.join(tempDir.path, keyNames[1]), null)).thenAnswer((_) => Future.value(true));
      when(apiService.downloadAsset(keyNames[2], path.join(tempDir.path, keyNames[2]), null)).thenAnswer((_) => Future.value(false));

      await File(path.join(path.join(tempDir.path, 'keqing$imageFileExtension'))).create();
      await File(path.join(path.join(tempDir.path, 'kamisato_ayaka$imageFileExtension'))).create();

      final service = ResourceServiceImpl(
        MockLoggingService(),
        settingsService,
        networkService,
        apiService,
        maxItemsPerBatch: 1,
        maxRetryAttempts: 1,
      );
      service.initForTests(tempDir.path, path.join(tempDir.path, 'assets'));

      final applied = await service.downloadAndApplyUpdates(1, allJson, keyNames: keyNames);
      expect(applied, isFalse);
      final dirExists = await tempDir.exists();
      expect(dirExists, isFalse);
    });
  });
}
