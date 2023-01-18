import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/backup_restore_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/settings_service.dart';

class BackupRestoreServiceImpl implements BackupRestoreService {
  final LoggingService _loggingService;
  final SettingsService _settingsService;
  final DeviceInfoService _deviceInfoService;
  final DataService _dataService;

  BackupRestoreServiceImpl(this._loggingService, this._settingsService, this._deviceInfoService, this._dataService);

  @override
  Future<CreateBackupResultModel> createBackup() async {
    //TODO: CHANGE THE FILENAME TO .bk
    final filename = 'shiori_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final dirPath = await _getBackupDir();
    final filePath = path.join(dirPath, filename);
    try {
      _loggingService.info(runtimeType, 'Retrieving the data that will be used for bk = $filename ...');
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

      _loggingService.info(runtimeType, 'Creating json ...');
      final jsonMap = bk.toJson();

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      final jsonString = json.encode(jsonMap);

      _loggingService.info(runtimeType, 'Creating file ...');
      await file.create();
      await file.writeAsString(jsonString);

      _loggingService.info(runtimeType, 'Bk = $filename was successfully created');
      return CreateBackupResultModel(name: filename, path: filePath, succeed: true);
    } catch (e, s) {
      _loggingService.error(runtimeType, 'Error creating bk = $filename', e, s);
      return CreateBackupResultModel(name: filename, path: filePath, succeed: false);
    }
  }

  Future<void> restoreBackup(String filePath) async {
    //TODO: CHECK FILE
    //TODO: RETURN RESULT
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
}
