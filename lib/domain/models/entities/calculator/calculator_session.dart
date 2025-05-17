import 'package:hive_ce/hive.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'calculator_session.g.dart';

@HiveType(typeId: 1)
class CalculatorSession extends BaseEntity {
  @HiveField(0)
  String name;

  @HiveField(1)
  int position;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  bool? showMaterialUsage;

  CalculatorSession(this.name, this.position, this.showMaterialUsage) : createdAt = DateTime.now();
}
