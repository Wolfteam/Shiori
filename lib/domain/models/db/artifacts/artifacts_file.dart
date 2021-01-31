import 'package:freezed_annotation/freezed_annotation.dart';

import 'artifact_file_model.dart';

part 'artifacts_file.freezed.dart';
part 'artifacts_file.g.dart';

@freezed
abstract class ArtifactsFile implements _$ArtifactsFile {
  factory ArtifactsFile({
    @required List<ArtifactFileModel> artifacts,
  }) = _ArtifactsFile;

  const ArtifactsFile._();

  factory ArtifactsFile.fromJson(Map<String, dynamic> json) => _$ArtifactsFileFromJson(json);
}
