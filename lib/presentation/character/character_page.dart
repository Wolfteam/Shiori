import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/extensions/weapon_type_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/artifact/artifact_page.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/character_skill_priority.dart';
import 'package:shiori/presentation/shared/custom_divider.dart';
import 'package:shiori/presentation/shared/details/detail_landscape_content.dart';
import 'package:shiori/presentation/shared/details/detail_main_card.dart';
import 'package:shiori/presentation/shared/details/detail_main_content.dart';
import 'package:shiori/presentation/shared/details/detail_materials.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/details/detail_stats.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/images/artifact_image_type.dart';
import 'package:shiori/presentation/shared/images/element_image.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/row_column_item_or.dart';
import 'package:shiori/presentation/shared/scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/sub_stats_to_focus.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

part 'widgets/ascension_materials.dart';
part 'widgets/builds.dart';
part 'widgets/constellations.dart';
part 'widgets/description.dart';
part 'widgets/main.dart';
part 'widgets/passives.dart';
part 'widgets/skills.dart';
part 'widgets/talent_ascension_materials.dart';

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
    final s = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocProvider<CharacterBloc>(
      create: (context) => Injection.characterBloc..add(CharacterEvent.loadFromKey(key: itemKey)),
      child: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading.column(),
          loaded: (state) {
            final Color color = state.elementType.getElementColorFromContext(context);

            final main = _Main(
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
            );

            if (isPortrait) {
              return ScaffoldWithFab(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    main,
                    Padding(
                      padding: Styles.edgeInsetHorizontal5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Description(
                            color: color,
                            description: state.description,
                            subStatType: state.subStatType,
                            stats: state.stats,
                          ),
                          if (state.builds.isNotEmpty)
                            _Builds(
                              color: color,
                              elementType: state.elementType,
                              builds: state.builds,
                            ),
                          _Skills(
                            color: color,
                            skills: state.skills,
                          ),
                          _Passives(
                            color: color,
                            passives: state.passives,
                          ),
                          _Constellations(
                            color: color,
                            constellations: state.constellations,
                          ),
                          if (state.ascensionMaterials.isNotEmpty)
                            _AscensionMaterials(
                              color: color,
                              ascensionMaterials: state.ascensionMaterials,
                            ),
                          if (state.talentAscensionsMaterials.isNotEmpty)
                            _TalentAscensionMaterials(
                              color: color,
                              talentAscensionsMaterials: state.talentAscensionsMaterials,
                            ),
                          ...state.multiTalentAscensionMaterials.map(
                            (multi) => _TalentAscensionMaterials(
                              color: color,
                              talentAscensionsMaterials: multi.materials,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
            final tabs = [
              s.description,
              s.skills,
              s.passives,
              s.constellations,
              s.materials,
            ];
            return Scaffold(
              body: SafeArea(
                child: DetailLandscapeContent(
                  color: color,
                  tabs: tabs,
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Description.noButtons(
                            color: color,
                            description: state.description,
                            subStatType: state.subStatType,
                          ),
                          if (state.builds.isNotEmpty)
                            _Builds(
                              color: color,
                              elementType: state.elementType,
                              builds: state.builds,
                              expanded: true,
                            ),
                          StatsTable(
                            color: color,
                            stats: state.stats.map((e) => StatItem.character(e, state.subStatType, s)).toList(),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _Skills(
                        color: color,
                        skills: state.skills,
                        expanded: true,
                      ),
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _Passives(
                        color: color,
                        passives: state.passives,
                        expanded: true,
                      ),
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _Constellations(
                        color: color,
                        constellations: state.constellations,
                        expanded: true,
                      ),
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.ascensionMaterials.isNotEmpty)
                            _AscensionMaterials(
                              color: color,
                              ascensionMaterials: state.ascensionMaterials,
                            ),
                          if (state.talentAscensionsMaterials.isNotEmpty)
                            _TalentAscensionMaterials(
                              color: color,
                              talentAscensionsMaterials: state.talentAscensionsMaterials,
                            ),
                          ...state.multiTalentAscensionMaterials.map(
                            (multi) => _TalentAscensionMaterials(
                              color: color,
                              talentAscensionsMaterials: multi.materials,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
