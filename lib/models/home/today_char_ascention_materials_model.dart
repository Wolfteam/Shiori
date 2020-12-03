import 'package:flutter/material.dart';

import '../../common/enums/day_type.dart';

class TodayCharAscentionMaterialsModel {
  final String name;
  final String image;
  final List<DayType> days;
  final String bossName;
  final List<String> charactersImg;

  bool get onlyObtainableInDays => days.isNotEmpty;

  TodayCharAscentionMaterialsModel.fromDays({
    @required this.name,
    @required this.image,
    @required this.days,
    @required this.charactersImg,
  }) : bossName = null;

  TodayCharAscentionMaterialsModel.fromBoss({
    @required this.name,
    @required this.image,
    @required this.bossName,
    @required this.charactersImg,
  }) : days = [];
}
