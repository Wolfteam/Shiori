import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_backup_result_model.freezed.dart';

@freezed
class BackupOperationResultModel with _$BackupOperationResultModel {
  const factory BackupOperationResultModel({
    required String name,
    required String path,
    required bool succeed,
  }) = _BackupOperationResultModel;
}
