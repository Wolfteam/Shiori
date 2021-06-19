import 'package:flutter/material.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/wrapped_ascension_material.dart';

class WeaponCraftingMaterials extends StatelessWidget {
  final List<ItemAscensionMaterialModel> materials;
  final Color rarityColor;

  const WeaponCraftingMaterials({
    Key? key,
    required this.materials,
    required this.rarityColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rows = materials.map((m) => WrappedAscensionMaterial(image: m.fullImagePath, quantity: m.quantity, size: 50)).toList();

    final body = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: rows,
    );

    return ItemDescriptionDetail(title: s.craftingMaterials, body: body, textColor: rarityColor);
  }
}
