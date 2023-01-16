import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_backup_result_model.freezed.dart';

@freezed
class CreateBackupResultModel with _$CreateBackupResultModel {
  const factory CreateBackupResultModel({
    required String name,
    required String path,
    required bool succeed,
  }) = _CreateBackupResultModel;
}
