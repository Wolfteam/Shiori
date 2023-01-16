import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';

part 'backup_model.freezed.dart';
part 'backup_model.g.dart';

@freezed
class BackupModel with _$BackupModel {
  factory BackupModel({
    required String appVersion,
    required int resourceVersion,
    required DateTime createdAt,
    required Map<String, String> deviceInfo,
    required AppSettings settings,
    required List<BackupInventoryModel> inventory,
    required List<CalculatorAscMaterialsSessionModel> calculatorAscMaterials,
    required List<BackupCustomBuildModel> customBuilds,
    required List<BackupTierListModel> tierList,
    required BackupNotificationsModel notifications,
  }) = _BackupModel;

  factory BackupModel.fromJson(Map<String, dynamic> json) => _$BackupModelFromJson(json);
}
