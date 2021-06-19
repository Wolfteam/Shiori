class ElementReactionCardModel {
  final String name;
  final String effect;
  final String? description;
  final List<String> principal;
  final List<String> secondary;

  const ElementReactionCardModel.withImages({
    required this.name,
    required this.effect,
    required this.principal,
    required this.secondary,
  }) : description = null;

  const ElementReactionCardModel.withoutImages({
    required this.name,
    required this.effect,
    required this.description,
  })   : principal = const [],
        secondary = const [];
}
