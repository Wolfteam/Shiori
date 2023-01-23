import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_calculator_asc_materials_model.freezed.dart';
part 'backup_calculator_asc_materials_model.g.dart';

@freezed
class CalculatorAscMaterialsSessionModel with _$CalculatorAscMaterialsSessionModel {
  const factory CalculatorAscMaterialsSessionModel({
    required String name,
    required int position,
    required DateTime createdAt,
    required List<CalculatorAscMaterialsSessionItemModel> items,
  }) = _CalculatorDataModel;

  factory CalculatorAscMaterialsSessionModel.fromJson(Map<String, dynamic> json) => _$CalculatorAscMaterialsSessionModelFromJson(json);
}

@freezed
class CalculatorAscMaterialsSessionItemModel with _$CalculatorAscMaterialsSessionItemModel {
  const factory CalculatorAscMaterialsSessionItemModel({
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
    @Default(<CalculatorAscMaterialsSessionCharSkillItemModel>[]) List<CalculatorAscMaterialsSessionCharSkillItemModel> characterSkills,
  }) = _CalculatorItemDataModel;

  factory CalculatorAscMaterialsSessionItemModel.fromJson(Map<String, dynamic> json) => _$CalculatorAscMaterialsSessionItemModelFromJson(json);
}

@freezed
class CalculatorAscMaterialsSessionCharSkillItemModel with _$CalculatorAscMaterialsSessionCharSkillItemModel {
  const factory CalculatorAscMaterialsSessionCharSkillItemModel({
    required String skillKey,
    required int currentLevel,
    required int desiredLevel,
    required int position,
  }) = _CalculatorCharacterSkillItemDataModel;

  factory CalculatorAscMaterialsSessionCharSkillItemModel.fromJson(Map<String, dynamic> json) =>
      _$CalculatorAscMaterialsSessionCharSkillItemModelFromJson(json);
}
