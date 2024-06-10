import 'dart:io';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CircleItemImage extends StatelessWidget {
  final String image;
  final double radius;
  final bool forDrag;
  final bool imageSizeTimesTwo;
  final Function(String)? onTap;
  final BoxFit fit;
  final Alignment alignment;
  final Color backgroundColor;
  final Gradient? gradient;

  const CircleItemImage({
    super.key,
    required this.image,
    this.radius = 35,
    this.forDrag = false,
    this.imageSizeTimesTwo = true,
    this.onTap,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
    this.backgroundColor = Colors.transparent,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    //TODO: TRY ADDING A BACKGROUND WITH THE MATERIAL WIDGET
    final size = imageSizeTimesTwo ? radius * 2 : radius;
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: ClipOval(
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

    final boxDecoration = BoxDecoration(shape: BoxShape.circle, gradient: gradient);

    if (forDrag) {
      if (gradient != null) {
        return DecoratedBox(
          decoration: boxDecoration,
          child: avatar,
        );
      }
      return avatar;
    }

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: boxDecoration,
      child: InkWell(
        radius: radius,
        borderRadius: BorderRadius.circular(radius),
        onTap: () => onTap != null ? onTap!(image) : {},
        child: avatar,
      ),
    );
  }
}
