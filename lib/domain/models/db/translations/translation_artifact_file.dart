import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_artifact_file.freezed.dart';
part 'translation_artifact_file.g.dart';

@freezed
class TranslationArtifactFile with _$TranslationArtifactFile {
  factory TranslationArtifactFile({
    required String key,
    required String name,
    required List<TranslationArtifactBonusFile> bonus,
  }) = _TranslationArtifactFile;

  const TranslationArtifactFile._();

  factory TranslationArtifactFile.fromJson(Map<String, dynamic> json) => _$TranslationArtifactFileFromJson(json);
}

@freezed
class TranslationArtifactBonusFile with _$TranslationArtifactBonusFile {
  factory TranslationArtifactBonusFile({
    required String key,
    required String bonus,
  }) = _TranslationArtifactBonusFile;

  const TranslationArtifactBonusFile._();

  factory TranslationArtifactBonusFile.fromJson(Map<String, dynamic> json) => _$TranslationArtifactBonusFileFromJson(json);
}
