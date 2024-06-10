import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/home/widgets/ascension_material_item_card.dart';
import 'package:shiori/presentation/shared/images/character_icon_image.dart';

class CharCardAscensionMaterial extends StatelessWidget {
  final String itemKey;
  final String name;
  final String image;
  final List<ItemCommonWithName> characters;
  final String? bossName;
  final List<int> days;

  const CharCardAscensionMaterial.fromDays({
    super.key,
    required this.itemKey,
    required this.name,
    required this.image,
    required this.days,
    required this.characters,
  }) : bossName = null;

  const CharCardAscensionMaterial.fromBoss({
    super.key,
    required this.itemKey,
    required this.name,
    required this.image,
    required this.bossName,
    required this.characters,
  }) : days = const [];

  @override
  Widget build(BuildContext context) {
    return AscensionMaterialItemCard(
      itemKey: itemKey,
      name: name,
      image: image,
      days: days,
      child: SizedBox(
        height: 70,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: characters.length,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            final item = characters[index];
            return CharacterIconImage(itemKey: item.key, image: item.iconImage);
          },
        ),
      ),
    );
  }
}
