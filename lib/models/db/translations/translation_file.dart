import 'package:freezed_annotation/freezed_annotation.dart';

import 'translation_character_file.dart';
import 'translation_weapon_file.dart';

part 'translation_file.freezed.dart';
part 'translation_file.g.dart';

@freezed
abstract class TranslationFile implements _$TranslationFile {
  factory TranslationFile({
    @required List<TranslationCharacterFile> characters,
    @required List<TranslationWeaponFile> weapons,
  }) = _TranslationFile;

  factory TranslationFile.fromJson(Map<String, dynamic> json) => _$TranslationFileFromJson(json);
}
