import '../items/item_ascension_material_model.dart';

class WeaponAscensionModel {
  final int level;
  final List<ItemAscensionMaterialModel> materials;

  WeaponAscensionModel({
    required this.level,
    required this.materials,
  });
}
