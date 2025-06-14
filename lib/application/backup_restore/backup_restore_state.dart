part of 'backup_restore_bloc.dart';

@freezed
sealed class BackupRestoreState with _$BackupRestoreState {
  const factory BackupRestoreState.loading() = BackupRestoreStateLoadine;

  const factory BackupRestoreState.loaded({
    required List<BackupFileItemModel> backups,
    BackupOperationResultModel? createResult,
    BackupOperationResultModel? readResult,
    BackupOperationResultModel? restoreResult,
    BackupOperationResultModel? deleteResult,
  }) = BackupRestoreStateLoaded;
}
