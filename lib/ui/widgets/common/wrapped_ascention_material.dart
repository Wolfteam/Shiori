import 'package:flutter/material.dart';

class WrappedAscentionMaterial extends StatelessWidget {
  final String image;
  final int quantity;
  const WrappedAscentionMaterial({
    Key key,
    @required this.image,
    @required this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Image.asset(image, width: 20, height: 20),
      Container(
        margin: EdgeInsets.only(left: 5, right: 10),
        child: Text('x $quantity'),
      ),
    ]);
  }
}
