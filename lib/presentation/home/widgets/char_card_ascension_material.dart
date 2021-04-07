import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/circle_character.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/material_item_button.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class CharCardAscensionMaterial extends StatelessWidget {
  final String name;
  final String image;
  final List<String> charImgs;
  final String bossName;
  final List<int> days;

  const CharCardAscensionMaterial.fromDays({
    Key key,
    @required this.name,
    @required this.image,
    @required this.days,
    @required this.charImgs,
  })  : bossName = null,
        super(key: key);

  const CharCardAscensionMaterial.fromBoss({
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
    final chars = charImgs.map((e) => CircleCharacter(image: e)).toList();
    final obtainOn = days.isNotEmpty ? s.translateDays(days) : bossName;

    return Card(
      margin: Styles.edgeInsetAll10,
      shape: Styles.cardShape,
      child: Container(
        padding: Styles.edgeInsetAll5,
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 35,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialItemButton(image: image, size: 100),
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
                      style: theme.textTheme.subtitle2.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 65,
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
