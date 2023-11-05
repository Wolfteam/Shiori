import 'package:hive/hive.dart';
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

  CalculatorSession(this.name, this.position) : createdAt = DateTime.now();
}
