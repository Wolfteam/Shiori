import 'package:flutter/material.dart';

import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';

class WeaponCardAscentionMaterial extends StatelessWidget {
  final String name;
  final String image;
  final List<int> days;

  const WeaponCardAscentionMaterial({
    Key key,
    @required this.name,
    @required this.image,
    @required this.days,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final obtainOn = s.translateDays(days);
    return Card(
      margin: Styles.edgeInsetAll10,
      shape: Styles.cardShape,
      child: Container(
        padding: Styles.edgeInsetAll5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
