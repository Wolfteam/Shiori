import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

class GameCodeModel {
  final String code;
  final AppServerResetTimeType? region;

  final DateTime? discoveredOn;
  final DateTime? expiredOn;
  final bool isExpired;

  final bool isUsed;
  final List<ItemAscensionMaterialModel> rewards;

  GameCodeModel({
    required this.code,
    required this.isUsed,
    required this.rewards,
    required this.isExpired,
    this.discoveredOn,
    this.expiredOn,
    this.region,
  });
}
