import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/api_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';

const _tempDirName = 'shiori_temp';
const _tempAssetsDirName = 'shiori_assets';

class ResourceServiceImpl implements ResourceService {
  final LoggingService _loggingService;
  final SettingsService _settingsService;
  final NetworkService _networkService;
  final ApiService _apiService;
  final int maxRetryAttempts;
  final int maxItemsPerBatch;

  late final String _tempPath;
  late final String _assetsPath;

  ResourceServiceImpl(
    this._loggingService,
    this._settingsService,
    this._networkService,
    this._apiService, {
    this.maxRetryAttempts = 5,
    this.maxItemsPerBatch = 5,
  });

  Future<void> init() async {
    final temp = await getTemporaryDirectory();
    final support = await getApplicationSupportDirectory();

    _tempPath = join(temp.path, _tempDirName);
    _assetsPath = join(support.path, _tempAssetsDirName);
    await _deleteDirectoryIfExists(_tempPath);
  }

  @visibleForTesting
  void initForTests(String temPath, String assetsPath) {
    if (temPath.isNullEmptyOrWhitespace) {
      throw Exception('Invalid temp path');
    }

    if (assetsPath.isNullEmptyOrWhitespace) {
      throw Exception('Invalid assets path');
    }

    _tempPath = temPath;
    _assetsPath = assetsPath;
  }

  @override
  String getJsonFilePath(AppJsonFileType type, {AppLanguageType? language}) {
    if (language != null) {
      if (type != AppJsonFileType.translations) {
        throw Exception('The translation type must be set when a language is provided');
      }
      final filename = _getJsonTranslationFilename(language);
      return join(_assetsPath, 'i18n', filename);
    }

    final dbPath = join(_assetsPath, 'db');
    switch (type) {
      case AppJsonFileType.artifacts:
        return join(dbPath, 'artifacts.json');
      case AppJsonFileType.bannerHistory:
        return join(dbPath, 'banners_history.json');
      case AppJsonFileType.characters:
        return join(dbPath, 'characters.json');
      case AppJsonFileType.elements:
        return join(dbPath, 'elements.json');
      case AppJsonFileType.furniture:
        return join(dbPath, 'furniture.json');
      case AppJsonFileType.gadgets:
        return join(dbPath, 'gadgets.json');
      case AppJsonFileType.materials:
        return join(dbPath, 'materials.json');
      case AppJsonFileType.monsters:
        return join(dbPath, 'monsters.json');
      case AppJsonFileType.weapons:
        return join(dbPath, 'weapons.json');
      case AppJsonFileType.translations:
        throw Exception('You must provide a language to retrieve a translation file');
    }
  }

  String _getImagePath(String filename, AppImageFolderType type, {WeaponType? weaponType, MaterialType? materialType}) {
    switch (type) {
      case AppImageFolderType.artifacts:
        return join(_assetsPath, 'artifacts', filename);
      case AppImageFolderType.characters:
        return join(_assetsPath, 'characters', filename);
      case AppImageFolderType.charactersFull:
        return join(_assetsPath, 'characters_full', filename);
      case AppImageFolderType.furniture:
        return join(_assetsPath, 'furniture', filename);
      case AppImageFolderType.gadgets:
        return join(_assetsPath, 'gadgets', filename);
      case AppImageFolderType.items:
        final materialBasePath = join(_assetsPath, 'items');
        switch (materialType) {
          case MaterialType.common:
            return join(materialBasePath, 'common', filename);
          case MaterialType.currency:
            return join(materialBasePath, 'currency', filename);
          case MaterialType.elementalStone:
            return join(materialBasePath, 'elemental', filename);
          case MaterialType.expWeapon:
          case MaterialType.expCharacter:
            return join(materialBasePath, 'experience', filename);
          case MaterialType.ingredient:
            return join(materialBasePath, 'ingredients', filename);
          case MaterialType.jewels:
            return join(materialBasePath, 'jewels', filename);
          case MaterialType.local:
            return join(materialBasePath, 'local', filename);
          case MaterialType.talents:
            return join(materialBasePath, 'talents', filename);
          case MaterialType.weapon:
            return join(materialBasePath, 'weapon', filename);
          case MaterialType.weaponPrimary:
            return join(materialBasePath, 'weapon_primary', filename);
          case MaterialType.others:
            throw Exception('Invalid material type');
          default:
            throw Exception('You must provide a material type');
        }
      case AppImageFolderType.monsters:
        return join(_assetsPath, 'monsters', filename);
      case AppImageFolderType.skills:
        return join(_assetsPath, 'skills', filename);
      case AppImageFolderType.weapons:
        final weaponBasePath = join(_assetsPath, 'weapons');
        switch (weaponType) {
          case WeaponType.sword:
            return join(weaponBasePath, 'swords', filename);
          case WeaponType.claymore:
            return join(weaponBasePath, 'claymores', filename);
          case WeaponType.polearm:
            return join(weaponBasePath, 'polearms', filename);
          case WeaponType.bow:
            return join(weaponBasePath, 'bows', filename);
          case WeaponType.catalyst:
            return join(weaponBasePath, 'catalysts', filename);
          default:
            throw Exception('You must provide a weapon type');
        }
    }
  }

  @override
  String getArtifactImagePath(String filename) => _getImagePath(filename, AppImageFolderType.artifacts);

  @override
  String getCharacterImagePath(String filename) => _getImagePath(filename, AppImageFolderType.characters);

  @override
  String getCharacterFullImagePath(String filename) => _getImagePath(filename, AppImageFolderType.charactersFull);

  @override
  String getFurnitureImagePath(String filename) => _getImagePath(filename, AppImageFolderType.furniture);

  @override
  String getGadgetImagePath(String filename) => _getImagePath(filename, AppImageFolderType.gadgets);

  @override
  String getMonsterImagePath(String filename) => _getImagePath(filename, AppImageFolderType.monsters);

  @override
  String getSkillImagePath(String? filename) {
    if (filename.isNullEmptyOrWhitespace) {
      return Assets.noImageAvailablePath;
    }

    return _getImagePath(filename!, AppImageFolderType.skills);
  }

  @override
  String getWeaponImagePath(String filename, WeaponType type) => _getImagePath(filename, AppImageFolderType.weapons, weaponType: type);

  @override
  String getMaterialImagePath(String filename, MaterialType type) => _getImagePath(filename, AppImageFolderType.items, materialType: type);

  bool _canCheckForUpdates({bool checkDate = true}) {
    _loggingService.info(runtimeType, '_canCheckForUpdates: Checking if we can check for resource updates...');
    final lastResourcesCheckedDate = _settingsService.lastResourcesCheckedDate;
    if (lastResourcesCheckedDate == null) {
      return true;
    }

    if (!checkDate) {
      return true;
    }

    final isAfter = DateTime.now().isAfter(lastResourcesCheckedDate.add(const Duration(hours: 24)));
    if (!isAfter) {
      return false;
    }

    return true;
  }

  @override
  Future<CheckForUpdatesResult> checkForUpdates(
    String currentAppVersion,
    int currentResourcesVersion, {
    bool updateResourceCheckedDate = true,
  }) async {
    if (currentAppVersion.isNullEmptyOrWhitespace) {
      throw Exception('Invalid app version');
    }

    final appVersionRegex = RegExp(r'(\d+\.)(\d+\.)(\d+)');
    if (!appVersionRegex.hasMatch(currentAppVersion)) {
      throw Exception('Invalid app version');
    }

    if (!_canCheckForUpdates()) {
      return CheckForUpdatesResult(type: AppResourceUpdateResultType.noUpdatesAvailable, resourceVersion: currentResourcesVersion);
    }

    final isInternetAvailable = await _networkService.isInternetAvailable();
    final isFirstResourceCheck = _settingsService.noResourcesHasBeenDownloaded;
    if (!isInternetAvailable && isFirstResourceCheck) {
      return CheckForUpdatesResult(type: AppResourceUpdateResultType.noInternetConnectionForFirstInstall, resourceVersion: currentResourcesVersion);
    }

    bool canUpdateResourceCheckedDate = false;

    try {
      _loggingService.info(runtimeType, 'checkForUpdates: Checking if there is a diff for appVersion = $currentAppVersion');
      final apiResponse = await _apiService.checkForUpdates(currentAppVersion, currentResourcesVersion);
      canUpdateResourceCheckedDate = true;
      switch (apiResponse.messageId) {
        case '3':
          return CheckForUpdatesResult(type: AppResourceUpdateResultType.needsLatestAppVersion, resourceVersion: currentResourcesVersion);
        case '4':
          return CheckForUpdatesResult(type: AppResourceUpdateResultType.noUpdatesAvailable, resourceVersion: currentResourcesVersion);
        case null:
          break;
        default: // Unknown error
          _loggingService.error(runtimeType, 'checkForUpdates: Api returned with unknown msg = ${apiResponse.message}');
          return CheckForUpdatesResult(type: AppResourceUpdateResultType.unknownError, resourceVersion: currentResourcesVersion);
      }

      final targetResourceVersion = apiResponse.result!.targetResourceVersion;
      if (currentResourcesVersion == targetResourceVersion) {
        return CheckForUpdatesResult(type: AppResourceUpdateResultType.noUpdatesAvailable, resourceVersion: currentResourcesVersion);
      } else if (currentResourcesVersion > targetResourceVersion) {
        _loggingService.warning(
          runtimeType,
          'checkForUpdates: Server returned a lower resource version. Current = $currentResourcesVersion -- Target = $targetResourceVersion',
        );
        return CheckForUpdatesResult(type: AppResourceUpdateResultType.noUpdatesAvailable, resourceVersion: currentResourcesVersion);
      }

      final mainFileMustBeDownloaded = apiResponse.result!.jsonFileKeyName.isNotNullEmptyOrWhitespace;
      final partialFilesMustBeDownloaded = apiResponse.result!.keyNames.isNotEmpty;

      if (!mainFileMustBeDownloaded && !partialFilesMustBeDownloaded) {
        _loggingService.warning(runtimeType, 'checkForUpdates: We got a case were we do not have nothing to process. Error = ${apiResponse.message}');
        return CheckForUpdatesResult(type: AppResourceUpdateResultType.noUpdatesAvailable, resourceVersion: currentResourcesVersion);
      }

      return CheckForUpdatesResult(
        type: AppResourceUpdateResultType.updatesAvailable,
        resourceVersion: targetResourceVersion,
        jsonFileKeyName: apiResponse.result!.jsonFileKeyName,
        keyNames: apiResponse.result!.keyNames,
      );
    } catch (e, s) {
      _loggingService.error(runtimeType, 'checkForUpdates: Unknown error', e, s);
      return CheckForUpdatesResult(type: AppResourceUpdateResultType.unknownError, resourceVersion: currentResourcesVersion);
    } finally {
      final updateDate = canUpdateResourceCheckedDate && !isFirstResourceCheck && updateResourceCheckedDate;
      if (updateDate) {
        _settingsService.lastResourcesCheckedDate = DateTime.now();
      }
    }
  }

  @override
  Future<bool> downloadAndApplyUpdates(
    int targetResourceVersion,
    String? jsonFileKeyName, {
    List<String> keyNames = const <String>[],
    ProgressChanged? onProgress,
  }) async {
    if (targetResourceVersion <= 0) {
      throw Exception('The provided targetResourceVersion = $targetResourceVersion is not valid');
    }

    if (jsonFileKeyName.isNullEmptyOrWhitespace && keyNames.isEmpty) {
      throw Exception('This platform uses either a jsonKeyName or multiple keyNames files but neither were provided');
    }

    final partialFilesMustBeDownloaded = keyNames.isNotEmpty;
    final mainFilesMustBeDownloaded = !partialFilesMustBeDownloaded && jsonFileKeyName.isNotNullEmptyOrWhitespace;

    if (!mainFilesMustBeDownloaded && !partialFilesMustBeDownloaded) {
      throw Exception('You need to either provide a main or partial files');
    }

    if (_settingsService.resourceVersion == targetResourceVersion) {
      throw Exception('The provided targetResourceVersion = $targetResourceVersion == ${_settingsService.resourceVersion}');
    } else if (_settingsService.resourceVersion > targetResourceVersion) {
      throw Exception('The provided targetResourceVersion = $targetResourceVersion < ${_settingsService.resourceVersion}');
    }

    if (!_canCheckForUpdates(checkDate: false)) {
      return false;
    }

    try {
      _loggingService.info(runtimeType, 'downloadAndApplyUpdates: Creating temp folders...');
      await _deleteDirectoryIfExists(_tempPath);
      await _createDirectoryIfItDoesntExist(_tempPath);

      if (mainFilesMustBeDownloaded) {
        _loggingService.info(runtimeType, 'downloadAndApplyUpdates: Downloading main files...');
        //we need to download the whole file
        final destMainFilePath = join(_tempPath, jsonFileKeyName);
        final downloaded = await _apiService.downloadAsset(jsonFileKeyName!, destMainFilePath, onProgress);

        if (!downloaded) {
          _loggingService.error(runtimeType, 'downloadAndApplyUpdates: Could not download the main file');
          await _deleteDirectoryIfExists(_tempPath);
          return false;
        }

        _loggingService.info(runtimeType, 'downloadAndApplyUpdates: Processing files...');
        final processed = await _processVersionsJsonFile(destMainFilePath, _tempPath, _assetsPath, onProgress);

        if (!processed) {
          _loggingService.error(runtimeType, 'downloadAndApplyUpdates: Could not process the main file');
          return false;
        }
      } else {
        //we need to download a portion
        _loggingService.info(runtimeType, 'downloadAndApplyUpdates: Downloading partial files...');
        final processed = await _processPartialUpdate(_tempPath, _assetsPath, keyNames, onProgress);
        if (!processed) {
          _loggingService.error(runtimeType, 'downloadAndApplyUpdates: Could not process the partial file');
          return false;
        }
      }

      _loggingService.info(runtimeType, 'downloadAndApplyUpdates: Update completed');
      _settingsService.resourceVersion = targetResourceVersion;
      _settingsService.lastResourcesCheckedDate = DateTime.now();
      return true;
    } catch (e, s) {
      _loggingService.error(runtimeType, 'downloadAndApplyUpdates: Unknown error', e, s);
      return false;
    }
  }

  Future<bool> _processVersionsJsonFile(String destMainFilePath, String tempFolder, String assetsFolder, ProgressChanged? onProgress) async {
    _loggingService.info(runtimeType, '_processVersionsJsonFile: Processing main json file...');
    final file = File(destMainFilePath);
    final jsonString = await file.readAsString();
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final version = JsonVersionsFile.fromJson(json);
    await File(destMainFilePath).delete();
    final processed = await _downloadAssets(tempFolder, version.keyNames, onProgress);

    if (processed) {
      _loggingService.info(runtimeType, '_processVersionsJsonFile: Main json file was successfully processed');
      await _afterMainFileWasProcessed(tempFolder, assetsFolder);
    } else {
      _loggingService.error(runtimeType, '_processVersionsJsonFile: Processing of  main json file failed');
    }

    return processed;
  }

  Future<bool> _processPartialUpdate(String tempFolder, String assetsFolder, List<String> keyNames, ProgressChanged? onProgress) async {
    _loggingService.info(runtimeType, '_processPartialUpdate: Downloading partial files...');
    final processed = await _downloadAssets(tempFolder, keyNames, onProgress);
    if (!processed) {
      _loggingService.error(runtimeType, '_processPartialUpdate: Could not process the partial file');
      await _deleteDirectoryIfExists(tempFolder);
      return false;
    }
    await _afterMainFileWasProcessed(tempFolder, assetsFolder, deleteAssetsFolder: false);
    _loggingService.info(runtimeType, '_processPartialUpdate: Partial update was successfully processed');
    return true;
  }

  Future<bool> _downloadAssets(String tempFolder, List<String> keyNames, ProgressChanged? onProgress) async {
    if (keyNames.isEmpty) {
      return true;
    }

    _loggingService.info(runtimeType, '_downloadAssets: Processing ${keyNames.length} keyName(s)...');
    final Map<String, String> destPaths = await _createTempDirectories(tempFolder, keyNames);

    int itemsPerBatch = maxItemsPerBatch;
    int processedItems = 0;
    int retryAttempts = 0;

    final total = keyNames.length;
    final keyNamesCopy = [...keyNames];
    while (keyNamesCopy.isNotEmpty) {
      final taken = keyNamesCopy.take(itemsPerBatch).toList();
      for (int i = 0; i < itemsPerBatch; i++) {
        if (keyNamesCopy.isEmpty) {
          break;
        }
        keyNamesCopy.removeAt(0);
      }

      try {
        if (taken.isNotEmpty) {
          if (retryAttempts > 0) {
            await Future.delayed(const Duration(seconds: 1));
          }
          await Future.wait(taken.map((e) => _downloadAsset(destPaths[e]!, e)).toList(), eagerError: true);
          processedItems += taken.length;
          final progress = processedItems * 100 / total;
          onProgress?.call(progress);
        }
      } catch (e, s) {
        _loggingService.error(runtimeType, '_downloadAssets: One or more keyNames failed... RetryAttempts = $retryAttempts', e, s);
        itemsPerBatch--;
        retryAttempts++;
        if (retryAttempts <= maxRetryAttempts && itemsPerBatch > 0) {
          keyNamesCopy.addAll(taken);
          await Future.delayed(Duration(seconds: retryAttempts + maxRetryAttempts));
          continue;
        }

        final remaining = keyNamesCopy.length;
        _loggingService.error(runtimeType, '_downloadAssets: Reached maxRetryAttempts = $maxRetryAttempts with remaining items = $remaining', e, s);
        await _deleteDirectoryIfExists(tempFolder);
        return false;
      }
    }

    _loggingService.info(runtimeType, '_downloadAssets: ${keyNames.length} keyName(s) were successfully downloaded');
    return true;
  }

  Future<void> _downloadAsset(String destPath, String keyName) async {
    final file = File(destPath);
    if (await file.exists()) {
      await file.delete();
    }
    final downloaded = await _apiService.downloadAsset(keyName, destPath, null);
    if (!downloaded) {
      throw Exception('Download of keyName = $keyName failed');
    }
  }

  Future<void> _afterMainFileWasProcessed(String tempFolder, String assetsFolder, {bool deleteAssetsFolder = true}) async {
    //I delete and create the folder because it may exist and contain old data
    if (deleteAssetsFolder) {
      await _deleteDirectoryIfExists(assetsFolder);
      await _createDirectoryIfItDoesntExist(assetsFolder);
    }
    await _moveFolder(tempFolder, assetsFolder, _tempDirName);
    await _deleteDirectoryIfExists(tempFolder);
  }

  Future<Map<String, String>> _createTempDirectories(String tempFolder, List<String> keyNames) async {
    final destPaths = <String, String>{};
    final allDirs = <String>[];
    for (final keyName in keyNames) {
      final split = keyName.split('/');
      //the last item is the filename
      final partA = split.take(split.length - 1).fold<String>('', (previousValue, element) {
        if (previousValue.isEmpty) {
          return element;
        }
        return join(previousValue, element);
      });
      final dir = join(tempFolder, partA);
      allDirs.add(dir);

      final destPath = join(dir, split.last);
      destPaths.putIfAbsent(keyName, () => destPath);
    }

    final dirs = allDirs.toSet();
    for (final dir in dirs) {
      await _createDirectoryIfItDoesntExist(dir);
    }

    return destPaths;
  }

  Future<void> _createDirectoryIfItDoesntExist(String path) async {
    final dir = Directory(path);
    final dirExists = await dir.exists();
    if (!dirExists) {
      await dir.create(recursive: true);
    }
  }

  Future<void> _deleteDirectoryIfExists(String path) async {
    final dir = Directory(path);
    final dirExists = await dir.exists();
    if (dirExists) {
      await dir.delete(recursive: true);
    }
  }

  String _getNewPathForMove(String to, String fromFolderName, FileSystemEntity entity) {
    final subPath = entity.path.substring(entity.path.indexOf(fromFolderName) + fromFolderName.length + 1);
    return join(to, subPath);
  }

  Future<void> _moveFolder(String from, String to, String fromFolderName) async {
    try {
      // prefer using rename as it is probably faster
      await Directory(from).rename(to);
      return;
    } catch (e) {
      //NO OP
    }

    try {
      // if rename fails, copy the source file and then delete it
      final entities = await Directory(from).list(recursive: true).toList();

      final dirs = entities.whereType<Directory>().toList();
      for (final dir in dirs) {
        final newPath = _getNewPathForMove(to, fromFolderName, dir);
        await _createDirectoryIfItDoesntExist(newPath);
      }

      final files = entities.whereType<File>().toList();
      for (final file in files) {
        final newPath = _getNewPathForMove(to, fromFolderName, file);
        await _moveFile(file.path, newPath);
      }
      return;
    } catch (e) {
      //NO OP
    }

    throw Exception('Could not move from = $from to = $to');
  }

  Future<void> _moveFile(String from, String to) async {
    final file = File(from);
    try {
      // prefer using rename as it is probably faster
      await file.rename(to);
      return;
    } catch (e) {
      //NO OP
    }

    try {
      // if rename fails, copy the source file and then delete it
      await file.copy(to);
      await file.delete();
      return;
    } catch (e) {
      //NO OP
    }

    throw Exception('Could not move from = $from to = $to');
  }

  String _getJsonTranslationFilename(AppLanguageType languageType) {
    switch (languageType) {
      case AppLanguageType.english:
        return 'en.json';
      case AppLanguageType.spanish:
        return 'es.json';
      case AppLanguageType.russian:
        return 'ru.json';
      case AppLanguageType.simplifiedChinese:
        return 'zh_CN.json';
      case AppLanguageType.portuguese:
        return 'pt.json';
      case AppLanguageType.italian:
        return 'it.json';
      case AppLanguageType.japanese:
        return 'ja.json';
      case AppLanguageType.vietnamese:
        return 'vi.json';
      case AppLanguageType.indonesian:
        return 'id.json';
      case AppLanguageType.deutsch:
        return 'de.json';
      case AppLanguageType.french:
        return 'fr.json';
      case AppLanguageType.traditionalChinese:
        return 'zh_TW.json';
      case AppLanguageType.korean:
        return 'ko.json';
      case AppLanguageType.thai:
        return 'th.json';
      default:
        throw Exception('Invalid language = $languageType');
    }
  }
}
