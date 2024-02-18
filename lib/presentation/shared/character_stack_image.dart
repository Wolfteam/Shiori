import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:transparent_image/transparent_image.dart';

class CharacterStackImage extends StatelessWidget {
  final String name;
  final String image;
  final int rarity;
  final double height;
  final VoidCallback? onTap;
  final BoxFit fit;

  const CharacterStackImage({
    super.key,
    required this.name,
    required this.image,
    required this.rarity,
    this.onTap,
    this.height = 280,
    this.fit = BoxFit.fitHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            FadeInImage(
              height: height,
              placeholder: MemoryImage(kTransparentImage),
              fit: fit,
              image: FileImage(File(image)),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: Styles.edgeInsetAll10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Rarity(stars: rarity, color: Colors.white),
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
