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
    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, alignment: WrapAlignment.center, children: [
      Image.asset(image, width: 30, height: 30),
      Container(
        margin: EdgeInsets.only(left: 5, right: 10),
        child: Text('x $quantity'),
      ),
    ]);
  }
}
