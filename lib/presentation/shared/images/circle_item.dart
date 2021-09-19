import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CircleItem extends StatelessWidget {
  final String image;
  final double radius;
  final bool forDrag;
  final Function(String)? onTap;

  const CircleItem({
    Key? key,
    required this.image,
    this.radius = 35,
    this.forDrag = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: TRY ADDING A BACKGROUND WITH THE MATERIAL WIDGET
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: FadeInImage(
          placeholder: MemoryImage(kTransparentImage),
          image: AssetImage(image),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          height: radius * 2,
          width: radius * 2,
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
