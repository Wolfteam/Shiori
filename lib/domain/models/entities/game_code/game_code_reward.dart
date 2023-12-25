import 'package:hive/hive.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'game_code_reward.g.dart';

@HiveType(typeId: 8)
class GameCodeReward extends BaseEntity {
  @HiveField(0)
  final int gameCodeKey;

  @HiveField(1)
  final String itemKey;

  @HiveField(2)
  final int quantity;

  GameCodeReward(this.gameCodeKey, this.itemKey, this.quantity);
}
