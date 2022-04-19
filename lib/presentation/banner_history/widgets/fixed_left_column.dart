import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/banner_history/widgets/item_release_history_dialog.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/images/circle_weapon.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

enum _ItemOptionsType {
  details,
  releaseHistory,
}

class FixedLeftColumn extends StatelessWidget {
  final List<BannerHistoryItemModel> items;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const FixedLeftColumn({
    Key? key,
    required this.items,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        items.length,
        (index) {
          final item = items[index];
          return _ItemCard(
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            margin: margin,
            image: item.image,
            itemKey: item.key,
            type: item.type,
            rarity: item.rarity,
            name: item.name,
            number: item.versions.where((el) => el.released).length,
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String itemKey;
  final BannerHistoryItemType type;
  final String name;
  final String image;
  final int rarity;
  final int number;
  final EdgeInsets margin;
  final double cellWidth;
  final double cellHeight;

  const _ItemCard({
    Key? key,
    required this.itemKey,
    required this.type,
    required this.name,
    required this.image,
    required this.rarity,
    required this.number,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = rarity.getRarityGradient();
    const double radius = 10;
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(radius)),
      onTap: () => showDialog<_ItemOptionsType>(context: context, builder: (_) => const _OptionsDialog()).then(
        (value) async => _handleOptionSelected(value, context),
      ),
      child: Card(
        margin: margin,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          width: cellWidth,
          height: cellHeight,
          padding: Styles.edgeInsetHorizontal5,
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            fit: StackFit.passthrough,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 3),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black.withOpacity(0.25),
                    child: Tooltip(
                      message: '$number',
                      child: Text(
                        '$number',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  if (type == BannerHistoryItemType.character)
                    CircleCharacter(itemKey: itemKey, image: image, radius: 45)
                  else
                    CircleWeapon(itemKey: itemKey, image: image, radius: 45),
                  Tooltip(
                    message: name,
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOptionSelected(_ItemOptionsType? value, BuildContext context) async {
    if (value == null) {
      return;
    }

    switch (value) {
      case _ItemOptionsType.details:
        switch (type) {
          case BannerHistoryItemType.character:
            await CharacterPage.route(itemKey, context);
            break;
          case BannerHistoryItemType.weapon:
            await WeaponPage.route(itemKey, context);
            break;
        }
        break;
      case _ItemOptionsType.releaseHistory:
        await showDialog(context: context, builder: (_) => ItemReleaseHistoryDialog(itemKey: itemKey));
        break;
    }
  }
}

class _OptionsDialog extends StatelessWidget {
  const _OptionsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.selectAnOption),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        )
      ],
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(s.details),
              onTap: () => Navigator.pop(context, _ItemOptionsType.details),
            ),
            ListTile(
              title: Text(s.releaseHistory),
              onTap: () => Navigator.pop(context, _ItemOptionsType.releaseHistory),
            ),
          ],
        ),
      ),
    );
  }
}
