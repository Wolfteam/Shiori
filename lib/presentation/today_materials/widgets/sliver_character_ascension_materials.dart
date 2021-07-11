import 'package:flutter/material.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/presentation/home/widgets/char_card_ascension_material.dart';

class SliverCharacterAscensionMaterials extends StatelessWidget {
  final List<TodayCharAscensionMaterialsModel> charAscMaterials;

  const SliverCharacterAscensionMaterials({
    Key? key,
    required this.charAscMaterials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: charAscMaterials.length,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            final e = charAscMaterials[index];
            return e.isFromBoss
                ? CharCardAscensionMaterial.fromBoss(
                    name: e.name,
                    image: e.image,
                    bossName: e.bossName,
                    charImgs: e.characters,
                  )
                : CharCardAscensionMaterial.fromDays(
                    name: e.name,
                    image: e.image,
                    days: e.days,
                    charImgs: e.characters,
                  );
          },
        ),
      ),
    );
  }
}
