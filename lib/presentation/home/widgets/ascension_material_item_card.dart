import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/material_item_button.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class AscensionMaterialItemCard extends StatelessWidget {
  final String name;
  final String image;
  final List<int> days;
  final Widget child;

  const AscensionMaterialItemCard({
    Key? key,
    required this.name,
    required this.image,
    required this.days,
    required this.child,
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
        width: 250,
        padding: Styles.edgeInsetAll5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialItemButton(image: image, size: 100),
            Tooltip(
              message: name,
              child: Text(
                name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Tooltip(
              message: obtainOn,
              child: Text(
                obtainOn,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                style: theme.textTheme.subtitle2!.copyWith(fontSize: 12),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
