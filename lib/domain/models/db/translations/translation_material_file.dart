import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_material_file.freezed.dart';
part 'translation_material_file.g.dart';

@freezed
class TranslationMaterialFile with _$TranslationMaterialFile {
  factory TranslationMaterialFile({
    required String key,
    required String name,
    required String description,
    String? bossName,
  }) = _TranslationMaterialFile;

  factory TranslationMaterialFile.fromJson(Map<String, dynamic> json) => _$TranslationMaterialFileFromJson(json);
}
