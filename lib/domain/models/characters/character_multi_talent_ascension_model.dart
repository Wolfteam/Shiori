import 'package:shiori/domain/models/models.dart';

class CharacterMultiTalentAscensionModel {
  final int number;
  final List<CharacterTalentAscensionModel> materials;

  CharacterMultiTalentAscensionModel({
    required this.number,
    required this.materials,
  });
}
