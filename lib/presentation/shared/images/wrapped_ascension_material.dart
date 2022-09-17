import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/material_item_button.dart';

class WrappedAscensionMaterial extends StatelessWidget {
  final String itemKey;
  final String image;
  final int quantity;
  final double size;

  const WrappedAscensionMaterial({
    Key? key,
    required this.itemKey,
    required this.image,
    required this.quantity,
    this.size = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        MaterialItemButton(itemKey: itemKey, image: image, size: size),
        Container(
          margin: const EdgeInsets.only(left: 5, right: 10),
          child: Text('x $quantity'),
        ),
      ],
    );
  }
}
