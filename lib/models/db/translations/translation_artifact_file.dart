import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_artifact_file.freezed.dart';
part 'translation_artifact_file.g.dart';

@freezed
abstract class TranslationArtifactFile implements _$TranslationArtifactFile {
  factory TranslationArtifactFile({
    @required String key,
    @required String name,
    @required List<String> bonus,
  }) = _TranslationArtifactFile;

  const TranslationArtifactFile._();

  factory TranslationArtifactFile.fromJson(Map<String, dynamic> json) => _$TranslationArtifactFileFromJson(json);
}
