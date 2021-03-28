import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_monster_file.freezed.dart';
part 'translation_monster_file.g.dart';

@freezed
abstract class TranslationMonsterFile implements _$TranslationMonsterFile {
  factory TranslationMonsterFile({
    @required String key,
    @required String name,
  }) = _TranslationMonsterFile;

  const TranslationMonsterFile._();

  factory TranslationMonsterFile.fromJson(Map<String, dynamic> json) => _$TranslationMonsterFileFromJson(json);
}
