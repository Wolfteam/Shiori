import 'package:freezed_annotation/freezed_annotation.dart';

part 'artifact_file_model.freezed.dart';
part 'artifact_file_model.g.dart';

@freezed
abstract class ArtifactFileModel with _$ArtifactFileModel {
  factory ArtifactFileModel({
    required String key,
    required String image,
    required int minRarity,
    required int maxRarity,
  }) = _ArtifactFileModel;

  ArtifactFileModel._();

  factory ArtifactFileModel.fromJson(Map<String, dynamic> json) => _$ArtifactFileModelFromJson(json);
}
