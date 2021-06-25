import '../../enums/character_skill_ability_type.dart';
import '../../enums/character_skill_type.dart';

class CharacterSkillCardModel {
  final String image;
  final String title;
  final CharacterSkillType type;
  final String? description;
  final List<CharacterSkillAbilityModel> abilities;

  CharacterSkillCardModel({
    required this.image,
    required this.title,
    required this.type,
    this.description = '',
    required this.abilities,
  });
}

class CharacterSkillAbilityModel {
  final String? name;
  final CharacterSkillAbilityType? type;
  final String? description;
  final String? secondDescription;
  final List<String> descriptions;

  bool get hasCommonTranslation => type != null;

  const CharacterSkillAbilityModel({
    this.name,
    this.type,
    this.description,
    this.secondDescription,
    required this.descriptions,
  });
}
