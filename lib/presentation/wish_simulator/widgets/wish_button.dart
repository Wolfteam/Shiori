import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/transform_tap_scale.dart';

typedef WishButtonTap = void Function(int);

const _boxConstraints = BoxConstraints(maxWidth: 190, minWidth: 100);

class WishQuantityButton extends StatelessWidget {
  final int quantity;
  final String imagePath;
  final double width;
  final double height;
  final double iconSize;
  final WishButtonTap onTap;

  const WishQuantityButton({
    required this.quantity,
    required this.imagePath,
    required this.onTap,
    required this.width,
    required this.height,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return TransformTapScale(
      onTap: () => onTap(quantity),
      child: Container(
        width: width,
        height: height,
        constraints: _boxConstraints,
        padding: Styles.edgeInsetHorizontal16,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.wishBannerButtonBackgroundImgPath),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              s.wishXQuantity(quantity),
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.file(
                  File(imagePath),
                  width: iconSize,
                  height: iconSize,
                ),
                const SizedBox(width: 5),
                Text(
                  'x $quantity',
                  style: const TextStyle(color: Colors.red),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WishButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final GestureTapCallback onTap;

  const WishButton({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TransformTapScale(
      onTap: () => onTap(),
      child: Container(
        height: height,
        width: width,
        constraints: _boxConstraints,
        padding: Styles.edgeInsetHorizontal16,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.wishBannerButtonBackgroundImgPath),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
