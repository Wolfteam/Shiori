import 'package:flutter/cupertino.dart';
import 'package:genshindb/domain/models/models.dart';

class GameCodeModel {
  final String code;
  final bool isExpired;
  final bool isUsed;
  final List<ItemAscensionMaterialModel> rewards;

  GameCodeModel({
    @required this.code,
    @required this.isExpired,
    @required this.isUsed,
    @required this.rewards,
  });
}
