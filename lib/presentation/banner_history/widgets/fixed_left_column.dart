import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
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
    required this.number,
    required this.margin,
    required this.cellWidth,
    required this.cellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = '$name ($number)';
    return InkWell(
      onTap: () {
        //show some details here ?
      },
      child: Card(
        margin: margin,
        color: theme.colorScheme.primary,
        elevation: 10,
        child: Container(
          alignment: Alignment.center,
          width: cellWidth,
          height: cellHeight,
          padding: Styles.edgeInsetHorizontal5,
          child: Column(
            children: [
              if (type == BannerHistoryItemType.character)
                CircleCharacter(itemKey: itemKey, image: image, radius: 45)
              else
                CircleWeapon(itemKey: itemKey, image: image, radius: 45),
              Tooltip(
                message: text,
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
