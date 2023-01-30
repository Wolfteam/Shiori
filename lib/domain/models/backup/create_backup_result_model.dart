import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'create_backup_result_model.freezed.dart';

@freezed
class BackupOperationResultModel with _$BackupOperationResultModel {
  String get filename => basename(path);

  const factory BackupOperationResultModel({
    required String path,
    required bool succeed,
    required List<AppBackupDataType> dataTypes,
  }) = _BackupOperationResultModel;

  const BackupOperationResultModel._();
}
