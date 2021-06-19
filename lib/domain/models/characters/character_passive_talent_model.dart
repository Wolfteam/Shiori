class CharacterPassiveTalentModel {
  final int unlockedAt;
  final String image;
  final String title;
  final String description;
  final List<String> descriptions;

  CharacterPassiveTalentModel({
    required this.unlockedAt,
    required this.image,
    required this.title,
    required this.description,
    this.descriptions = const [],
  });
}
