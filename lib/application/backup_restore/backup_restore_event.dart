part of 'backup_restore_bloc.dart';

@freezed
sealed class BackupRestoreEvent with _$BackupRestoreEvent {
  const factory BackupRestoreEvent.init() = BackupRestoreEventInit;

  const factory BackupRestoreEvent.create({
    required List<AppBackupDataType> dataTypes,
  }) = BackupRestoreEventCreate;

  const factory BackupRestoreEvent.read({
    required String filePath,
  }) = BackupRestoreEventRead;

  const factory BackupRestoreEvent.restore({
    required String filePath,
    required List<AppBackupDataType> dataTypes,
    @Default(false) bool imported,
  }) = BackupRestoreEventRestore;

  const factory BackupRestoreEvent.delete({
    required String filePath,
  }) = BackupRestoreEventDelete;
}
