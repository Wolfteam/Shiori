import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_element_file.freezed.dart';
part 'translation_element_file.g.dart';

@freezed
abstract class TranslationElementFile with _$TranslationElementFile {
  factory TranslationElementFile({
    required String key,
    required String name,
    required String effect,
    String? description,
  }) = _TranslationElementFile;

  const TranslationElementFile._();

  factory TranslationElementFile.fromJson(Map<String, dynamic> json) => _$TranslationElementFileFromJson(json);
}
