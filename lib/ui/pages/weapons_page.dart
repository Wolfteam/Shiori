import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../common/enums/weapon_type.dart';
import '../../common/styles.dart';
import '../../models/weapons/weapon_card_model.dart';
import '../widgets/common/search_box.dart';
import '../widgets/weapons/weapon_bottom_sheet.dart';
import '../widgets/weapons/weapon_card.dart';

class WeaponsPage extends StatelessWidget {
  final weapons = <WepaonCardModel>[
    WepaonCardModel(
      image: 'assets/weapons/swords/aquila_favonia.png',
      baseAtk: 48,
      name: 'Aquila Favonia',
      rarity: 5,
      type: WeaponType.sword,
    ),
    WepaonCardModel(
      image: 'assets/weapons/swords/festering_fang.png',
      baseAtk: 42,
      name: 'Festering Fang',
      rarity: 4,
      type: WeaponType.sword,
    ),
    WepaonCardModel(
      image: 'assets/weapons/polearms/primordial_jade_winged_spear.png',
      baseAtk: 48,
      name: 'Primordial Jade Winged-Spear',
      rarity: 5,
      type: WeaponType.polearm,
    ),
    WepaonCardModel(
      image: 'assets/weapons/polearms/vortex_vanquisher.png',
      baseAtk: 46,
      name: 'Vortex Vanquisher',
      rarity: 5,
      type: WeaponType.polearm,
    ),
    WepaonCardModel(
      image: 'assets/weapons/claymores/snow_tombed_starsilver.png',
      baseAtk: 44,
      name: 'Snow-Tombed Starsilver',
      rarity: 4,
      type: WeaponType.claymore,
    ),
    WepaonCardModel(
      image: 'assets/weapons/claymores/wolfs_gravestone.png',
      baseAtk: 46,
      name: "Wolf's Gravestone",
      rarity: 5,
      type: WeaponType.claymore,
    ),
    WepaonCardModel(
      image: 'assets/weapons/catalysts/eye_of_perception.png',
      baseAtk: 41,
      name: 'Eye of Perception',
      rarity: 4,
      type: WeaponType.catalyst,
    ),
    WepaonCardModel(
      image: 'assets/weapons/catalysts/lost_prayer_to_the_sacred_winds.png',
      baseAtk: 46,
      name: 'Lost Prayer to the Sacred Winds',
      rarity: 5,
      type: WeaponType.catalyst,
    ),
    WepaonCardModel(
      image: 'assets/weapons/bows/dreams_of_dragonfell.png',
      baseAtk: 46,
      name: 'Dreams of Dragonfell',
      rarity: 5,
      type: WeaponType.bow,
    ),
    WepaonCardModel(
      image: 'assets/weapons/bows/rust.png',
      baseAtk: 42,
      name: 'Rust',
      rarity: 4,
      type: WeaponType.bow,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildFiltersSwitch(context),
        _buildGrid(context),
      ],
    );
  }

  Widget _buildFiltersSwitch(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SearchBox(),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'All',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline6,
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () => _showFiltersModal(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: isPortrait ? 2 : 3,
        itemBuilder: (ctx, index) {
          final weapon = weapons[index];
          return WeaponCard(
            baseAtk: weapon.baseAtk,
            image: weapon.image,
            name: weapon.name,
            rarity: weapon.rarity,
            type: weapon.type,
          );
        },
        itemCount: weapons.length,
        crossAxisSpacing: isPortrait ? 10 : 5,
        mainAxisSpacing: 5,
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      ),
    );
  }

  Future<void> _showFiltersModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => WeaponBottomSheet(),
    );
  }
}
