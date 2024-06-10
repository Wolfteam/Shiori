import 'dart:io';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class SquareItemImage extends StatelessWidget {
  final String image;
  final double size;
  final Function(String)? onTap;
  final BoxFit fit;
  final Alignment alignment;
  final Gradient? gradient;

  const SquareItemImage({
    super.key,
    required this.image,
    required this.size,
    this.onTap,
    this.fit = BoxFit.fill,
    this.alignment = Alignment.center,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap != null ? () => onTap!(image) : null,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: FadeInImage(
          placeholder: MemoryImage(kTransparentImage),
          image: FileImage(File(image)),
          fit: fit,
          alignment: alignment,
          height: size,
          width: size,
        ),
      ),
    );
  }
}
