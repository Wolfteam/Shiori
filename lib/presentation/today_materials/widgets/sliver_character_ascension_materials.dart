import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/home/widgets/char_card_ascension_material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SliverCharacterAscensionMaterials extends StatelessWidget {
  final List<TodayCharAscensionMaterialsModel> charAscMaterials;
  final bool useListView;

  const SliverCharacterAscensionMaterials({
    Key? key,
    required this.charAscMaterials,
    this.useListView = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useListView) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: Styles.materialCardHeight,
          child: ListView.builder(
            itemCount: charAscMaterials.length,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) {
              final e = charAscMaterials[index];
              return e.isFromBoss
                  ? CharCardAscensionMaterial.fromBoss(name: e.name, image: e.image, bossName: e.bossName, charImgs: e.characters)
                  : CharCardAscensionMaterial.fromDays(name: e.name, image: e.image, days: e.days, charImgs: e.characters);
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
        children: charAscMaterials.map((e) {
          final child = e.isFromBoss
              ? CharCardAscensionMaterial.fromBoss(name: e.name, image: e.image, bossName: e.bossName, charImgs: e.characters)
              : CharCardAscensionMaterial.fromDays(name: e.name, image: e.image, days: e.days, charImgs: e.characters);

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
