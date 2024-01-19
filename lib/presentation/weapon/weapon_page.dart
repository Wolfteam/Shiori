import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/disabled_card_surface_tint_color.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';
import 'package:shiori/presentation/weapon/widgets/bottom.dart';
import 'package:shiori/presentation/weapon/widgets/top.dart';

class WeaponPage extends StatelessWidget {
  final String itemKey;

  const WeaponPage({super.key, required this.itemKey});

  static Future<void> route(String itemKey, BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => WeaponPage(itemKey: itemKey));
    await Navigator.push(context, route);
    await route.completed;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return DisabledSurfaceCardTintColor(
      child: BlocProvider(
        create: (context) => Injection.weaponBloc..add(WeaponEvent.loadFromKey(key: itemKey)),
        child: isPortrait ? const _PortraitLayout() : const _LandscapeLayout(),
      ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithFab(
      child: BlocBuilder<WeaponBloc, WeaponState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading.column(),
          loaded: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Top(
                itemKey: state.key,
                name: state.name,
                atk: state.atk,
                rarity: state.rarity,
                secondaryStatType: state.secondaryStat,
                secondaryStatValue: state.secondaryStatValue,
                type: state.weaponType,
                locationType: state.locationType,
                image: state.fullImage,
                isInInventory: state.isInInventory,
              ),
              BottomPortraitLayout(
                rarity: state.rarity,
                description: state.description,
                ascensionMaterials: state.ascensionMaterials,
                charImgs: state.characters,
                craftingMaterials: state.craftingMaterials,
                refinements: state.refinements,
                secondaryStatType: state.secondaryStat,
                stats: state.stats,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<WeaponBloc, WeaponState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading.column(),
            loaded: (state) => Row(
              children: [
                Expanded(
                  flex: 40,
                  child: Top(
                    itemKey: state.key,
                    name: state.name,
                    atk: state.atk,
                    rarity: state.rarity,
                    secondaryStatType: state.secondaryStat,
                    secondaryStatValue: state.secondaryStatValue,
                    type: state.weaponType,
                    locationType: state.locationType,
                    image: state.fullImage,
                    isInInventory: state.isInInventory,
                  ),
                ),
                Expanded(
                  flex: 60,
                  child: BottomLandscapeLayout(
                    rarity: state.rarity,
                    description: state.description,
                    ascensionMaterials: state.ascensionMaterials,
                    charImgs: state.characters,
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
