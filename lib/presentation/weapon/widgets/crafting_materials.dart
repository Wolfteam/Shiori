import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/material/material_page.dart' as mp;
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/material_item_button.dart';

class CraftingMaterials extends StatelessWidget {
  final Color color;
  final List<ItemCommonWithQuantityAndName> craftingMaterials;

  const CraftingMaterials({
    required this.color,
    required this.craftingMaterials,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: s.craftingMaterials,
      color: color,
      children: ListTile.divideTiles(
        color: color,
        context: context,
        tiles: craftingMaterials.map(
          (e) => ListTile(
            leading: MaterialItemButton(
              itemKey: e.key,
              image: e.image,
              size: 36,
              useButton: false,
            ),
            title: Text('${e.name} x ${e.quantity}'),
            onTap: () => mp.MaterialPage.route(e.key, context),
          ),
        ),
      ).toList(),
    );
  }
}
