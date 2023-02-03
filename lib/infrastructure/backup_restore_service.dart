import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/backup_restore_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:version/version.dart';

const _fileExtension = '.bk';

class BackupRestoreServiceImpl implements BackupRestoreService {
  final LoggingService _loggingService;
  final SettingsService _settingsService;
  final DeviceInfoService _deviceInfoService;
  final DataService _dataService;
  final NotificationService _notificationService;
  final String? _dirPath;

  BackupRestoreServiceImpl(
    this._loggingService,
    this._settingsService,
    this._deviceInfoService,
    this._dataService,
    this._notificationService,
  ) : _dirPath = null;

  @visibleForTesting
  BackupRestoreServiceImpl.forTesting(
    LoggingService loggingService,
    SettingsService settingsService,
    DeviceInfoService deviceInfoService,
    DataService dataService,
    NotificationService notificationService,
    String dirPath,
  )   : _loggingService = loggingService,
        _settingsService = settingsService,
        _deviceInfoService = deviceInfoService,
        _dataService = dataService,
        _notificationService = notificationService,
        _dirPath = dirPath;

  @override
  Future<BackupOperationResultModel> createBackup(List<AppBackupDataType> dataTypes) async {
    if (dataTypes.isEmpty) {
      throw Exception('You must provide at least one bk data type');
    }

    final filePath = await _generateFilePath();
    try {
      _loggingService.info(runtimeType, 'createBackup: Retrieving the data that will be used for bk = $filePath ...');

      final deviceInfo = _deviceInfoService.deviceInfo;
      var bk = BackupModel(
        appVersion: _deviceInfoService.version,
        resourceVersion: _settingsService.resourceVersion,
        createdAt: DateTime.now(),
        deviceInfo: deviceInfo,
        dataTypes: dataTypes,
      );
      for (final type in dataTypes) {
        switch (type) {
          case AppBackupDataType.settings:
            final settings = _settingsService.appSettings;
            bk = bk.copyWith(settings: settings);
            break;
          case AppBackupDataType.inventory:
            final inventory = _dataService.inventory.getDataForBackup();
            bk = bk.copyWith(inventory: inventory);
            break;
          case AppBackupDataType.calculatorAscMaterials:
            final calcAscMat = _dataService.calculator.getDataForBackup();
            bk = bk.copyWith(calculatorAscMaterials: calcAscMat);
            break;
          case AppBackupDataType.tierList:
            final tierList = _dataService.tierList.getDataForBackup();
            bk = bk.copyWith(tierList: tierList);
            break;
          case AppBackupDataType.customBuilds:
            final customBuilds = _dataService.customBuilds.getDataForBackup();
            bk = bk.copyWith(customBuilds: customBuilds);
            break;
          case AppBackupDataType.notifications:
            final notifications = _dataService.notifications.getDataForBackup();
            bk = bk.copyWith(notifications: notifications);
            break;
        }
      }

      _loggingService.info(runtimeType, 'createBackup: Creating json...');
      final jsonMap = bk.toJson();

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      final jsonString = json.encode(jsonMap);

      _loggingService.info(runtimeType, 'createBackup: Saving file...');
      await file.create();
      await file.writeAsString(jsonString);

      _loggingService.info(runtimeType, 'createBackup: Bk = $filePath was successfully created');
      return BackupOperationResultModel(path: filePath, succeed: true, dataTypes: dataTypes);
    } catch (e, s) {
      _loggingService.error(runtimeType, 'createBackup: Error creating bk = $filePath', e, s);
      return BackupOperationResultModel(path: filePath, succeed: false, dataTypes: dataTypes);
    }
  }

  @override
  Future<List<BackupFileItemModel>> readBackups() async {
    final bks = <BackupFileItemModel>[];
    final dirPath = await _getBackupDir();
    final dir = Directory(dirPath);
    final files = await dir.list().toList();
    for (final file in files) {
      final bk = await readBackup(file.path);
      if (bk != null) {
        final flattened = BackupFileItemModel(
          filePath: file.path,
          appVersion: bk.appVersion,
          resourceVersion: bk.resourceVersion,
          createdAt: bk.createdAt,
          dataTypes: bk.dataTypes,
        );
        bks.add(flattened);
      }
    }
    return bks;
  }

  @override
  Future<BackupModel?> readBackup(String filePath) async {
    _loggingService.info(runtimeType, 'readBackup: Trying to read file = $filePath');
    try {
      final jsonMap = await _readBackupAsJson(filePath);
      if (jsonMap != null) {
        return BackupModel.fromJson(jsonMap);
      }
    } catch (e, s) {
      _loggingService.error(runtimeType, 'readBackup: Error reading file = $filePath', e, s);
    }
    return null;
  }

  @override
  bool canBackupBeRestored(String bkAppVersion) {
    try {
      final bkVersion = Version.parse(bkAppVersion);
      final appVersion = Version.parse(_deviceInfoService.version);
      return bkVersion <= appVersion;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> restoreBackup(BackupModel bk, List<AppBackupDataType> dataTypes) async {
    if (dataTypes.isEmpty) {
      throw Exception('You must provide at least one bk data type');
    }

    if (!canBackupBeRestored(bk.appVersion)) {
      return false;
    }

    try {
      _loggingService.info(runtimeType, 'restoreBackup: Restoring from backup...');
      for (final type in dataTypes) {
        if (!bk.dataTypes.contains(type)) {
          continue;
        }
        switch (type) {
          case AppBackupDataType.settings:
            _settingsService.restoreFromBackup(bk.settings!);
            break;
          case AppBackupDataType.inventory:
            await _dataService.inventory.restoreFromBackup(bk.inventory!);
            break;
          case AppBackupDataType.calculatorAscMaterials:
            await _dataService.calculator.restoreFromBackup(bk.calculatorAscMaterials!);
            break;
          case AppBackupDataType.tierList:
            await _dataService.tierList.restoreFromBackup(bk.tierList!);
            break;
          case AppBackupDataType.customBuilds:
            await _dataService.customBuilds.restoreFromBackup(bk.customBuilds!);
            break;
          case AppBackupDataType.notifications:
            _loggingService.info(runtimeType, 'restoreBackup: Cancelling all notifications...');
            await _notificationService.cancelAllNotifications();
            final serverResetTime = bk.settings?.serverResetTime ?? _settingsService.serverResetTime;
            await _dataService.notifications.restoreFromBackup(bk.notifications!, serverResetTime);
            break;
        }
      }
      _loggingService.info(runtimeType, 'restoreBackup: Process completed');
      return true;
    } catch (e, s) {
      _loggingService.error(runtimeType, 'restoreBackup: Error restoring bk', e, s);
      return false;
    }
  }

  @override
  Future<bool> deleteBackup(String filePath) async {
    try {
      _loggingService.info(runtimeType, 'deleteBackup: Deleting file = $filePath');
      final file = File(filePath);
      if (!await file.exists()) {
        return true;
      }

      await file.delete();
      return true;
    } catch (e, s) {
      _loggingService.error(runtimeType, 'deleteBackup: Error deleting file = $filePath', e, s);
      return false;
    }
  }

  @override
  Future<bool> copyImportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final filename = path.basename(filePath);
      final newFilePath = await _generateFilePath(customFilename: filename);
      await file.copy(newFilePath);
      return true;
    } catch (e, s) {
      _loggingService.error(runtimeType, 'copyImportedBackup: Error copying file = $filePath', e, s);
      return false;
    }
  }

  Future<String> _generateFilePath({String? customFilename}) async {
    final filename = customFilename ?? 'shiori_backup_${DateTime.now().millisecondsSinceEpoch}$_fileExtension';
    final dirPath = await _getBackupDir();
    final filePath = path.join(dirPath, filename);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    return filePath;
  }

  Future<String> _getBackupDir() async {
    String dirPath;
    if (_dirPath.isNotNullEmptyOrWhitespace) {
      return _dirPath!;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      final dir = await getApplicationDocumentsDirectory();
      dirPath = dir.path;
    } else {
      final dir = await getExternalStorageDirectory();
      dirPath = dir!.path;
    }

    final dir = Directory(path.join(dirPath, 'backups'));
    if (!await dir.exists()) {
      await dir.create();
    }

    return dir.path;
  }

  Future<Map<String, dynamic>?> _readBackupAsJson(String filePath) async {
    _loggingService.info(runtimeType, '_readBackup: Trying to read file = $filePath');
    final file = File(filePath);
    if (!await file.exists()) {
      _loggingService.warning(runtimeType, '_readBackup: File = $filePath does not exist');
      return null;
    }

    try {
      final jsonString = await file.readAsString();
      final decodedJson = json.decode(jsonString);
      return decodedJson as Map<String, dynamic>;
    } catch (e, s) {
      _loggingService.error(runtimeType, '_readBackup: Error reading file = $filePath', e, s);
      return null;
    }
  }
}
