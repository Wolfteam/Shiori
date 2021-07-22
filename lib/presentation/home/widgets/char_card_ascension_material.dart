import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genshindb/presentation/home/widgets/ascension_material_item_card.dart';
import 'package:genshindb/presentation/shared/circle_character.dart';

class CharCardAscensionMaterial extends StatelessWidget {
  final String name;
  final String image;
  final List<String> charImgs;
  final String? bossName;
  final List<int> days;

  const CharCardAscensionMaterial.fromDays({
    Key? key,
    required this.name,
    required this.image,
    required this.days,
    required this.charImgs,
  })  : bossName = null,
        super(key: key);

  const CharCardAscensionMaterial.fromBoss({
    Key? key,
    required this.name,
    required this.image,
    required this.bossName,
    required this.charImgs,
  })  : days = const [],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AscensionMaterialItemCard(
      name: name,
      image: image,
      days: days,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: SizedBox(
          height: 70,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: charImgs.length,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) => CircleCharacter(image: charImgs[index]),
          ),
        ),
      ),
    );
  }
}
