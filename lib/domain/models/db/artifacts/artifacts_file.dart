import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';

part 'artifacts_file.freezed.dart';
part 'artifacts_file.g.dart';

@freezed
class ArtifactsFile with _$ArtifactsFile {
  factory ArtifactsFile({
    required List<ArtifactFileModel> artifacts,
  }) = _ArtifactsFile;

  const ArtifactsFile._();

  factory ArtifactsFile.fromJson(Map<String, dynamic> json) => _$ArtifactsFileFromJson(json);
}
