import 'package:shiori/domain/models/models.dart';

abstract class BackupRestoreService {
  Future<CreateBackupResultModel> createBackup();

  Future<BackupModel?> readBackup(String filePath);

  bool canBackupBeRestored(String bkAppVersion);

  Future<bool> restoreBackup(BackupModel bk);
}
