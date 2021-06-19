import '../items/item_ascension_material_model.dart';

class CharacterTalentAscensionModel {
  final int level;
  final List<ItemAscensionMaterialModel> materials;
  CharacterTalentAscensionModel({
    required this.level,
    required this.materials,
  });
}
