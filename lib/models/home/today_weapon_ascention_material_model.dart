import 'package:flutter/widgets.dart';

import '../../common/enums/day_type.dart';

class TodayWeaponAscentionMaterialModel {
  final String name;
  final String image;
  final List<DayType> days;
  TodayWeaponAscentionMaterialModel({
    @required this.name,
    @required this.image,
    @required this.days,
  });
}
