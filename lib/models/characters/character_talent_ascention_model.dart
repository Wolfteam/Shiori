import 'package:flutter/widgets.dart';
import 'character_ascention_material_model.dart';

class CharacterTalentAscentionModel {
  final int level;
  final List<CharacterAscentionMaterialModel> materials;
  CharacterTalentAscentionModel({
    @required this.level,
    @required this.materials,
  });
}
