import 'package:shiori/domain/models/models.dart';

class CharacterTalentAscensionModel {
  final int level;
  final List<ItemCommonWithQuantityAndName> materials;

  CharacterTalentAscensionModel({
    required this.level,
    required this.materials,
  });
}
