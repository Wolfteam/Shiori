import 'package:moor/moor.dart';

import 'base_entity.dart';

class CharacterAscentionItemMaterial extends BaseEntity {
  IntColumn get quantity => integer()();
  IntColumn get ascentionMaterial =>
      integer().nullable().customConstraint('REFERENCES character_ascention_material(id)')();
}
