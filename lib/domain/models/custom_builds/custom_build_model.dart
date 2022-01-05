import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'custom_build_model.freezed.dart';

@freezed
class CustomBuildModel with _$CustomBuildModel {
  const factory CustomBuildModel({
    required int key,
    required String title,
    required CharacterRoleType type,
    required CharacterRoleSubType subType,
    required bool showOnCharacterDetail,
    required CharacterCardModel character,
    required List<WeaponCardModel> weapons,
    required List<CustomBuildArtifactModel> artifacts,
  }) = _CustomBuildModel;
}
