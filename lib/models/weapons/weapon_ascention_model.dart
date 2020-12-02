import 'package:flutter/widgets.dart';

import '../items/item_ascention_material_model.dart';

class WeaponAscentionModel {
  final int level;
  final List<ItemAscentionMaterialModel> materials;

  WeaponAscentionModel({
    @required this.level,
    @required this.materials,
  });
}
