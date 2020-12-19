import 'package:flutter/widgets.dart';

import '../items/item_ascention_material_model.dart';

class CharacterTalentAscentionModel {
  final int level;
  final List<ItemAscentionMaterialModel> materials;
  CharacterTalentAscentionModel({
    @required this.level,
    @required this.materials,
  });
}
