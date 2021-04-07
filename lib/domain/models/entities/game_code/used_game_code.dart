import 'package:hive/hive.dart';

part 'used_game_code.g.dart';

@HiveType(typeId: 6)
class UsedGameCode extends HiveObject {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final DateTime usedOn;

  UsedGameCode(this.code, this.usedOn);
}
