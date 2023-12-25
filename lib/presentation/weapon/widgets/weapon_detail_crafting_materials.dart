import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/images/wrapped_ascension_material.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

class WeaponCraftingMaterials extends StatelessWidget {
  final List<ItemAscensionMaterialModel> materials;
  final Color rarityColor;

  const WeaponCraftingMaterials({
    super.key,
    required this.materials,
    required this.rarityColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = SizeUtils.getSizeForCircleImages(context);
    final rows = materials
        .map(
          (m) => WrappedAscensionMaterial(
            itemKey: m.key,
            image: m.image,
            quantity: m.requiredQuantity,
            size: size * 1.2,
          ),
        )
        .toList();

    final body = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: rows,
    );

    return ItemDescriptionDetail(title: s.craftingMaterials, body: body, textColor: rarityColor);
  }
}
