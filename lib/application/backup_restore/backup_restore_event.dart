part of 'backup_restore_bloc.dart';

@freezed
class BackupRestoreEvent with _$BackupRestoreEvent {
  const factory BackupRestoreEvent.backup() = _Backup;

  const factory BackupRestoreEvent.restore(String filePath) = _Restore;
}
