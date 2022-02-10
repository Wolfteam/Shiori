import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/character/widgets/character_detail.dart';
import 'package:shiori/presentation/shared/details/detail_bottom_portrait_layout.dart';
import 'package:shiori/presentation/shared/details/detail_tab_landscape_layout.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/loading.dart';

import 'character_detail.dart';

class CharacterDetailBottom extends StatelessWidget {
  const CharacterDetailBottom({Key? key}) : super(key: key);

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
    final s = S.of(context);
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => DetailBottomPortraitLayout(
          isAnSmallImage: false,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ItemDescriptionDetail(
                title: s.description,
                body: Container(margin: const EdgeInsets.symmetric(horizontal: 5), child: Text(state.description)),
                textColor: state.elementType.getElementColorFromContext(context),
              ),
            ),
            CharacterDetailSkillsCard(elementType: state.elementType, skills: state.skills),
            if (state.builds.isNotEmpty)
              ItemDescriptionDetail(
                title: s.builds,
                body: Column(
                  children: state.builds
                      .map(
                        (build) => CharacterDetailBuildCard(
                          isRecommended: build.isRecommended,
                          type: build.type,
                          subType: build.subType,
                          skillPriorities: build.skillPriorities,
                          elementType: state.elementType,
                          weapons: build.weapons,
                          artifacts: build.artifacts,
                          subStatsToFocus: build.subStatsToFocus,
                          isCustomBuild: build.isCustomBuild,
                        ),
                      )
                      .toList(),
                ),
                textColor: state.elementType.getElementColorFromContext(context),
              ),
            CharacterDetailAscensionMaterialsCard(
              ascensionMaterials: state.ascensionMaterials,
              elementType: state.elementType,
            ),
            if (state.talentAscensionsMaterials.isNotEmpty)
              CharacterDetailTalentAscensionMaterialsCard.withTalents(
                talentAscensionMaterials: state.talentAscensionsMaterials,
                elementType: state.elementType,
              ),
            if (state.multiTalentAscensionMaterials.isNotEmpty)
              CharacterDetailTalentAscensionMaterialsCard.withMultiTalents(
                multiTalentAscensionMaterials: state.multiTalentAscensionMaterials,
                elementType: state.elementType,
              ),
            CharacterDetailPassiveCard(elementType: state.elementType, passives: state.passives),
            CharacterDetailConstellationsCard(elementType: state.elementType, constellations: state.constellations),
            if (state.stats.isNotEmpty)
              CharacterDetailStatsCard(
                elementType: state.elementType,
                stats: state.stats,
                subStatType: state.subStatType,
              ),
          ],
        ),
      ),
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final tabs = [
      s.description,
      s.passives,
      s.constellations,
      s.materials,
      s.builds,
      s.stats,
    ];
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(),
        loaded: (state) => DetailTabLandscapeLayout(
          color: state.elementType.getElementColorFromContext(context),
          tabs: tabs,
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ItemDescriptionDetail(
                      title: s.description,
                      body: Container(margin: const EdgeInsets.symmetric(horizontal: 5), child: Text(state.description)),
                      textColor: state.elementType.getElementColorFromContext(context),
                    ),
                  ),
                  CharacterDetailSkillsCard(elementType: state.elementType, skills: state.skills),
                ],
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: CharacterDetailPassiveCard(elementType: state.elementType, passives: state.passives),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: CharacterDetailConstellationsCard(
                elementType: state.elementType,
                constellations: state.constellations,
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CharacterDetailAscensionMaterialsCard(
                    ascensionMaterials: state.ascensionMaterials,
                    elementType: state.elementType,
                  ),
                  CharacterDetailTalentAscensionMaterialsCard.withTalents(
                    talentAscensionMaterials: state.talentAscensionsMaterials,
                    elementType: state.elementType,
                  ),
                  if (state.multiTalentAscensionMaterials.isNotEmpty)
                    CharacterDetailTalentAscensionMaterialsCard.withMultiTalents(
                      multiTalentAscensionMaterials: state.multiTalentAscensionMaterials,
                      elementType: state.elementType,
                    ),
                ],
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ItemDescriptionDetail(
                title: s.builds,
                body: Column(
                  children: state.builds
                      .map(
                        (build) => CharacterDetailBuildCard(
                          isRecommended: build.isRecommended,
                          type: build.type,
                          subType: build.subType,
                          skillPriorities: build.skillPriorities,
                          elementType: state.elementType,
                          weapons: build.weapons,
                          artifacts: build.artifacts,
                          subStatsToFocus: build.subStatsToFocus,
                          isCustomBuild: build.isCustomBuild,
                        ),
                      )
                      .toList(),
                ),
                textColor: state.elementType.getElementColorFromContext(context),
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: CharacterDetailStatsCard(
                elementType: state.elementType,
                stats: state.stats,
                subStatType: state.subStatType,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
