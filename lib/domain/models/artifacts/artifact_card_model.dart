class ArtifactCardModel {
  final String key;
  final String name;
  final String image;
  final int rarity;
  final List<ArtifactCardBonusModel> bonus;

  const ArtifactCardModel({
    required this.key,
    required this.name,
    required this.image,
    required this.rarity,
    required this.bonus,
  });
}

class ArtifactCardBonusModel {
  final int pieces;
  final String bonus;

  const ArtifactCardBonusModel({
    required this.pieces,
    required this.bonus,
  });
}
