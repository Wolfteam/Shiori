import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class BannerMainImage extends StatelessWidget {
  final String topTitle;
  final Color topTitleColor;
  final String imagePath;
  final double margin;
  final double imageWidth;

  const BannerMainImage({
    required this.topTitle,
    required this.topTitleColor,
    required this.imagePath,
    required this.margin,
    required this.imageWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            width: imageWidth,
            fit: BoxFit.fill,
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              decoration: BoxDecoration(
                color: topTitleColor,
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15)),
              ),
              padding: Styles.edgeInsetAll5,
              child: Text(
                topTitle,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
