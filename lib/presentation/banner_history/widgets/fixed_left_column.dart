import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/images/circle_weapon.dart';
import 'package:shiori/presentation/shared/styles.dart';

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
      onTap: () {
        //show some details here ?
      },
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
                        style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
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
                      style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
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
}
