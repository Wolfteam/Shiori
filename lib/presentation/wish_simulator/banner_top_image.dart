import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/transform_tap_scale.dart';

typedef BannerTopImageTap = void Function(int);

class BannerTopImage extends StatelessWidget {
  final int index;
  final List<String> imagesPath;
  final double width;
  final double height;
  final bool selected;
  final BannerTopImageTap onTap;

  const BannerTopImage({
    required this.index,
    required this.imagesPath,
    required this.width,
    required this.height,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final singleScale = selected ? 1.9 : 1.7;
    final multiScale = selected ? 2.4 : 2.2;
    return Container(
      width: width,
      padding: Styles.edgeInsetAll10,
      child: TransformTapScale(
        onTap: () => onTap(index),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              color: selected ? const Color(0xFFf7f3d8) : const Color(0xFF4f6d95),
              height: height,
            ),
            Positioned(
              top: 0,
              child: imagesPath.length == 1
                  ? Image.asset(imagesPath.first, scale: singleScale)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imagesPath.map((path) => Image.file(File(path), scale: multiScale)).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
