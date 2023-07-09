import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';

class BannerMainImage extends StatelessWidget {
  final String topTitle;
  final Color topTitleColor;
  final String imagePath;
  final BannerItemType type;

  const BannerMainImage({
    required this.topTitle,
    required this.topTitleColor,
    required this.imagePath,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isStandardBanner = type == BannerItemType.standard;
    return Center(
      child: Stack(
        children: [
          if (isStandardBanner)
            Image.asset(
              imagePath,
              fit: BoxFit.contain,
            )
          else
            Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          Positioned.directional(
            top: 0,
            start: 0,
            textDirection: TextDirection.ltr,
            child: Container(
              decoration: BoxDecoration(
                color: topTitleColor,
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              child: Text(
                topTitle,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
