part of 'backup_restore_bloc.dart';

@freezed
class BackupRestoreEvent with _$BackupRestoreEvent {
  const factory BackupRestoreEvent.init() = _Init;

  const factory BackupRestoreEvent.create() = _Create;

  const factory BackupRestoreEvent.read(String filePath) = _Read;

  const factory BackupRestoreEvent.restore(String filePath) = _Restore;

  const factory BackupRestoreEvent.delete(String filePath) = _Delete;
}
