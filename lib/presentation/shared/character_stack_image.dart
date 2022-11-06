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
  final Function? onTap;
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
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(),
      child: Stack(
        alignment: Alignment.bottomLeft,
        fit: StackFit.passthrough,
        children: [
          FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            height: height,
            fit: fit,
            image: FileImage(File(image)),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
            padding: Styles.edgeInsetAll10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Rarity(stars: rarity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
