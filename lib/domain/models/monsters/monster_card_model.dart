import 'package:flutter/foundation.dart';
import 'package:genshindb/domain/enums/enums.dart';

class MonsterCardModel {
  final String key;
  final String image;
  final String name;
  final MonsterType type;
  final bool isComingSoon;

  MonsterCardModel({
    @required this.key,
    @required this.image,
    @required this.name,
    @required this.type,
    @required this.isComingSoon,
  });
}
