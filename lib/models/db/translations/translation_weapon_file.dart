import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_weapon_file.freezed.dart';
part 'translation_weapon_file.g.dart';

@freezed
abstract class TranslationWeaponFile implements _$TranslationWeaponFile {
  factory TranslationWeaponFile({
    @required String key,
    @required String description,
    String refinement,
  }) = _TranslationWeaponFile;

  factory TranslationWeaponFile.fromJson(Map<String, dynamic> json) => _$TranslationWeaponFileFromJson(json);
}
