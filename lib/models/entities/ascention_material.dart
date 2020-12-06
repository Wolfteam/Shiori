import 'package:moor/moor.dart';

import 'base_entity.dart';

class AscentionMaterial extends BaseEntity {
  TextColumn get image => text().withLength(min: 0, max: 255)();
}
