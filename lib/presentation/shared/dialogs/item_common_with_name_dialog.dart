import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/images/circle_item_image.dart';
import 'package:shiori/presentation/shared/images/square_item_image.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

typedef OnTap = void Function(String);

class ItemCommonWithNameDialog extends StatelessWidget {
  final String title;
  final List<ItemCommonWithName> items;
  final List<ItemCommonWithQuantityAndName> itemsWithQuantity;
  final BoxFit fit;
  final bool useSquare;
  final OnTap? onTap;

  ItemCommonWithNameDialog.simple({
    required this.title,
    required this.items,
    this.onTap,
    this.useSquare = true,
    this.fit = BoxFit.fill,
  })  : assert(items.isNotEmpty),
        itemsWithQuantity = [];

  ItemCommonWithNameDialog.quantity({
    required this.title,
    required this.itemsWithQuantity,
    this.onTap,
    this.useSquare = true,
    this.fit = BoxFit.fill,
  })  : assert(itemsWithQuantity.isNotEmpty),
        items = [];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    final int count = max(items.length, itemsWithQuantity.length);
    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: mq.getDialogBoxConstraints(count + 1, itemHeight: itemsWithQuantity.isNotEmpty ? 70 : 50),
        child: ListView.builder(
          itemCount: count,
          itemBuilder: (context, index) {
            if (items.isNotEmpty) {
              return _RowItem(
                item: items[index],
                fit: fit,
                useSquare: useSquare,
                onTap: onTap,
              );
            }

            return _QuantityRowItem(
              item: itemsWithQuantity[index],
              fit: fit,
              useSquare: useSquare,
              onTap: onTap,
            );
          },
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.ok),
        ),
      ],
    );
  }
}

class _Image extends StatelessWidget {
  final String image;
  final BoxFit fit;
  final bool useSquare;

  const _Image({
    required this.image,
    required this.fit,
    required this.useSquare,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: useSquare
          ? SquareItemImage(
              image: image,
              fit: fit,
              size: SizeUtils.getSizeForSquareImages(context, smallImage: true).height,
            )
          : CircleItemImage(
              image: image,
              fit: fit,
              radius: SizeUtils.getSizeForCircleImages(context, smallImage: true),
            ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final ItemCommonWithName item;
  final BoxFit fit;
  final bool useSquare;
  final OnTap? onTap;

  const _RowItem({
    required this.item,
    required this.fit,
    required this.useSquare,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap == null ? null : () => onTap!.call(item.key),
      child: Container(
        margin: Styles.edgeInsetVertical5,
        child: Row(
          children: [
            _Image(
              image: item.iconImage,
              fit: fit,
              useSquare: useSquare,
            ),
            Expanded(
              child: Container(
                margin: Styles.edgeInsetHorizontal10,
                child: Text(
                  item.name,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityRowItem extends StatelessWidget {
  final ItemCommonWithQuantityAndName item;
  final BoxFit fit;
  final bool useSquare;
  final OnTap? onTap;

  const _QuantityRowItem({
    required this.item,
    required this.fit,
    required this.useSquare,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap == null ? null : () => onTap!.call(item.key),
      child: Container(
        margin: Styles.edgeInsetVertical5,
        child: Row(
          children: [
            _Image(
              image: item.iconImage,
              fit: fit,
              useSquare: useSquare,
            ),
            Expanded(
              child: Container(
                margin: Styles.edgeInsetHorizontal10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                    Text(
                      '${s.quantity}: ${item.quantity}',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
