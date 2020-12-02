import 'package:flutter/widgets.dart';

import '../items/item_ascention_material_model.dart';

class CharacterAscentionModel {
  final int rank;
  final int level;
  final List<ItemAscentionMaterialModel> materials;

  CharacterAscentionModel({
    @required this.rank,
    @required this.level,
    @required this.materials,
  });
}
