import 'package:hive/hive.dart';

part 'game_code.g.dart';

@HiveType(typeId: 6)
class GameCode extends HiveObject {
  @HiveField(0)
  final String code;

  @HiveField(1)
  DateTime usedOn;

  @HiveField(2)
  DateTime discoveredOn;

  @HiveField(3)
  DateTime expiredOn;

  @HiveField(4)
  bool isExpired;

  @HiveField(5)
  int region;

  GameCode(this.code, this.usedOn, this.discoveredOn, this.expiredOn, this.isExpired, this.region);
}
