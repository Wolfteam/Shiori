part of '../weapon_page.dart';

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
      color: color,
      title: s.craftingMaterials,
      children: [
        DetailMaterialsHorizontalListColumn(
          color: color,
          title: s.craftingMaterials,
          items: craftingMaterials,
        ),
      ],
    );
  }
}
