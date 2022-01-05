import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'custom_build_artifact_model.freezed.dart';

@freezed
class CustomBuildArtifactModel with _$CustomBuildArtifactModel {
  const factory CustomBuildArtifactModel({
    required String key,
    required ArtifactType type,
    required StatType statType,
    required String image,
    required int rarity,
  }) = _CustomBuildArtifactModel;
}
