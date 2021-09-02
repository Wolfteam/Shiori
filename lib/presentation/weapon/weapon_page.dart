import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/scaffold_with_fab.dart';
import 'package:genshindb/presentation/weapon/widgets/weapon_detail_bottom.dart';
import 'package:genshindb/presentation/weapon/widgets/weapon_detail_top.dart';

class WeaponPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait ? const _PortraitLayout() : const _LandscapeLayout();
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithFab(
      child: BlocBuilder<WeaponBloc, WeaponState>(
        builder: (context, state) {
          return state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) => Stack(
              fit: StackFit.passthrough,
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                WeaponDetailTop(
                  name: state.name,
                  atk: state.atk,
                  rarity: state.rarity,
                  secondaryStatType: state.secondaryStat,
                  secondaryStatValue: state.secondaryStatValue,
                  type: state.weaponType,
                  locationType: state.locationType,
                  image: state.fullImage,
                ),
                WeaponDetailBottom(
                  rarity: state.rarity,
                  description: state.description,
                  ascensionMaterials: state.ascensionMaterials,
                  charImgs: state.charImages,
                  craftingMaterials: state.craftingMaterials,
                  refinements: state.refinements,
                  secondaryStatType: state.secondaryStat,
                  stats: state.stats,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<WeaponBloc, WeaponState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 40,
                  child: WeaponDetailTop(
                    name: state.name,
                    atk: state.atk,
                    rarity: state.rarity,
                    secondaryStatType: state.secondaryStat,
                    secondaryStatValue: state.secondaryStatValue,
                    type: state.weaponType,
                    locationType: state.locationType,
                    image: state.fullImage,
                  ),
                ),
                Expanded(
                  flex: 60,
                  child: WeaponDetailBottom(
                    rarity: state.rarity,
                    description: state.description,
                    ascensionMaterials: state.ascensionMaterials,
                    charImgs: state.charImages,
                    craftingMaterials: state.craftingMaterials,
                    refinements: state.refinements,
                    secondaryStatType: state.secondaryStat,
                    stats: state.stats,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
