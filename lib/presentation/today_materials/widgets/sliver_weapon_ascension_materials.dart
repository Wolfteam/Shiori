import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/home/widgets/weapon_card_ascension_material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SliverWeaponAscensionMaterials extends StatelessWidget {
  final List<TodayWeaponAscensionMaterialModel> weaponAscMaterials;
  final bool useListView;

  const SliverWeaponAscensionMaterials({
    Key? key,
    required this.weaponAscMaterials,
    this.useListView = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useListView) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: Styles.materialCardHeight,
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

    final mediaQuery = MediaQuery.of(context);
    final deviceType = getDeviceType(mediaQuery.size);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    return SliverToBoxAdapter(
      child: ResponsiveGridRow(
        children: weaponAscMaterials.map((e) {
          final child = WeaponCardAscensionMaterial(itemKey: e.key, name: e.name, image: e.image, days: e.days, weapons: e.weapons);

          switch (deviceType) {
            case DeviceScreenType.mobile:
              return ResponsiveGridCol(
                sm: isPortrait ? 12 : 6,
                md: isPortrait ? 6 : 4,
                xs: isPortrait ? 6 : 3,
                xl: isPortrait ? 3 : 2,
                child: child,
              );
            case DeviceScreenType.desktop:
            case DeviceScreenType.tablet:
              return ResponsiveGridCol(
                sm: isPortrait ? 3 : 4,
                md: isPortrait ? 4 : 3,
                xs: 3,
                xl: 3,
                child: child,
              );
            default:
              return ResponsiveGridCol(sm: 4, md: 3, xs: 4, xl: 3, child: child);
          }
        }).toList(),
      ),
    );
  }
}
