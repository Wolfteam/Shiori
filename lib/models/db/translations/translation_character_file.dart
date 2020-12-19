import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../common/assets.dart';

part 'translation_character_file.freezed.dart';
part 'translation_character_file.g.dart';

@freezed
abstract class TranslationCharacterFile implements _$TranslationCharacterFile {
  factory TranslationCharacterFile({
    @required String key,
    @required String description,
    @required String role,
    @required List<TranslationCharacterSkillFile> skills,
    @required List<TranslationCharacterPassive> passives,
    @required List<TranslationCharacterConstellation> constellations,
  }) = _TranslationCharacterFile;

  factory TranslationCharacterFile.fromJson(Map<String, dynamic> json) => _$TranslationCharacterFileFromJson(json);
}

@freezed
abstract class TranslationCharacterSkillFile implements _$TranslationCharacterSkillFile {
  @late
  String get fullImagePath => Assets.getSkillPath(image);

  factory TranslationCharacterSkillFile({
    @required String image,
    @required String title,
    @required String subTitle,
    String description,
    @required List<TranslationCharacterAbility> abilities,
  }) = _TranslationCharacterSkillFile;

  factory TranslationCharacterSkillFile.fromJson(Map<String, dynamic> json) => _$TranslationCharacterSkillFileFromJson(json);
}

@freezed
abstract class TranslationCharacterAbility implements _$TranslationCharacterAbility {
  factory TranslationCharacterAbility({
    @required String name,
    String description,
    String secondDescription,
    @required List<String> descriptions,
  }) = _TranslationCharacterAbility;

  factory TranslationCharacterAbility.fromJson(Map<String, dynamic> json) => _$TranslationCharacterAbilityFromJson(json);
}

@freezed
abstract class TranslationCharacterPassive implements _$TranslationCharacterPassive {
  @late
  String get fullImagePath => Assets.getSkillPath(image);

  factory TranslationCharacterPassive({
    @required String image,
    @required String title,
    @required int unlockedAt,
    @required String description,
    @required List<String> descriptions,
  }) = _TranslationCharacterPassive;

  factory TranslationCharacterPassive.fromJson(Map<String, dynamic> json) => _$TranslationCharacterPassiveFromJson(json);
}

@freezed
abstract class TranslationCharacterConstellation implements _$TranslationCharacterConstellation {
  @late
  String get fullImagePath => Assets.getSkillPath(image);

  factory TranslationCharacterConstellation({
    @required int number,
    @required String image,
    @required String title,
    @required String description,
    String secondDescription,
    @required List<String> descriptions,
  }) = _TranslationCharacterConstellation;

  factory TranslationCharacterConstellation.fromJson(Map<String, dynamic> json) => _$TranslationCharacterConstellationFromJson(json);
}
