import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

abstract class BackupRestoreService {
  Future<BackupOperationResultModel> createBackup(List<AppBackupDataType> dataTypes);

  Future<List<BackupFileItemModel>> readBackups();

  Future<BackupModel?> readBackup(String filePath);

  bool canBackupBeRestored(String bkAppVersion);

  Future<bool> restoreBackup(BackupModel bk, List<AppBackupDataType> dataTypes);

  Future<bool> deleteBackup(String filePath);
}
