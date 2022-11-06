import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/home/widgets/ascension_material_item_card.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';

class CharCardAscensionMaterial extends StatelessWidget {
  final String itemKey;
  final String name;
  final String image;
  final List<ItemCommon> charImgs;
  final String? bossName;
  final List<int> days;

  const CharCardAscensionMaterial.fromDays({
    super.key,
    required this.itemKey,
    required this.name,
    required this.image,
    required this.days,
    required this.charImgs,
  }) : bossName = null;

  const CharCardAscensionMaterial.fromBoss({
    super.key,
    required this.itemKey,
    required this.name,
    required this.image,
    required this.bossName,
    required this.charImgs,
  }) : days = const [];

  @override
  Widget build(BuildContext context) {
    return AscensionMaterialItemCard(
      itemKey: itemKey,
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
            itemBuilder: (ctx, index) => CircleCharacter.fromItem(item: charImgs[index]),
          ),
        ),
      ),
    );
  }
}
