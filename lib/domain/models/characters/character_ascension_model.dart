import 'package:shiori/domain/models/models.dart';

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
