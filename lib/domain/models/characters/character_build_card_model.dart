import 'package:genshindb/domain/enums/enums.dart';

import '../models.dart';

class CharacterBuildCardModel {
  final bool isForSupport;
  final List<WeaponCardModel> weapons;
  final List<CharacterBuildArtifactModel> artifacts;
  final List<StatType> subStatsToFocus;

  CharacterBuildCardModel({
    required this.isForSupport,
    required this.weapons,
    required this.artifacts,
    required this.subStatsToFocus,
  });
}

class CharacterBuildArtifactModel {
  final ArtifactCardModel? one;
  final List<CharacterBuildMultipleArtifactModel> multiples;
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
