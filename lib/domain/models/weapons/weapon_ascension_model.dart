import 'package:shiori/domain/models/models.dart';

class WeaponAscensionModel {
  final int level;
  final List<ItemAscensionMaterialModel> materials;

  WeaponAscensionModel({
    required this.level,
    required this.materials,
  });
}
