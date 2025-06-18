import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_calculator_asc_materials_model.freezed.dart';
part 'backup_calculator_asc_materials_model.g.dart';

@freezed
abstract class BackupCalculatorAscMaterialsSessionModel with _$BackupCalculatorAscMaterialsSessionModel {
  const factory BackupCalculatorAscMaterialsSessionModel({
    required String name,
    required int position,
    required List<BackupCalculatorAscMaterialsSessionItemModel> items,
    @Default(false) bool showMaterialUsage,
  }) = _BackupCalculatorAscMaterialsSessionModel;

  factory BackupCalculatorAscMaterialsSessionModel.fromJson(Map<String, dynamic> json) =>
      _$BackupCalculatorAscMaterialsSessionModelFromJson(json);
}

@freezed
abstract class BackupCalculatorAscMaterialsSessionItemModel with _$BackupCalculatorAscMaterialsSessionItemModel {
  const factory BackupCalculatorAscMaterialsSessionItemModel({
    required String itemKey,
    required int position,
    required int currentLevel,
    required int desiredLevel,
    required int currentAscensionLevel,
    required int desiredAscensionLevel,
    required bool isCharacter,
    required bool isWeapon,
    required bool isActive,
    required bool useMaterialsFromInventory,
    @Default(<BackupCalculatorAscMaterialsSessionCharSkillItemModel>[])
    List<BackupCalculatorAscMaterialsSessionCharSkillItemModel> characterSkills,
  }) = _BackupCalculatorAscMaterialsSessionItemModel;

  factory BackupCalculatorAscMaterialsSessionItemModel.fromJson(Map<String, dynamic> json) =>
      _$BackupCalculatorAscMaterialsSessionItemModelFromJson(json);
}

@freezed
abstract class BackupCalculatorAscMaterialsSessionCharSkillItemModel
    with _$BackupCalculatorAscMaterialsSessionCharSkillItemModel {
  const factory BackupCalculatorAscMaterialsSessionCharSkillItemModel({
    required String skillKey,
    required int currentLevel,
    required int desiredLevel,
    required int position,
  }) = _BackupCalculatorAscMaterialsSessionCharSkillItemModel;

  factory BackupCalculatorAscMaterialsSessionCharSkillItemModel.fromJson(Map<String, dynamic> json) =>
      _$BackupCalculatorAscMaterialsSessionCharSkillItemModelFromJson(json);
}
