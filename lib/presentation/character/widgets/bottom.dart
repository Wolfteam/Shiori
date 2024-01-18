import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/character/widgets/builds.dart';
import 'package:shiori/presentation/character/widgets/constellations.dart';
import 'package:shiori/presentation/character/widgets/description.dart';
import 'package:shiori/presentation/character/widgets/passives.dart';
import 'package:shiori/presentation/character/widgets/skills.dart';
import 'package:shiori/presentation/shared/details/detail_materials.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/details/detail_stats.dart';
import 'package:shiori/presentation/shared/details/detail_tab_landscape_layout.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

class BottomPortraitLayout extends StatelessWidget {
  final String description;
  final ElementType elementType;
  final StatType subStatType;
  final List<CharacterFileStatModel> stats;
  final List<CharacterSkillCardModel> skills;
  final List<CharacterPassiveTalentModel> passives;
  final List<CharacterConstellationModel> constellations;
  final List<CharacterAscensionModel> ascensionMaterials;
  final List<CharacterTalentAscensionModel> talentAscensionsMaterials;
  final List<CharacterMultiTalentAscensionModel> multiTalentAscensionMaterials;
  final List<CharacterBuildCardModel> builds;

  const BottomPortraitLayout({
    required this.description,
    required this.elementType,
    required this.subStatType,
    required this.stats,
    required this.skills,
    required this.passives,
    required this.constellations,
    required this.ascensionMaterials,
    required this.talentAscensionsMaterials,
    required this.multiTalentAscensionMaterials,
    required this.builds,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = elementType.getElementColorFromContext(context);
    return Padding(
      padding: Styles.edgeInsetHorizontal5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Description(
            color: color,
            description: description,
            subStatType: subStatType,
            stats: stats,
            ascensionMaterials: ascensionMaterials,
            talentAscensionsMaterials: talentAscensionsMaterials,
            multiTalentAscensionMaterials: multiTalentAscensionMaterials,
          ),
          if (builds.isNotEmpty)
            Builds(
              color: color,
              elementType: elementType,
              builds: builds,
            ),
          Skills(
            color: color,
            skills: skills,
          ),
          Passives(
            color: color,
            passives: passives,
          ),
          Constellations(
            color: color,
            constellations: constellations,
          ),
        ],
      ),
    );
  }
}

class BottomLandscapeLayout extends StatelessWidget {
  final String description;
  final ElementType elementType;
  final StatType subStatType;
  final List<CharacterFileStatModel> stats;
  final List<CharacterSkillCardModel> skills;
  final List<CharacterPassiveTalentModel> passives;
  final List<CharacterConstellationModel> constellations;
  final List<CharacterAscensionModel> ascensionMaterials;
  final List<CharacterTalentAscensionModel> talentAscensionsMaterials;
  final List<CharacterMultiTalentAscensionModel> multiTalentAscensionMaterials;
  final List<CharacterBuildCardModel> builds;

  const BottomLandscapeLayout({
    required this.description,
    required this.elementType,
    required this.subStatType,
    required this.stats,
    required this.skills,
    required this.passives,
    required this.constellations,
    required this.ascensionMaterials,
    required this.talentAscensionsMaterials,
    required this.multiTalentAscensionMaterials,
    required this.builds,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final tabs = [
      s.description,
      s.skills,
      s.passives,
      s.constellations,
      s.materials,
    ];
    final Color color = elementType.getElementColorFromContext(context);
    return DetailTabLandscapeLayout(
      color: color,
      tabs: tabs,
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Description.noButtons(
                color: color,
                description: description,
                subStatType: subStatType,
              ),
              if (builds.isNotEmpty)
                Builds(
                  color: color,
                  elementType: elementType,
                  builds: builds,
                  expanded: true,
                ),
              StatsTable(
                color: color,
                stats: stats.map((e) => StatItem.forCharacter(e, subStatType)).toList(),
                mainSubStatType: subStatType,
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Skills(
            color: color,
            skills: skills,
            expanded: true,
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Passives(
            color: color,
            passives: passives,
            expanded: true,
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Constellations(
            color: color,
            constellations: constellations,
            expanded: true,
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (ascensionMaterials.isNotEmpty)
                DetailSection.complex(
                  title: s.ascensionMaterials,
                  color: color,
                  children: ListTile.divideTiles(
                    context: context,
                    color: color,
                    tiles: ascensionMaterials.map(
                      (e) => AscensionMaterialsListTile(data: MaterialsData.fromAscensionMaterial(e)),
                    ),
                  ).toList(),
                ),
              if (talentAscensionsMaterials.isNotEmpty)
                DetailSection.complex(
                  title: s.talentsAscension,
                  color: color,
                  children: ListTile.divideTiles(
                    context: context,
                    color: color,
                    tiles: talentAscensionsMaterials.map(
                      (e) => AscensionMaterialsListTile(data: MaterialsData.fromTalentAscensionMaterial(e)),
                    ),
                  ).toList(),
                ),
              if (multiTalentAscensionMaterials.isNotEmpty)
                ...multiTalentAscensionMaterials.map(
                  (multi) => DetailSection.complex(
                    title: s.talentAscensionX(multi.number),
                    color: color,
                    children: ListTile.divideTiles(
                      context: context,
                      color: color,
                      tiles: multi.materials.map(
                        (e) => AscensionMaterialsListTile(data: MaterialsData.fromTalentAscensionMaterial(e)),
                      ),
                    ).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

//TODO: USE CUSTOM WIDGETS FOR EXPANSION TILE + BODY
//TODO: REMOVE LINE BREAK AT THE END OF STRING IN TILE BODY
//TODO: FAB COLOR
//TODO: USE SAME COLOR ON STAT, DETAILS DIALOGS
//TODO: USE TITLES ON ALL DIALOGS
