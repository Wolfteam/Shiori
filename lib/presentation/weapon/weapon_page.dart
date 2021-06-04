import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/scaffold_with_fab.dart';
import 'package:genshindb/presentation/weapon/widgets/weapon_detail_bottom.dart';
import 'package:genshindb/presentation/weapon/widgets/weapon_detaill_top.dart';

class WeaponPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWithFab(
      child: BlocBuilder<WeaponBloc, WeaponState>(
        builder: (context, state) {
          return state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (s) => Stack(
              children: [
                WeaponDetailTop(
                  name: s.name,
                  atk: s.atk,
                  rarity: s.rarity,
                  secondaryStatType: s.secondaryStat,
                  secondaryStatValue: s.secondaryStatValue,
                  type: s.weaponType,
                  locationType: s.locationType,
                  image: s.fullImage,
                ),
                WeaponDetailBottom(
                  description: s.description,
                  rarity: s.rarity,
                  secondaryStatType: s.secondaryStat,
                  stats: s.stats,
                  ascensionMaterials: s.ascensionMaterials,
                  refinements: s.refinements,
                  charImgs: s.charImages,
                  craftingMaterials: s.craftingMaterials,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
