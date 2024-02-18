part of '../character_page.dart';

class _AscensionMaterials extends StatelessWidget {
  final Color color;
  final List<CharacterAscensionModel> ascensionMaterials;

  const _AscensionMaterials({
    required this.color,
    required this.ascensionMaterials,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      color: color,
      title: s.ascensionMaterials,
      children: [
        DetailMaterialsSliderColumn(
          color: color,
          data: ascensionMaterials.map((e) => MaterialsData.fromAscensionMaterial(e)).toList(),
        ),
      ],
    );
  }
}
