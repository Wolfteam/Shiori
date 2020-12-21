import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bloc.dart';
import '../../common/enums/element_type.dart';
import '../../common/enums/weapon_type.dart';
import '../../common/extensions/element_type_extensions.dart';
import '../../common/extensions/weapon_type_extensions.dart';
import '../../common/genshin_db_icons.dart';
import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../../models/models.dart';
import '../widgets/characters/character_build_card.dart';
import '../widgets/characters/character_detail.dart';
import '../widgets/common/element_image.dart';
import '../widgets/common/item_description.dart';
import '../widgets/common/item_description_detail.dart';
import '../widgets/common/loading.dart';
import '../widgets/common/rarity.dart';

class CharacterPage extends StatelessWidget {
  final double imgSize = 28;
  final double imgHeight = 550;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<CharacterBloc, CharacterState>(
            builder: (context, state) {
              return state.map(
                loading: (_) => const Loading(),
                loaded: (s) => Stack(
                  fit: StackFit.passthrough,
                  clipBehavior: Clip.none,
                  children: [
                    _buildTop(
                      s.name,
                      s.rarity,
                      s.fullImage,
                      s.secondFullImage,
                      s.elementType,
                      s.weaponType,
                      s.region,
                      s.role,
                      s.isFemale,
                      context,
                    ),
                    _buildBottom(
                      s.description,
                      s.elementType,
                      s.skills,
                      s.ascentionMaterials,
                      s.talentAscentionsMaterials,
                      s.multiTalentAscentionMaterials ?? [],
                      s.passives,
                      s.constellations,
                      s.builds,
                      context,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTop(
    String name,
    int rarity,
    String fullImage,
    String secondFullImage,
    ElementType elementType,
    WeaponType weaponType,
    String region,
    String role,
    bool isFemale,
    BuildContext context,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final descriptionWidth = mediaQuery.size.width / (isPortrait ? 1.2 : 2);
    //TODO: IM NOT SURE HOW THIS WILL LOOK LIKE IN BIGGER DEVICES
    // final padding = mediaQuery.padding;
    // final screenHeight = mediaQuery.size.height - padding.top - padding.bottom;

    return Container(
      color: elementType.getElementColorFromContext(context),
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Container(
              transform: Matrix4.translationValues(60, -30, 0.0),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  secondFullImage ?? fullImage,
                  width: 350,
                  height: imgHeight,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              fullImage,
              width: 340,
              height: imgHeight,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: descriptionWidth,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: _buildGeneralCard(name, rarity, elementType, weaponType, region, role, isFemale, context),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(backgroundColor: Colors.transparent, elevation: 0.0),
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(
    String description,
    ElementType elementType,
    List<TranslationCharacterSkillFile> skills,
    List<CharacterFileAscentionMaterialModel> ascentionMaterials,
    List<CharacterFileTalentAscentionMaterialModel> talentAscentionMaterials,
    List<CharacterFileMultiTalentAscentionMaterialModel> multiTalentAscentionMaterials,
    List<TranslationCharacterPassive> passives,
    List<TranslationCharacterConstellation> constellations,
    List<CharacterBuildCardModel> builds,
    BuildContext context,
  ) {
    final s = S.of(context);
    return Card(
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
                body: Container(margin: const EdgeInsets.symmetric(horizontal: 5), child: Text(description)),
                textColor: elementType.getElementColorFromContext(context),
              ),
            ),
            CharacterDetailSkillsCard(elementType: elementType, skills: skills),
            if (builds.isNotEmpty)
              ItemDescriptionDetail(
                title: s.builds,
                body: Column(
                  children: builds
                      .map((build) => CharacterBuildCard(
                            isForSupport: build.isForSupport,
                            elementType: elementType,
                            weapons: build.weapons,
                            artifacts: build.artifacts,
                          ))
                      .toList(),
                ),
                textColor: elementType.getElementColorFromContext(context),
              ),
            CharacterDetailAscentionMaterialsCard(ascentionMaterials: ascentionMaterials, elementType: elementType),
            if (talentAscentionMaterials.isNotEmpty)
              CharacterDetailTalentAscentionMaterialsCard.withTalents(
                talentAscentionMaterials: talentAscentionMaterials,
                elementType: elementType,
              ),
            if (multiTalentAscentionMaterials.isNotEmpty)
              CharacterDetailTalentAscentionMaterialsCard.withMultiTalents(
                multiTalentAscentionMaterials: multiTalentAscentionMaterials,
                elementType: elementType,
              ),
            CharacterDetailPassiveCard(elementType: elementType, passives: passives),
            CharacterDetailConstellationsCard(elementType: elementType, constellations: constellations),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralCard(
    String name,
    int rarity,
    ElementType elementType,
    WeaponType weaponType,
    String region,
    String role,
    bool isFemale,
    BuildContext context,
  ) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: theme.textTheme.headline5.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        Rarity(stars: rarity, starSize: 25, alignment: MainAxisAlignment.start),
        ItemDescription(
          title: s.element,
          widget: ElementImage.fromType(type: elementType, radius: 12, useDarkForBackgroundColor: true),
          useColumn: false,
        ),
        ItemDescription(
          title: s.region,
          widget: Text(
            region,
            style: const TextStyle(color: Colors.white),
          ),
          useColumn: false,
        ),
        ItemDescription(
          title: s.weapon,
          widget: Image.asset(weaponType.getWeaponAssetPath(), width: imgSize, height: imgSize),
          useColumn: false,
        ),
        ItemDescription(
          title: s.role,
          widget: Text(
            role,
            style: const TextStyle(color: Colors.white),
          ),
          useColumn: false,
        ),
        ItemDescription(
          title: s.gender,
          widget: Icon(isFemale ? GenshinDb.female : GenshinDb.male, color: isFemale ? Colors.pink : Colors.blue),
          useColumn: false,
        ),
      ],
    );
    return Card(
      color: elementType.getElementColorFromContext(context).withOpacity(0.1),
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(padding: Styles.edgeInsetAll10, child: details),
    );
  }
}
