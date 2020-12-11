import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bloc.dart';
import '../../common/enums/element_type.dart';
import '../../common/enums/weapon_type.dart';
import '../../common/extensions/element_type_extensions.dart';
import '../../common/extensions/weapon_type_extensions.dart';
import '../../common/styles.dart';
import '../../models/models.dart';
import '../widgets/characters/character_detail.dart';
import '../widgets/common/item_description.dart';
import '../widgets/common/item_description_detail.dart';
import '../widgets/common/loading.dart';
import '../widgets/common/rarity.dart';

class CharacterPage extends StatelessWidget {
  final double imgSize = 20;
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
      color: elementType.getElementColor(),
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
              margin: EdgeInsets.symmetric(horizontal: 30),
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
    BuildContext context,
  ) {
    return Card(
      margin: EdgeInsets.only(top: 380, right: 10, left: 10),
      shape: Styles.cardItemDetailShape,
      child: Padding(
        padding: EdgeInsets.only(top: 10, right: 10, left: 10),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: ItemDescriptionDetail(
                title: 'Description',
                body: Container(margin: EdgeInsets.symmetric(horizontal: 5), child: Text(description)),
                icon: Icon(Icons.settings),
              ),
            ),
            CharacterDetailSkillsCard(elementType: elementType, skills: skills),
            CharacterDetailAscentionMaterialsCard(ascentionMaterials: ascentionMaterials),
            if (talentAscentionMaterials.isNotEmpty)
              CharacterDetailTalentAscentionMaterialsCard.withTalents(
                talentAscentionMaterials: talentAscentionMaterials,
              ),
            if (multiTalentAscentionMaterials.isNotEmpty)
              CharacterDetailTalentAscentionMaterialsCard.withMultiTalents(
                multiTalentAscentionMaterials: multiTalentAscentionMaterials,
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
    final theme = Theme.of(context);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: theme.textTheme.headline5.copyWith(fontWeight: FontWeight.bold)),
        ItemDescription(title: 'Rarity', widget: Rarity(stars: rarity), useColumn: false),
        ItemDescription(
          title: 'Element',
          widget: Image.asset(elementType.getElementAsssetPath(), width: imgSize, height: imgSize),
          useColumn: false,
        ),
        ItemDescription(title: 'Region', widget: Text(region), useColumn: false),
        ItemDescription(
          title: 'Weapon',
          widget: Image.asset(weaponType.getWeaponAssetPath(), width: imgSize, height: imgSize),
          useColumn: false,
        ),
        ItemDescription(title: 'Role', widget: Text(role), useColumn: false),
        ItemDescription(title: 'Gender', widget: Text(isFemale ? 'Female' : 'Male'), useColumn: false),
      ],
    );
    return Card(
      color: Colors.amber.withOpacity(0.1),
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(padding: Styles.edgeInsetAll10, child: details),
    );
  }
}
