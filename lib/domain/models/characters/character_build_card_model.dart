import 'package:flutter/foundation.dart';

import '../models.dart';

class CharacterBuildCardModel {
  final bool isForSupport;
  final List<WeaponCardModel> weapons;
  final List<CharacterBuildArtifactModel> artifacts;
  CharacterBuildCardModel({
    @required this.isForSupport,
    @required this.weapons,
    @required this.artifacts,
  });
}

class CharacterBuildArtifactModel {
  final ArtifactCardModel one;
  final List<CharacterBuildMultipleArtifactModel> multiples;

  const CharacterBuildArtifactModel({
    @required this.one,
    @required this.multiples,
  });

  const CharacterBuildArtifactModel.one({
    @required this.one,
  }) : multiples = const [];

  const CharacterBuildArtifactModel.multiples({
    @required this.multiples,
  }) : one = null;
}

class CharacterBuildMultipleArtifactModel {
  final int quantity;
  final ArtifactCardModel artifact;
  CharacterBuildMultipleArtifactModel({
    @required this.quantity,
    @required this.artifact,
  });
}
