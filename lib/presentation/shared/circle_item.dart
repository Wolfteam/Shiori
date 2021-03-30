import 'package:flutter/material.dart';

class CircleItem extends StatelessWidget {
  final String image;
  final double radius;
  final bool forDrag;
  final Function(String) onTap;

  const CircleItem({
    Key key,
    @required this.image,
    this.radius = 35,
    this.forDrag = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage(image),
    );
    if (forDrag) {
      return avatar;
    }

    return Container(
      margin: const EdgeInsets.all(3),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => onTap != null ? onTap(image) : {},
        child: avatar,
      ),
    );
  }
}
