import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_weapon_file.freezed.dart';
part 'translation_weapon_file.g.dart';

@freezed
abstract class TranslationWeaponFile with _$TranslationWeaponFile {
  factory TranslationWeaponFile({
    required String key,
    required String name,
    required String description,
    required List<String> refinements,
  }) = _TranslationWeaponFile;

  factory TranslationWeaponFile.fromJson(Map<String, dynamic> json) => _$TranslationWeaponFileFromJson(json);
}
