part of 'backup_restore_bloc.dart';

@freezed
class BackupRestoreEvent with _$BackupRestoreEvent {
  const factory BackupRestoreEvent.init() = _Init;

  const factory BackupRestoreEvent.create({
    required List<AppBackupDataType> dataTypes,
  }) = _Create;

  const factory BackupRestoreEvent.read({
    required String filePath,
  }) = _Read;

  const factory BackupRestoreEvent.restore({
    required String filePath,
    required List<AppBackupDataType> dataTypes,
    @Default(false) bool imported,
  }) = _Restore;

  const factory BackupRestoreEvent.delete({
    required String filePath,
  }) = _Delete;
}
