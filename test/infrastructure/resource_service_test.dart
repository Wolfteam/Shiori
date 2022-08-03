import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../common.dart';
import '../mocks.mocks.dart';

void main() {
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
      final path = service.getArtifactImagePath('glacier-and-snowfield_4.png');
      checkAsset(path);
    });

    test('valid character image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getCharacterImagePath('keqing.png');
      checkAsset(path);
    });

    test('valid character full image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getCharacterFullImagePath('keqing.png');
      checkAsset(path);
    });

    test('valid furniture image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getFurnitureImagePath('mondstadt-mansion-windward-manor.png');
      checkAsset(path);
    });

    test('valid gadget image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getGadgetImagePath('parametric-transformer.png');
      checkAsset(path);
    });

    test('valid monster image path', () {
      final service = getResourceService(MockSettingsService());
      final path = service.getMonsterImagePath('electro-specter.png');
      checkAsset(path);
    });

    test('valid skill image path', () {
      final service = getResourceService(MockSettingsService());
      final paths = [
        service.getSkillImagePath('keqing_s1.png'),
        service.getSkillImagePath('keqing_c1.png'),
        service.getSkillImagePath('keqing_p1.png'),
        service.getSkillImagePath(null),
      ];
      checkAssets(paths);
    });

    test('valid weapon image path', () {
      final service = getResourceService(MockSettingsService());
      final paths = [
        service.getWeaponImagePath('predator.png', WeaponType.bow),
        service.getWeaponImagePath('the-widsith.png', WeaponType.catalyst),
        service.getWeaponImagePath('akuoumaru.png', WeaponType.claymore),
        service.getWeaponImagePath('the-catch.png', WeaponType.polearm),
        service.getWeaponImagePath('the-flute.png', WeaponType.sword),
      ];
      checkAssets(paths);
    });

    test('valid material image path', () {
      final service = getResourceService(MockSettingsService());
      final paths = [
        service.getMaterialImagePath('firm-arrowhead.png', MaterialType.common),
        service.getMaterialImagePath('mora.png', MaterialType.currency),
        service.getMaterialImagePath('storm-beads.png', MaterialType.elementalStone),
        service.getMaterialImagePath('wanderers-advice.png', MaterialType.expCharacter),
        service.getMaterialImagePath('fine-enhancement-ore.png', MaterialType.expWeapon),
        service.getMaterialImagePath('ham.png', MaterialType.ingredient),
        service.getMaterialImagePath('agnidus-agate-gemstone.png', MaterialType.jewels),
        service.getMaterialImagePath('amakumo-fruit.png', MaterialType.local),
        service.getMaterialImagePath('crown-of-insight.png', MaterialType.talents),
        service.getMaterialImagePath('heavy-horn.png', MaterialType.weapon),
        service.getMaterialImagePath('narukamis-wisdom.png', MaterialType.weaponPrimary),
      ];
      checkAssets(paths);
    });
  });

  group('Check for updates', () {
    void _checkEmptyUpdateResult(AppResourceUpdateResultType expectedResultType, int expectedResourceVersion, CheckForUpdatesResult result) {
      expect(result.type == expectedResultType, isTrue);
      expect(result.resourceVersion == expectedResourceVersion, isTrue);
      expect(result.jsonFileKeyName, isNull);
      expect(result.zipFileKeyName, isNull);
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
        expect(result.zipFileKeyName == apiResponse.zipFileKeyName, isTrue);
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

    test('unsupported platform', () {
      final service = ResourceServiceImpl(
        MockLoggingService(),
        MockSettingsService(),
        MockNetworkService(),
        MockApiService(),
        usesJsonFile: false,
        usesZipFile: false,
      );
      expect(() => service.checkForUpdates('1.0.0', -1), throwsA(isA<Exception>()));
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
          zipFileKeyName: 'all.zip',
          jsonFileKeyName: 'all.json',
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
        result: ResourceDiffResponseDto(currentResourceVersion: 1, targetResourceVersion: 2, keyNames: ['characters/keqing.png']),
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
  });

  group('Download and apply updates', () {
    test('invalid target version', () {
      final service = ResourceServiceImpl(MockLoggingService(), MockSettingsService(), MockNetworkService(), MockApiService());
      expect(() => service.downloadAndApplyUpdates(0, null, null), throwsA(isA<Exception>()));
    });

    test('neither zip file nor keyNames were provided', () {
      final service = ResourceServiceImpl(
        MockLoggingService(),
        MockSettingsService(),
        MockNetworkService(),
        MockApiService(),
        usesZipFile: true,
        usesJsonFile: false,
      );
      expect(() => service.downloadAndApplyUpdates(1, null, null), throwsA(isA<Exception>()));
    });

    test('neither json file nor keyNames were provided', () {
      final service = ResourceServiceImpl(
        MockLoggingService(),
        MockSettingsService(),
        MockNetworkService(),
        MockApiService(),
        usesZipFile: false,
        usesJsonFile: true,
      );
      expect(() => service.downloadAndApplyUpdates(1, null, null), throwsA(isA<Exception>()));
    });

    test('unsupported platform', () {
      final service = ResourceServiceImpl(
        MockLoggingService(),
        MockSettingsService(),
        MockNetworkService(),
        MockApiService(),
        usesJsonFile: false,
        usesZipFile: false,
      );
      expect(() => service.downloadAndApplyUpdates(1, null, null), throwsA(isA<Exception>()));
    });

    test('target resource version already applied', () {
      final settingsService = MockSettingsService();
      when(settingsService.resourceVersion).thenReturn(2);
      final service = ResourceServiceImpl(MockLoggingService(), settingsService, MockNetworkService(), MockApiService());
      expect(() => service.downloadAndApplyUpdates(2, null, null), throwsA(isA<Exception>()));
    });

    test('download main zip file, cannot check for updates', () async {
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
        usesZipFile: true,
        usesJsonFile: false,
      );
      final appliedA = await service.downloadAndApplyUpdates(1, 'all.zip', null);
      final appliedB = await service.downloadAndApplyUpdates(1, 'all.zip', null, keyNames: ['characters/keqing.png']);

      expect(appliedA, isFalse);
      expect(appliedB, isFalse);
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
        usesZipFile: false,
        usesJsonFile: true,
      );
      final appliedA = await service.downloadAndApplyUpdates(1, null, 'all.json');
      final appliedB = await service.downloadAndApplyUpdates(1, null, 'all.json', keyNames: ['characters/keqing.png']);

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
        usesZipFile: false,
        usesJsonFile: true,
      );
      final applied = await service.downloadAndApplyUpdates(1, null, null, keyNames: ['characters/keqing.png']);

      expect(applied, isFalse);
    });
    //todo: missing cases
  });
}
