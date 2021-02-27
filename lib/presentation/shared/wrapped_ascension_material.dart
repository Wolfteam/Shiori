import 'package:flutter/material.dart';

class WrappedAscensionMaterial extends StatelessWidget {
  final String image;
  final int quantity;
  final double size;
  const WrappedAscensionMaterial({
    Key key,
    @required this.image,
    @required this.quantity,
    this.size = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        Image.asset(image, width: size, height: size),
        Container(
          margin: const EdgeInsets.only(left: 5, right: 10),
          child: Text('x $quantity'),
        ),
      ],
    );
  }
}
