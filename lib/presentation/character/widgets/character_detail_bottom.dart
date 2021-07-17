import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/element_type.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/character/widgets/character_detail.dart';
import 'package:genshindb/presentation/character/widgets/character_detail_skills_card.dart';
import 'package:genshindb/presentation/shared/extensions/element_type_extensions.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'character_detail.dart';

// final height = MediaQuery.of(context).size.height;
//
// // Height (without SafeArea)
// var padding = MediaQuery.of(context).padding;
// double height1 = height - padding.top - padding.bottom;
// // Height (without status bar)
// double height2 = height - padding.top;
// // Height (without status and toolbar)
// double height3 = height - padding.top - kToolbarHeight;

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
    final size = MediaQuery.of(context).size;
    final maxTopHeight = (getTopHeightForPortrait(context) / 2) + (charDescriptionHeight / 1.8);
    final device = getDeviceType(size);
    final width = size.width * (device == DeviceScreenType.mobile ? 0.9 : 0.8);
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => SizedBox(
          width: width,
          child: Card(
            margin: EdgeInsets.only(top: maxTopHeight),
            shape: Styles.cardItemDetailShape,
            child: Padding(
              padding: Styles.edgeInsetAll10,
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
                  if (state.builds.isNotEmpty)
                    ItemDescriptionDetail(
                      title: s.builds,
                      body: Column(
                        children: state.builds
                            .map((build) => CharacterDetailBuildCard(
                                  isForSupport: build.isForSupport,
                                  elementType: state.elementType,
                                  weapons: build.weapons,
                                  artifacts: build.artifacts,
                                  subStatsToFocus: build.subStatsToFocus,
                                ))
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
                  if (state.multiTalentAscensionMaterials != null && state.multiTalentAscensionMaterials!.isNotEmpty)
                    CharacterDetailTalentAscensionMaterialsCard.withMultiTalents(
                      multiTalentAscensionMaterials: state.multiTalentAscensionMaterials!,
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
          ),
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
    final tabColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(),
        loaded: (state) {
          return DefaultTabController(
            length: 6,
            //had to use a container to keep the background color on the system bar
            child: Container(
              color: state.elementType.getElementColorFromContext(context),
              padding: const EdgeInsets.only(right: 20),
              child: SafeArea(
                child: Scaffold(
                  appBar: AppBar(
                    toolbarHeight: 50,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.pink,
                    shadowColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    flexibleSpace: TabBar(
                      physics: const BouncingScrollPhysics(),
                      indicatorColor: state.elementType.getElementColorFromContext(context),
                      isScrollable: true,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 30),
                      labelColor: tabColor,
                      tabs: [
                        Tab(text: s.skills),
                        Tab(text: s.passives),
                        Tab(text: s.constellations),
                        Tab(text: s.materials),
                        Tab(text: s.builds),
                        Tab(text: s.stats),
                      ],
                    ),
                  ),
                  body: _LandscapeTabView(
                    description: state.description,
                    elementType: state.elementType,
                    subStatType: state.subStatType,
                    ascensionMaterials: state.ascensionMaterials,
                    talentAscensionsMaterials: state.talentAscensionsMaterials,
                    multiTalentAscensionMaterials: state.multiTalentAscensionMaterials ?? [],
                    constellations: state.constellations,
                    passives: state.passives,
                    skills: state.skills,
                    builds: state.builds,
                    stats: state.stats,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LandscapeTabView extends StatelessWidget {
  final ElementType elementType;
  final StatType subStatType;
  final String description;
  final List<CharacterSkillCardModel> skills;
  final List<CharacterPassiveTalentModel> passives;
  final List<CharacterConstellationModel> constellations;
  final List<CharacterFileAscensionMaterialModel> ascensionMaterials;
  final List<CharacterFileTalentAscensionMaterialModel> talentAscensionsMaterials;
  final List<CharacterFileMultiTalentAscensionMaterialModel> multiTalentAscensionMaterials;
  final List<CharacterBuildCardModel> builds;
  final List<CharacterFileStatModel> stats;
  final EdgeInsets padding;

  const _LandscapeTabView({
    Key? key,
    required this.elementType,
    required this.subStatType,
    required this.description,
    required this.skills,
    required this.passives,
    required this.constellations,
    required this.ascensionMaterials,
    required this.talentAscensionsMaterials,
    this.multiTalentAscensionMaterials = const [],
    required this.builds,
    required this.stats,
    this.padding = const EdgeInsets.symmetric(horizontal: 25),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: padding,
      child: TabBarView(
        physics: const BouncingScrollPhysics(),
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ItemDescriptionDetail(
                    title: s.description,
                    body: Container(margin: const EdgeInsets.symmetric(horizontal: 5), child: Text(description)),
                    textColor: elementType.getElementColorFromContext(context),
                  ),
                ),
                CharacterDetailSkillsCard(elementType: elementType, skills: skills),
              ],
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: CharacterDetailPassiveCard(elementType: elementType, passives: passives),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: CharacterDetailConstellationsCard(
              elementType: elementType,
              constellations: constellations,
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CharacterDetailAscensionMaterialsCard(
                  ascensionMaterials: ascensionMaterials,
                  elementType: elementType,
                ),
                CharacterDetailTalentAscensionMaterialsCard.withTalents(
                  talentAscensionMaterials: talentAscensionsMaterials,
                  elementType: elementType,
                ),
                if (multiTalentAscensionMaterials.isNotEmpty)
                  CharacterDetailTalentAscensionMaterialsCard.withMultiTalents(
                    multiTalentAscensionMaterials: multiTalentAscensionMaterials,
                    elementType: elementType,
                  ),
              ],
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ItemDescriptionDetail(
              title: s.builds,
              body: Column(
                children: builds
                    .map((build) => CharacterDetailBuildCard(
                          isForSupport: build.isForSupport,
                          elementType: elementType,
                          weapons: build.weapons,
                          artifacts: build.artifacts,
                          subStatsToFocus: build.subStatsToFocus,
                        ))
                    .toList(),
              ),
              textColor: elementType.getElementColorFromContext(context),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: CharacterDetailStatsCard(
              elementType: elementType,
              stats: stats,
              subStatType: subStatType,
            ),
          ),
        ],
      ),
    );
  }
}
