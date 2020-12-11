import 'package:flutter/material.dart';

class TodayCharAscentionMaterialsModel {
  final String name;
  final String image;
  final List<int> days;
  final String bossName;
  final List<String> characters;
  bool get isFromBoss => bossName != null;

  bool get onlyObtainableInDays => days.isNotEmpty;

  TodayCharAscentionMaterialsModel.fromDays({
    @required this.name,
    @required this.image,
    @required this.days,
    @required this.characters,
  }) : bossName = null;

  TodayCharAscentionMaterialsModel.fromBoss({
    @required this.name,
    @required this.image,
    @required this.bossName,
    @required this.characters,
  }) : days = [];
}
