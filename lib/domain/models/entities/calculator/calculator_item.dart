import 'package:hive_ce/hive.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'calculator_item.g.dart';

@HiveType(typeId: 2)
class CalculatorItem extends BaseEntity {
  @HiveField(0)
  final int sessionKey;

  @HiveField(1)
  final String itemKey;

  @HiveField(2)
  int position;

  @HiveField(3)
  final int currentLevel;

  @HiveField(4)
  final int desiredLevel;

  @HiveField(5)
  final int currentAscensionLevel;

  @HiveField(6)
  final int desiredAscensionLevel;

  @HiveField(7)
  final bool isCharacter;

  @HiveField(8)
  final bool isWeapon;

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final bool useMaterialsFromInventory;

  CalculatorItem(
    this.sessionKey,
    this.itemKey,
    this.position,
    this.currentLevel,
    this.desiredLevel,
    this.currentAscensionLevel,
    this.desiredAscensionLevel,
    this.isCharacter,
    this.isWeapon,
    this.isActive,
    this.useMaterialsFromInventory,
  );
}
