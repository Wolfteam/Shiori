import 'package:flutter/material.dart';
import 'package:genshindb/common/styles.dart';

import '../../../common/enums/day_type.dart';

class CharCardAscentionMaterial extends StatelessWidget {
  final String name;
  final String image;
  final List<String> charImgs;
  final String bossName;
  final List<DayType> days;

  CharCardAscentionMaterial.fromDays({
    Key key,
    @required this.name,
    @required this.image,
    @required this.days,
    @required this.charImgs,
  })  : bossName = null,
        super(key: key);

  CharCardAscentionMaterial.fromBoss({
    Key key,
    @required this.name,
    @required this.image,
    @required this.bossName,
    @required this.charImgs,
  })  : days = [],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chars = charImgs
        .map((e) => Container(
              margin: Styles.edgeInsetAll5,
              child: Image.asset(e, width: 55, height: 55),
            ))
        .toList();
    final obtainOn = days.isNotEmpty ? days.fold('', (previousValue, element) => '$previousValue, $element') : bossName;
    return Card(
      margin: Styles.edgeInsetAll10,
      child: Container(
        padding: Styles.edgeInsetAll5,
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 40,
              child: Column(
                children: [
                  Image.asset(image, width: 120, height: 100),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    obtainOn,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.subtitle2.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 60,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: chars,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
