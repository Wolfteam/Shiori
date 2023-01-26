import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
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

  BackupRestoreServiceImpl(this._loggingService, this._settingsService, this._deviceInfoService, this._dataService, this._notificationService);

  @override
  Future<BackupOperationResultModel> createBackup() async {
    final filename = 'shiori_backup_${DateTime.now().millisecondsSinceEpoch}$_fileExtension';
    final dirPath = await _getBackupDir();
    final filePath = path.join(dirPath, filename);
    try {
      _loggingService.info(runtimeType, 'createBackup: Retrieving the data that will be used for bk = $filename ...');
      final settings = _settingsService.appSettings;
      final deviceInfo = _deviceInfoService.deviceInfo;
      final calcAscMat = _dataService.calculator.getDataForBackup();
      final inventory = _dataService.inventory.getDataForBackup();
      final tierList = _dataService.tierList.getDataForBackup();
      final customBuilds = _dataService.customBuilds.getDataForBackup();
      final notifications = _dataService.notifications.getDataForBackup();
      final bk = BackupModel(
        appVersion: _deviceInfoService.version,
        resourceVersion: settings.resourceVersion,
        createdAt: DateTime.now(),
        deviceInfo: deviceInfo,
        settings: settings,
        inventory: inventory,
        calculatorAscMaterials: calcAscMat,
        tierList: tierList,
        customBuilds: customBuilds,
        notifications: notifications,
      );

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
      return BackupOperationResultModel(name: filename, path: filePath, succeed: true);
    } catch (e, s) {
      _loggingService.error(runtimeType, 'createBackup: Error creating bk = $filePath', e, s);
      return BackupOperationResultModel(name: filename, path: filePath, succeed: false);
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
        bks.add(BackupFileItemModel(filePath: file.path, appVersion: bk.appVersion, resourceVersion: bk.resourceVersion, createdAt: bk.createdAt));
      }
    }
    return bks;
  }

//TODO: IF THE FILE IS IN A DIFFERENT FOLDER THAN THE BACKUPS ONE, MAKE A COPY OF IT
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
  Future<bool> restoreBackup(BackupModel bk) async {
    _loggingService.info(runtimeType, 'restoreBackup: Cancelling all notifications...');
    await _notificationService.cancelAllNotifications();

    if (!canBackupBeRestored(bk.appVersion)) {
      return false;
    }

    try {
      _loggingService.info(runtimeType, 'restoreBackup: Restoring from backup...');
      _settingsService.restoreFromBackup(bk.settings);

      await _dataService.tierList.restoreFromBackup(bk.tierList);

      await _dataService.notifications.restoreFromBackup(bk.notifications, bk.settings.serverResetTime);

      await _dataService.customBuilds.restoreFromBackup(bk.customBuilds);

      await _dataService.inventory.restoreFromBackup(bk.inventory);

      await _dataService.calculator.restoreFromBackup(bk.calculatorAscMaterials);

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

  //TODO: PERHAPS CREATE A BK FOLDER ?
  Future<String> _getBackupDir() async {
    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }

    final dir = await getExternalStorageDirectory();
    return dir!.path;
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
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e, s) {
      _loggingService.error(runtimeType, '_readBackup: Error reading file = $filePath', e, s);
      return null;
    }
  }
}
