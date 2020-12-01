import 'package:flutter/widgets.dart';

import 'character_ascention_material_model.dart';

class CharacterAscentionModel {
  final int rank;
  final int level;
  final List<CharacterAscentionMaterialModel> materials;

  CharacterAscentionModel({
    @required this.rank,
    @required this.level,
    @required this.materials,
  });
}
