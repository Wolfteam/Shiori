import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/character/widgets/bottom.dart';
import 'package:shiori/presentation/character/widgets/top.dart';
import 'package:shiori/presentation/shared/disabled_card_surface_tint_color.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';

class CharacterPage extends StatelessWidget {
  final String itemKey;

  const CharacterPage({super.key, required this.itemKey});

  static Future<void> route(String itemKey, BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => CharacterPage(itemKey: itemKey));
    await Navigator.push(context, route);
    await route.completed;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return DisabledSurfaceCardTintColor(
      child: BlocProvider<CharacterBloc>(
        create: (context) => Injection.characterBloc..add(CharacterEvent.loadFromKey(key: itemKey)),
        child: isPortrait ? const _PortraitLayout() : const _LandscapeLayout(),
      ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout();

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return ScaffoldWithFab(
      child: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) => state.maybeMap(
          loaded: (state) => Column(
            children: [
              Top(
                itemKey: state.key,
                elementType: state.elementType,
                name: state.name,
                rarity: state.rarity,
                region: state.region,
                role: state.role,
                weaponType: state.weaponType,
                birthday: state.birthday,
                fullImage: state.fullImage,
                secondFullImage: state.secondFullImage,
                isInInventory: state.isInInventory,
              ),
              if (isPortrait)
                BottomPortraitLayout(
                  description: state.description,
                  elementType: state.elementType,
                  subStatType: state.subStatType,
                  stats: state.stats,
                  skills: state.skills,
                  passives: state.passives,
                  constellations: state.constellations,
                  ascensionMaterials: state.ascensionMaterials,
                  talentAscensionsMaterials: state.talentAscensionsMaterials,
                  multiTalentAscensionMaterials: state.multiTalentAscensionMaterials,
                  builds: state.builds,
                )
              else
                BottomLandscapeLayout(
                  description: state.description,
                  elementType: state.elementType,
                  subStatType: state.subStatType,
                  stats: state.stats,
                  skills: state.skills,
                  passives: state.passives,
                  constellations: state.constellations,
                  ascensionMaterials: state.ascensionMaterials,
                  talentAscensionsMaterials: state.talentAscensionsMaterials,
                  multiTalentAscensionMaterials: state.multiTalentAscensionMaterials,
                  builds: state.builds,
                ),
            ],
          ),
          orElse: () => const Loading.column(),
        ),
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout();

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CharacterBloc, CharacterState>(
          builder: (context, state) => state.maybeMap(
            loaded: (state) => Row(
              children: [
                Expanded(
                  child: Top(
                    itemKey: state.key,
                    elementType: state.elementType,
                    name: state.name,
                    rarity: state.rarity,
                    region: state.region,
                    role: state.role,
                    weaponType: state.weaponType,
                    birthday: state.birthday,
                    fullImage: state.fullImage,
                    secondFullImage: state.secondFullImage,
                    isInInventory: state.isInInventory,
                  ),
                ),
                Expanded(
                  child: isPortrait
                      ? BottomPortraitLayout(
                          description: state.description,
                          elementType: state.elementType,
                          subStatType: state.subStatType,
                          stats: state.stats,
                          skills: state.skills,
                          passives: state.passives,
                          constellations: state.constellations,
                          ascensionMaterials: state.ascensionMaterials,
                          talentAscensionsMaterials: state.talentAscensionsMaterials,
                          multiTalentAscensionMaterials: state.multiTalentAscensionMaterials,
                          builds: state.builds,
                        )
                      : BottomLandscapeLayout(
                          description: state.description,
                          elementType: state.elementType,
                          subStatType: state.subStatType,
                          stats: state.stats,
                          skills: state.skills,
                          passives: state.passives,
                          constellations: state.constellations,
                          ascensionMaterials: state.ascensionMaterials,
                          talentAscensionsMaterials: state.talentAscensionsMaterials,
                          multiTalentAscensionMaterials: state.multiTalentAscensionMaterials,
                          builds: state.builds,
                        ),
                ),
              ],
            ),
            orElse: () => const Loading.column(),
          ),
        ),
      ),
    );
  }
}
