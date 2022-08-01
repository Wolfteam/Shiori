import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

class CharacterBuildCardModel {
  final bool isRecommended;
  final CharacterRoleType type;
  final CharacterRoleSubType subType;
  final List<CharacterSkillType> skillPriorities;
  final List<WeaponCardModel> weapons;
  final List<CharacterBuildArtifactModel> artifacts;
  final List<StatType> subStatsToFocus;
  final bool isCustomBuild;

  CharacterBuildCardModel({
    required this.isRecommended,
    required this.type,
    required this.subType,
    required this.skillPriorities,
    required this.weapons,
    required this.artifacts,
    required this.subStatsToFocus,
    this.isCustomBuild = false,
  });
}

class CharacterBuildArtifactModel {
  final ArtifactCardModel? one;
  final List<ArtifactCardModel> multiples;
  final List<StatType> stats;

  const CharacterBuildArtifactModel({
    required this.one,
    required this.multiples,
    required this.stats,
  });

  const CharacterBuildArtifactModel.one({
    required this.one,
    required this.stats,
  }) : multiples = const [];

  const CharacterBuildArtifactModel.multiples({
    required this.multiples,
    required this.stats,
  }) : one = null;
}

class CharacterBuildMultipleArtifactModel {
  final int quantity;
  final ArtifactCardModel artifact;
  CharacterBuildMultipleArtifactModel({
    required this.quantity,
    required this.artifact,
  });
}
