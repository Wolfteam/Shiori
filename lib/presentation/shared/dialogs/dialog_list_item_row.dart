import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/images/circle_weapon.dart';
import 'package:shiori/presentation/shared/styles.dart';

typedef RowEndWidget = Widget Function(String);

class DialogListItemRow extends StatelessWidget {
  final ItemType itemType;
  final String itemKey;
  final String image;
  final String name;
  final RowEndWidget? getRowEndWidget;

  const DialogListItemRow({
    super.key,
    required this.itemType,
    required this.itemKey,
    required this.image,
    required this.name,
    this.getRowEndWidget,
  }) : assert(itemType == ItemType.character || itemType == ItemType.weapon);

  DialogListItemRow.fromItem({
    Key? key,
    required ItemType itemType,
    required ItemCommonWithName item,
    RowEndWidget? getRightWidget,
  }) : this(key: key, itemType: itemType, itemKey: item.key, image: item.image, name: item.name, getRowEndWidget: getRightWidget);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (itemType == ItemType.character)
              CircleCharacter(itemKey: itemKey, image: image, radius: 40)
            else
              CircleWeapon(itemKey: itemKey, image: image, radius: 40),
            Expanded(
              child: Padding(
                padding: Styles.edgeInsetHorizontal16,
                child: getRowEndWidget != null
                    ? getRowEndWidget!.call(itemKey)
                    : Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: theme.textTheme.titleMedium,
                      ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
