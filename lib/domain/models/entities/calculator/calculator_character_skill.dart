import 'package:hive/hive.dart';

part 'calculator_character_skill.g.dart';

@HiveType(typeId: 3)
class CalculatorCharacterSkill extends HiveObject {
  @HiveField(0)
  final int calculatorItemKey;

  @HiveField(1)
  final String skillKey;

  @HiveField(2)
  final int currentLevel;

  @HiveField(3)
  final int desiredLevel;

  @HiveField(4)
  final int position;

  CalculatorCharacterSkill(this.calculatorItemKey, this.skillKey, this.currentLevel, this.desiredLevel, this.position);
}
