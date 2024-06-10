import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class MonsterCard extends StatelessWidget {
  final String itemKey;
  final String image;
  final String name;
  final MonsterType type;
  final bool isComingSoon;
  final bool isInSelectionMode;

  static const double itemWidth = 200;
  static const double itemHeight = 200;

  const MonsterCard({
    super.key,
    required this.itemKey,
    required this.image,
    required this.name,
    required this.type,
    required this.isComingSoon,
    this.isInSelectionMode = false,
  });

  MonsterCard.item({
    super.key,
    required MonsterCardModel item,
    this.isInSelectionMode = false,
  })  : itemKey = item.key,
        type = item.type,
        name = item.name,
        image = item.image,
        isComingSoon = item.isComingSoon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: itemWidth,
      height: itemHeight,
      child: InkWell(
        borderRadius: Styles.mainCardBorderRadius,
        onTap: () => _onTap(context),
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: Styles.mainCardShape,
          elevation: Styles.cardTenElevation,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              FadeInImage(
                width: itemWidth,
                height: itemHeight,
                placeholder: MemoryImage(kTransparentImage),
                fit: BoxFit.fill,
                placeholderFit: BoxFit.fill,
                alignment: Alignment.topCenter,
                image: FileImage(File(image)),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: Styles.commonCardBoxDecoration,
                  width: double.infinity,
                  padding: Styles.edgeInsetAll10,
                  child: Tooltip(
                    message: name,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (isInSelectionMode) {
      Navigator.pop(context, itemKey);
      return;
    }

    final fToast = ToastUtils.of(context);
    final s = S.of(context);
    ToastUtils.showWarningToast(fToast, s.comingSoon);
  }
}
