import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/home/widgets/weapon_card_ascension_material.dart';
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SliverWeaponAscensionMaterials extends StatelessWidget {
  final List<TodayWeaponAscensionMaterialModel> weaponAscMaterials;
  final bool useListView;

  const SliverWeaponAscensionMaterials({
    super.key,
    required this.weaponAscMaterials,
    this.useListView = true,
  });

  @override
  Widget build(BuildContext context) {
    if (weaponAscMaterials.isEmpty) {
      return const SliverToBoxAdapter(
        child: NothingFound(),
      );
    }

    const double width = Styles.homeCardWidth + 50;
    const double height = Styles.materialCardHeight;

    if (useListView) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: height,
          child: ListView.builder(
            itemCount: weaponAscMaterials.length,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) {
              final item = weaponAscMaterials[index];
              return WeaponCardAscensionMaterial(
                itemKey: item.key,
                name: item.name,
                image: item.image,
                days: item.days,
                weapons: item.weapons,
              );
            },
          ),
        ),
      );
    }

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width,
        mainAxisExtent: height,
        childAspectRatio: width / height,
      ),
      itemCount: weaponAscMaterials.length,
      itemBuilder: (context, index) {
        final e = weaponAscMaterials[index];
        return WeaponCardAscensionMaterial(itemKey: e.key, name: e.name, image: e.image, days: e.days, weapons: e.weapons);
      },
    );
  }
}
