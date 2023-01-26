import 'package:shiori/domain/models/models.dart';

abstract class BackupRestoreService {
  Future<BackupOperationResultModel> createBackup();

  Future<List<BackupFileItemModel>> readBackups();

  Future<BackupModel?> readBackup(String filePath);

  bool canBackupBeRestored(String bkAppVersion);

  Future<bool> restoreBackup(BackupModel bk);

  Future<bool> deleteBackup(String filePath);
}
