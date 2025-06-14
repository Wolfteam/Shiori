import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_game_code_model.freezed.dart';
part 'backup_game_code_model.g.dart';

@freezed
abstract class BackupGameCodeModel with _$BackupGameCodeModel {
  const factory BackupGameCodeModel({
    required String code,
    DateTime? usedOn,
    DateTime? discoveredOn,
    DateTime? expiredOn,
    required bool isExpired,
    int? region,
    @Default(<BackupGameCodeRewardModel>[]) List<BackupGameCodeRewardModel> rewards,
  }) = _BackupGameCodeModel;

  factory BackupGameCodeModel.fromJson(Map<String, dynamic> json) => _$BackupGameCodeModelFromJson(json);
}

@freezed
abstract class BackupGameCodeRewardModel with _$BackupGameCodeRewardModel {
  const factory BackupGameCodeRewardModel({
    required String itemKey,
    required int quantity,
  }) = _BackupGameCodeRewardModel;

  factory BackupGameCodeRewardModel.fromJson(Map<String, dynamic> json) => _$BackupGameCodeRewardModelFromJson(json);
}
