import 'package:flutter/material.dart';

import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';

class CharCardAscentionMaterial extends StatelessWidget {
  final String name;
  final String image;
  final List<String> charImgs;
  final String bossName;
  final List<int> days;

  const CharCardAscentionMaterial.fromDays({
    Key key,
    @required this.name,
    @required this.image,
    @required this.days,
    @required this.charImgs,
  })  : bossName = null,
        super(key: key);

  const CharCardAscentionMaterial.fromBoss({
    Key key,
    @required this.name,
    @required this.image,
    @required this.bossName,
    @required this.charImgs,
  })  : days = const [],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final chars = charImgs
        .map((e) => Container(
              margin: Styles.edgeInsetAll5,
              child: Image.asset(e, width: 55, height: 55),
            ))
        .toList();
    final obtainOn = days.isNotEmpty ? s.translateDays(days) : bossName;

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
                  Tooltip(
                    message: name,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tooltip(
                    message: obtainOn,
                    child: Text(
                      obtainOn,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.subtitle2.copyWith(fontSize: 12),
                    ),
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
