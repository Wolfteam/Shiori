import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/material_item_button.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

class MaterialQuantityRow extends StatelessWidget {
  final String itemKey;
  final String image;
  final int quantity;
  final double? size;

  const MaterialQuantityRow({
    required this.itemKey,
    required this.image,
    required this.quantity,
    this.size,
  });

  MaterialQuantityRow.fromItemCommonQuantity({required ItemCommonWithQuantity item, this.size})
      : itemKey = item.key,
        image = item.image,
        quantity = item.quantity;

  MaterialQuantityRow.fromAscensionMaterial({required ItemAscensionMaterialModel item, this.size})
      : itemKey = item.key,
        image = item.image,
        quantity = item.requiredQuantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Styles.edgeInsetAll5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialItemButton(
            itemKey: itemKey,
            image: image,
            size: size ?? SizeUtils.getSizeForCircleImages(context) * 0.6,
            useButton: false,
          ),
          Text('x$quantity', overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
