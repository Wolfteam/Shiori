import 'package:moor/moor.dart';

import '../../common/converters/element_type_converter.dart';
import '../../common/converters/weapon_type_converter.dart';
import 'base_entity.dart';

class Character extends BaseEntity {
  TextColumn get name => text().withLength(min: 0, max: 255)();
  IntColumn get stars => integer()();
  IntColumn get weaponType => integer().map(const WeaponTypeConverter())();
  IntColumn get elementType => integer().map(const ElementTypeConverter())();
  TextColumn get image => text().withLength(min: 0, max: 255)();
  TextColumn get fullImage => text().withLength(min: 0, max: 255)();
  BoolColumn get isComingSoon => boolean()();
  BoolColumn get isNew => boolean()();

  //TODO: CHAR BIRTHDAY?
}
