import 'package:hive/hive.dart';

part 'custom_build_weapon.g.dart';

@HiveType(typeId: 22)
class CustomBuildWeapon extends HiveObject {
  @HiveField(0)
  final int buildItemKey;

  @HiveField(1)
  String weaponKey;

  @HiveField(2)
  int index;

  @HiveField(3)
  int refinement;

  @HiveField(4, defaultValue: -1)
  int level;

  @HiveField(5, defaultValue: false)
  bool isAnAscension;

  CustomBuildWeapon(
    this.buildItemKey,
    this.weaponKey,
    this.index,
    this.refinement,
    this.level,
    this.isAnAscension,
  );
}
