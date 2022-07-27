import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/dtos.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/secrets.dart';

class ResourceServiceImpl implements ResourceService {
  final LoggingService _loggingService;
  final SettingsService _settingsService;
  final NetworkService _networkService;

  final bool _usesZipFile = Platform.isAndroid || Platform.isIOS;
  final bool _usesJsonFile = Platform.isWindows;

  ResourceServiceImpl(this._loggingService, this._settingsService, this._networkService);

  @override
  Future<bool> canCheckForUpdates() async {
    _loggingService.info(runtimeType, 'Checking if we can check for resource updates...');
    final lastResourcesCheckedDate = _settingsService.lastResourcesCheckedDate;
    if (lastResourcesCheckedDate == null) {
      return true;
    }

    final isAfter = DateTime.now().isAfter(lastResourcesCheckedDate.add(const Duration(hours: 8)));
    if (!isAfter) {
      return false;
    }

    final bool isInternetAvailable = await _networkService.isInternetAvailable();
    return isInternetAvailable;
  }

  @override
  Future<CheckForUpdatesResult> checkForUpdates(String currentAppVersion, int currentResourcesVersion) async {
    if (currentAppVersion.isNullEmptyOrWhitespace) {
      throw Exception('Invalid app version');
    }

    if (!await canCheckForUpdates()) {
      return CheckForUpdatesResult(result: AppResourceUpdateResultType.noUpdatesAvailable, resourceVersion: currentResourcesVersion);
    }

    if (!_usesZipFile && !_usesJsonFile) {
      throw Exception('Unsupported platform');
    }
    try {
      String url = '${Secrets.apiBaseUrl}?AppVersion=$currentAppVersion';
      if (currentResourcesVersion > 0) {
        url += '&CurrentResourceVersion=$currentResourcesVersion';
      }

      final response = await http.Client().get(Uri.parse(url));
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponseDto.fromJson(
        json,
        (data) => data == null ? null : ResourceDiffResponseDto.fromJson(data as Map<String, dynamic>),
      );

      switch (apiResponse.messageId) {
        case '3':
          return CheckForUpdatesResult(result: AppResourceUpdateResultType.needsLatestAppVersion, resourceVersion: currentResourcesVersion);
        case '4':
          return CheckForUpdatesResult(result: AppResourceUpdateResultType.noUpdatesAvailable, resourceVersion: currentResourcesVersion);
        case null:
          break;
        default: // Unknown error
          _loggingService.error(runtimeType, 'checkForUpdates: Api returned with unknown msg = ${apiResponse.message}');
          return CheckForUpdatesResult(result: AppResourceUpdateResultType.unknownError, resourceVersion: currentResourcesVersion);
      }

      if (currentResourcesVersion == apiResponse.result!.targetResourceVersion) {
        return CheckForUpdatesResult(result: AppResourceUpdateResultType.noUpdatesAvailable, resourceVersion: currentResourcesVersion);
      }

      final mainFilesMustBeDownloaded =
          apiResponse.result!.jsonFileKeyName.isNotNullEmptyOrWhitespace || apiResponse.result!.zipFileKeyName.isNotNullEmptyOrWhitespace;

      final partialFilesMustBeDownloaded = apiResponse.result!.keyNames.isNotEmpty;

      if (!mainFilesMustBeDownloaded && !partialFilesMustBeDownloaded) {
        _loggingService.warning(runtimeType, 'checkForUpdates: We got a case were we do not have nothing to process. Error = ${apiResponse.message}');
        return CheckForUpdatesResult(result: AppResourceUpdateResultType.noUpdatesAvailable, resourceVersion: currentResourcesVersion);
      }

      return CheckForUpdatesResult(
        result: AppResourceUpdateResultType.updatesAvailable,
        resourceVersion: apiResponse.result!.targetResourceVersion,
        zipFileKeyName: apiResponse.result!.zipFileKeyName,
        jsonFileKeyName: apiResponse.result!.jsonFileKeyName,
        keyNames: apiResponse.result!.keyNames,
      );
    } catch (e, s) {
      _loggingService.error(runtimeType, 'checkForUpdates: Unknown error', e, s);
      return CheckForUpdatesResult(result: AppResourceUpdateResultType.unknownError, resourceVersion: currentResourcesVersion);
    }
  }

  @override
  Future<bool> downloadAndApplyUpdates(
    int targetResourceVersion,
    String? zipFileKeyName,
    String? jsonFileKeyName, {
    List<String> keyNames = const <String>[],
  }) async {
    if (targetResourceVersion <= 0) {
      throw Exception('The provided targetResourceVersion = $targetResourceVersion is not valid');
    }

    if (!_usesZipFile && !_usesJsonFile) {
      throw Exception('Unsupported platform');
    }

    if (_usesZipFile && zipFileKeyName.isNullEmptyOrWhitespace && keyNames.isEmpty) {
      throw Exception('This platform uses either a zipKeyName or multiple keyNames files but neither were provided');
    }

    if (_usesJsonFile && jsonFileKeyName.isNullEmptyOrWhitespace && keyNames.isEmpty) {
      throw Exception('This platform uses either a jsonKeyName or multiple keyNames files but neither were provided');
    }

    final mainFilesMustBeDownloaded = jsonFileKeyName.isNotNullEmptyOrWhitespace || zipFileKeyName.isNotNullEmptyOrWhitespace;
    final partialFilesMustBeDownloaded = keyNames.isNotEmpty;

    if (!mainFilesMustBeDownloaded && !partialFilesMustBeDownloaded) {
      throw Exception('You need to either provide a main or partial files');
    }

    if (_settingsService.resourceVersion == targetResourceVersion) {
      throw Exception('The provided targetResourceVersion = $targetResourceVersion == ${_settingsService.resourceVersion}');
    }

    if (!await canCheckForUpdates()) {
      return false;
    }

    try {
      _loggingService.info(runtimeType, 'downloadAndApplyUpdates: Creating temp folders...');

      final dir = (await getApplicationDocumentsDirectory()).path;
      final tempFolder = '$dir/Temp';
      final assetsFolder = '$dir/Assets';
      await _deleteDirectoryIfExists(tempFolder);
      await _createDirectoryIfItDoesntExist(tempFolder);

      if (mainFilesMustBeDownloaded) {
        _loggingService.info(runtimeType, 'downloadAndApplyUpdates: Downloading main files...');
        //we need to download the whole file
        final destMainFilePath = '$tempFolder/${_usesZipFile ? zipFileKeyName! : jsonFileKeyName!}';
        final downloaded =
            _usesZipFile ? await _downloadFile(zipFileKeyName!, destMainFilePath) : await _downloadFile(jsonFileKeyName!, destMainFilePath);

        if (!downloaded) {
          _loggingService.error(runtimeType, 'downloadAndApplyUpdates: Could not download the main file');
          return false;
        }

        _loggingService.info(runtimeType, 'downloadAndApplyUpdates: Processing files...');
        final processed = _usesZipFile
            ? await _processZipFile(destMainFilePath, tempFolder, assetsFolder)
            : await _processVersionsJsonFile(destMainFilePath, tempFolder, assetsFolder);

        if (!processed) {
          _loggingService.error(runtimeType, 'downloadAndApplyUpdates: Could not process the main file');
          return false;
        }
      } else {
        //we need to download a portion
        _loggingService.info(runtimeType, 'downloadAndApplyUpdates: Downloading partial files...');
        final processed = await _processKeyNames(tempFolder, assetsFolder, keyNames);
        if (!processed) {
          _loggingService.error(runtimeType, 'downloadAndApplyUpdates: Could not process the partial file');
          return false;
        }
      }

      _loggingService.info(runtimeType, 'downloadAndApplyUpdates: Update completed');
      _settingsService.lastResourcesCheckedDate = DateTime.now();
      _settingsService.resourceVersion = targetResourceVersion;
      return true;
    } catch (e, s) {
      _loggingService.error(runtimeType, 'downloadAndApplyUpdates: Unknown error', e, s);
      return false;
    }
  }

  Future<bool> _processZipFile(String destMainFilePath, String tempFolder, String assetsFolder) async {
    _loggingService.info(runtimeType, '_processZipFile: Processing main zip file...');
    final extracted = await _extractZip(destMainFilePath, tempFolder);
    await File(destMainFilePath).delete();
    if (!extracted) {
      _loggingService.error(runtimeType, '_processZipFile: Processing of main zip file failed');
      await _deleteDirectoryIfExists(tempFolder);
      return false;
    }
    await _deleteDirectoryIfExists(assetsFolder);
    await _moveFile(File(tempFolder), assetsFolder);
    _loggingService.info(runtimeType, '_processZipFile: Main zip file was successfully processed');
    return true;
  }

  Future<bool> _processVersionsJsonFile(String destMainFilePath, String tempFolder, String assetsFolder) async {
    _loggingService.info(runtimeType, '_processVersionsJsonFile: Processing main json file...');
    final file = File(destMainFilePath);
    final jsonString = await file.readAsString();
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final version = JsonVersionsFile.fromJson(json);
    await File(destMainFilePath).delete();
    final processed = await _processKeyNames(tempFolder, assetsFolder, version.keyNames);

    if (processed) {
      _loggingService.info(runtimeType, '_processVersionsJsonFile: Main json file was successfully processed');
    } else {
      _loggingService.error(runtimeType, '_processVersionsJsonFile: Processing of  main json file failed');
    }

    return processed;
  }

  Future<bool> _processKeyNames(String tempFolder, String assetsFolder, List<String> keyNames) async {
    if (keyNames.isEmpty) {
      return true;
    }

    _loggingService.info(runtimeType, '_processKeyNames: Processing ${keyNames.length} keyName(s)...');
    bool somethingFailed = false;
    for (final keyName in keyNames) {
      final split = keyName.split('/');
      //the last item is the filename
      final dir = '$tempFolder/${split.take(split.length - 1).join('/')}';
      await _createDirectoryIfItDoesntExist(dir);

      final destPath = '$dir/${split.last}';
      somethingFailed = await _downloadFile(keyName, destPath);

      if (somethingFailed) {
        break;
      }
    }

    if (somethingFailed) {
      await _deleteDirectoryIfExists(tempFolder);
      return false;
    }

    await _deleteDirectoryIfExists(assetsFolder);
    await _moveFile(File(tempFolder), assetsFolder);

    _loggingService.info(runtimeType, '_processKeyNames: ${keyNames.length} keyName(s) were successfully processed');
    return true;
  }

  Future<bool> _downloadFile(String keyName, String destPath) async {
    try {
      _loggingService.info(runtimeType, '_downloadFile: Downloading file = $keyName...');
      final dio = Dio();
      final url = '${Secrets.assetsBaseUrl}/$keyName';

      await dio.downloadUri(
        Uri.parse(url),
        destPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total * 100;
            print('${progress.toStringAsFixed(0)}%');
          }
        },
      );
      _loggingService.info(runtimeType, '_downloadFile: File = $keyName was successfully downloaded');
      return true;
    } catch (e, s) {
      _loggingService.error(runtimeType, '_downloadFile: Unknown error', e, s);
      return false;
    }
  }

  Future<bool> _extractZip(String zipFilePath, String destPath) async {
    _loggingService.info(runtimeType, '_extractZip: Extracting zip file...');
    final zipFile = File(zipFilePath);
    final destinationDir = Directory(destPath);
    try {
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: destinationDir,
        onExtracting: (zipEntry, progress) {
          print('progress: ${progress.toStringAsFixed(1)}%');
          print('name: ${zipEntry.name}');
          print('isDirectory: ${zipEntry.isDirectory}');
          return ZipFileOperation.includeItem;
        },
      );
      _loggingService.info(runtimeType, '_extractZip: Extracting completed');
      return true;
    } catch (e, s) {
      _loggingService.error(runtimeType, '_extractZip: Unknown error', e, s);
      return false;
    }
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

  Future<File> _moveFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }
}
