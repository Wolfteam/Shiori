part of 'backup_restore_bloc.dart';

@freezed
class BackupRestoreState with _$BackupRestoreState {
  const factory BackupRestoreState.loading() = _LoadingState;

  const factory BackupRestoreState.loaded({
    required List<BackupFileItemModel> backups,
    BackupOperationResultModel? createResult,
    BackupOperationResultModel? readResult,
    BackupOperationResultModel? restoreResult,
    BackupOperationResultModel? deleteResult,
  }) = _LoadedState;
}
