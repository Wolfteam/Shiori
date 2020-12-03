import 'package:flutter/material.dart';

import '../../../common/enums/day_type.dart';
import '../../../common/styles.dart';

class WeaponCardAscentionMaterial extends StatelessWidget {
  final String name;
  final String image;
  final List<DayType> days;

  const WeaponCardAscentionMaterial({
    Key key,
    @required this.name,
    @required this.image,
    @required this.days,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obtainOn = days.fold('', (previousValue, element) => '$previousValue, $element');
    return Card(
      margin: Styles.edgeInsetAll10,
      child: Container(
        padding: Styles.edgeInsetAll5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(image, width: 120, height: 100),
            Text(name, textAlign: TextAlign.center),
            Text(obtainOn, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
