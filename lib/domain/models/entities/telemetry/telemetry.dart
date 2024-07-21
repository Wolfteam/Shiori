import 'package:hive/hive.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'telemetry.g.dart';

@HiveType(typeId: 25)
class Telemetry extends BaseEntity {
  @HiveField(0)
  final DateTime createdAt;

  @HiveField(1)
  final String message;

  Telemetry(this.createdAt, this.message);
}
