import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart';
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
    required AppSettings settings,
    required List<BackupInventoryModel> inventory,
    required List<CalculatorAscMaterialsSessionModel> calculatorAscMaterials,
    required List<BackupCustomBuildModel> customBuilds,
    required List<BackupTierListModel> tierList,
    required BackupNotificationsModel notifications,
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
  }) = _BackupFileItemModel;

  const BackupFileItemModel._();
}
