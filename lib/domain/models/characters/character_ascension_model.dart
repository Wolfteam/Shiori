import '../items/item_ascension_material_model.dart';

class CharacterAscensionModel {
  final int rank;
  final int level;
  final List<ItemAscensionMaterialModel> materials;

  CharacterAscensionModel({
    required this.rank,
    required this.level,
    required this.materials,
  });
}
