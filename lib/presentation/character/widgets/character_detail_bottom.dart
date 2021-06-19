import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/element_type_extensions.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'character_detail.dart';

class CharacterDetailBottom extends StatelessWidget {
  const CharacterDetailBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => Card(
          margin: const EdgeInsets.only(top: 400, right: 10, left: 10),
          shape: Styles.cardItemDetailShape,
          child: Padding(
            padding: Styles.edgeInsetAll10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
    );
  }
}
