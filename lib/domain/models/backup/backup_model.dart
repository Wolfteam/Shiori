import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'backup_model.freezed.dart';
part 'backup_model.g.dart';

@freezed
class BackupModel with _$BackupModel {
  const factory BackupModel({
    required String appVersion,
    required int resourceVersion,
    required DateTime createdAt,
    required Map<String, String> deviceInfo,
    required List<AppBackupDataType> dataTypes,
    BackupAppSettingsModel? settings,
    List<BackupInventoryModel>? inventory,
    List<BackupCalculatorAscMaterialsSessionModel>? calculatorAscMaterials,
    List<BackupCustomBuildModel>? customBuilds,
    List<BackupTierListModel>? tierList,
    List<BackupGameCodeModel>? gameCodes,
    BackupNotificationsModel? notifications,
  }) = _BackupModel;

  factory BackupModel.fromJson(Map<String, dynamic> json) => _$BackupModelFromJson(json);
}

@freezed
class BackupFileItemModel with _$BackupFileItemModel {
  String get filename => basename(filePath);

  const factory BackupFileItemModel({
    required String appVersion,
    required int resourceVersion,
    required DateTime createdAt,
    required String filePath,
    required List<AppBackupDataType> dataTypes,
  }) = _BackupFileItemModel;

  const BackupFileItemModel._();
}
