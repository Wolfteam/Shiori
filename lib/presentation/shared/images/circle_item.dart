import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CircleItem extends StatelessWidget {
  final String image;
  final double radius;
  final bool forDrag;
  final bool imageSizeTimesTwo;
  final Function(String)? onTap;
  final BoxFit fit;
  final Alignment alignment;

  const CircleItem({
    Key? key,
    required this.image,
    this.radius = 35,
    this.forDrag = false,
    this.imageSizeTimesTwo = true,
    this.onTap,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: TRY ADDING A BACKGROUND WITH THE MATERIAL WIDGET
    final size = imageSizeTimesTwo ? radius * 2 : radius;
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: FadeInImage(
          placeholder: MemoryImage(kTransparentImage),
          image: AssetImage(image),
          fit: fit,
          alignment: alignment,
          height: size,
          width: size,
        ),
      ),
    );

    if (forDrag) {
      return avatar;
    }

    return Container(
      margin: const EdgeInsets.all(3),
      child: InkWell(
        radius: radius,
        borderRadius: BorderRadius.circular(radius),
        onTap: () => onTap != null ? onTap!(image) : {},
        child: avatar,
      ),
    );
  }
}
