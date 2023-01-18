import 'package:shiori/domain/models/models.dart';

abstract class BackupRestoreService {
  Future<CreateBackupResultModel> createBackup();
}
