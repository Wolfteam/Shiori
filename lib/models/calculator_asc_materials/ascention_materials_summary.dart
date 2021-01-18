import 'package:flutter/foundation.dart';

import '../../common/enums/material_type.dart';
import '../models.dart';

class AscentionMaterialsSummary {
  final MaterialType type;
  final List<ItemAscentionMaterialModel> materials;

  const AscentionMaterialsSummary({
    @required this.type,
    @required this.materials,
  });
}
