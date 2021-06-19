class CharacterConstellationModel {
  final int number;
  final String image;
  final String title;
  final String description;
  final String? secondDescription;
  final List<String> descriptions;

  const CharacterConstellationModel({
    required this.number,
    required this.image,
    required this.title,
    required this.description,
    this.secondDescription,
    this.descriptions = const [],
  });
}
