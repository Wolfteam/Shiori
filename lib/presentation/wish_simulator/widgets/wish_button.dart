import 'dart:io';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/transform_tap_scale.dart';

typedef WishButtonTap = void Function(int);

class WishButton extends StatelessWidget {
  final int quantity;
  final String imagePath;
  final double height;
  final double iconSize;
  final WishButtonTap onTap;

  const WishButton({
    required this.quantity,
    required this.imagePath,
    required this.onTap,
    this.height = 55,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final width = getValueForScreenType<double>(
      context: context,
      mobile: 170,
      tablet: 230,
      desktop: 230,
    );
    return TransformTapScale(
      onTap: () => onTap(quantity),
      child: Container(
        width: width,
        height: height,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
