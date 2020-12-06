import 'package:moor/moor.dart';

import 'base_entity.dart';

class CharacterAscentionMaterial extends BaseEntity {
  IntColumn get level => integer()();
}
