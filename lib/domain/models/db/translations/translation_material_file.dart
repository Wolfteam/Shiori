import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_material_file.freezed.dart';
part 'translation_material_file.g.dart';

@freezed
abstract class TranslationMaterialFile implements _$TranslationMaterialFile {
  factory TranslationMaterialFile({
    @required String key,
    @required String name,
    String bossName,
  }) = _TranslationMaterialFile;

  factory TranslationMaterialFile.fromJson(Map<String, dynamic> json) => _$TranslationMaterialFileFromJson(json);
}
