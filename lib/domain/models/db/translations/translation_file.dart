import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models.dart';

part 'translation_file.freezed.dart';
part 'translation_file.g.dart';

@freezed
class TranslationFile with _$TranslationFile {
  factory TranslationFile({
    required List<TranslationCharacterFile> characters,
    required List<TranslationWeaponFile> weapons,
    required List<TranslationArtifactFile> artifacts,
    required List<TranslationMaterialFile> materials,
    required List<TranslationElementFile> debuffs,
    required List<TranslationElementFile> reactions,
    required List<TranslationElementFile> resonance,
    required List<TranslationMonsterFile> monsters,
  }) = _TranslationFile;

  factory TranslationFile.fromJson(Map<String, dynamic> json) => _$TranslationFileFromJson(json);
}
