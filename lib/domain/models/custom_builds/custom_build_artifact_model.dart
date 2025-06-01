import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'custom_build_artifact_model.freezed.dart';

@freezed
abstract class CustomBuildArtifactModel with _$CustomBuildArtifactModel {
  const factory CustomBuildArtifactModel({
    required String key,
    required ArtifactType type,
    required String name,
    required StatType statType,
    required String image,
    required int rarity,
    required List<StatType> subStats,
  }) = _CustomBuildArtifactModel;
}
