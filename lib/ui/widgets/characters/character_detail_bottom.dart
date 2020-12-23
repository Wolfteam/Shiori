import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../common/item_description_detail.dart';
import '../common/loading.dart';
import 'character_build_card.dart';
import 'character_detail.dart';

class CharacterDetailBottom extends StatelessWidget {
  const CharacterDetailBottom({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => Card(
          margin: const EdgeInsets.only(top: 380, right: 10, left: 10),
          shape: Styles.cardItemDetailShape,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
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
                          .map((build) => CharacterBuildCard(
                                isForSupport: build.isForSupport,
                                elementType: state.elementType,
                                weapons: build.weapons,
                                artifacts: build.artifacts,
                              ))
                          .toList(),
                    ),
                    textColor: state.elementType.getElementColorFromContext(context),
                  ),
                CharacterDetailAscentionMaterialsCard(
                  ascentionMaterials: state.ascentionMaterials,
                  elementType: state.elementType,
                ),
                if (state.talentAscentionsMaterials.isNotEmpty)
                  CharacterDetailTalentAscentionMaterialsCard.withTalents(
                    talentAscentionMaterials: state.talentAscentionsMaterials,
                    elementType: state.elementType,
                  ),
                if (state.multiTalentAscentionMaterials != null && state.multiTalentAscentionMaterials.isNotEmpty)
                  CharacterDetailTalentAscentionMaterialsCard.withMultiTalents(
                    multiTalentAscentionMaterials: state.multiTalentAscentionMaterials,
                    elementType: state.elementType,
                  ),
                CharacterDetailPassiveCard(elementType: state.elementType, passives: state.passives),
                CharacterDetailConstellationsCard(elementType: state.elementType, constellations: state.constellations),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
