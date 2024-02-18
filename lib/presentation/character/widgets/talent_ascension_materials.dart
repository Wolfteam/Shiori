part of '../character_page.dart';

class _TalentAscensionMaterials extends StatelessWidget {
  final Color color;
  final int? number;
  final List<CharacterTalentAscensionModel> talentAscensionsMaterials;

  const _TalentAscensionMaterials({
    required this.color,
    this.number,
    required this.talentAscensionsMaterials,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      color: color,
      title: number != null ? s.talentAscensionX(number!) : s.talentsAscension,
      children: [
        DetailMaterialsSliderColumn(
          color: color,
          data: talentAscensionsMaterials.map((e) => MaterialsData.fromTalentAscensionMaterial(e)).toList(),
        ),
      ],
    );
  }
}
