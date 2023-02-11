import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/material_item_button.dart';
import 'package:shiori/presentation/shared/styles.dart';

class AscensionMaterialItemCard extends StatelessWidget {
  final String itemKey;
  final String name;
  final String image;
  final List<int> days;
  final Widget child;

  const AscensionMaterialItemCard({
    super.key,
    required this.itemKey,
    required this.name,
    required this.image,
    required this.days,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final obtainOn = s.translateDays(days);

    return Card(
      margin: Styles.edgeInsetAll10,
      shape: Styles.cardShape,
      child: Container(
        width: Styles.materialCardWidth,
        padding: Styles.edgeInsetAll5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialItemButton(itemKey: itemKey, image: image, size: 100),
            Tooltip(
              message: name,
              child: Text(
                name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Tooltip(
              message: obtainOn,
              child: Text(
                obtainOn,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                style: theme.textTheme.titleSmall!.copyWith(fontSize: 12),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
