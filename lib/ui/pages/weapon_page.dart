import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bloc.dart';
import '../../common/enums/item_location_type.dart';
import '../../common/enums/stat_type.dart';
import '../../common/enums/weapon_type.dart';
import '../../common/extensions/i18n_extensions.dart';
import '../../common/extensions/rarity_extensions.dart';
import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../../models/models.dart';
import '../widgets/common/item_description.dart';
import '../widgets/common/item_description_detail.dart';
import '../widgets/common/loading.dart';
import '../widgets/common/rarity.dart';
import '../widgets/weapons/weapon_detail_ascention_materials_card.dart';
import '../widgets/weapons/weapon_detail_refinements_card.dart';

class WeaponPage extends StatelessWidget {
  final double imageHeight = 320;
  final double imgSize = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<WeaponBloc, WeaponState>(
            builder: (context, state) {
              return state.map(
                loading: (_) => const Loading(),
                loaded: (s) => Stack(
                  children: [
                    _buildTop(
                      s.name,
                      s.atk,
                      s.rarity,
                      s.secondaryStat,
                      s.secondaryStatValue,
                      s.weaponType,
                      s.locationType,
                      s.fullImage,
                      context,
                    ),
                    _buildBottom(s.description, s.ascentionMaterials, s.refinements, context),
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
    int atk,
    int rarity,
    StatType secondaryStatType,
    double secondaryStatValue,
    WeaponType type,
    ItemLocationType locationType,
    String image,
    BuildContext context,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final descriptionWidth = mediaQuery.size.width / (isPortrait ? 1.2 : 2);
    //TODO: IM NOT SURE HOW THIS WILL LOOK LIKE IN BIGGER DEVICES
    // final padding = mediaQuery.padding;
    // final screenHeight = mediaQuery.size.height - padding.top - padding.bottom;

    return Container(
      decoration: BoxDecoration(gradient: rarity.getRarityGradient()),
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Container(
              transform: Matrix4.translationValues(80, -30, 0.0),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  image,
                  width: 350,
                  height: imageHeight,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              image,
              width: 340,
              height: imageHeight,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: descriptionWidth,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: _buildGeneralCard(
                name,
                atk,
                rarity,
                secondaryStatType,
                secondaryStatValue,
                type,
                locationType,
                context,
              ),
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
    List<WeaponFileAscentionMaterial> ascentionMaterials,
    List<WeaponFileRefinementModel> refinements,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(top: 280, right: 10, left: 10),
      shape: Styles.cardItemDetailShape,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
        child: Column(
          children: [
            _buildDescription(description, context),
            if (ascentionMaterials.isNotEmpty)
              WeaponDetailAscentionMaterialsCard(ascentionMaterials: ascentionMaterials),
            if (refinements.isNotEmpty) WeaponDetailRefinementsCard(refinements: refinements),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralCard(
    String name,
    int atk,
    int rarity,
    StatType statType,
    double secondaryStatValue,
    WeaponType type,
    ItemLocationType locationType,
    BuildContext context,
  ) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.headline5.copyWith(fontWeight: FontWeight.bold),
        ),
        ItemDescription(title: s.rarity, widget: Rarity(stars: rarity), useColumn: false),
        ItemDescription(title: s.type, widget: Text(s.translateWeaponType(type)), useColumn: false),
        ItemDescription(title: s.baseAtk, widget: Text('$atk'), useColumn: false),
        ItemDescription(
            title: s.secondaryState, widget: Text(s.translateStatType(statType, secondaryStatValue)), useColumn: false),
        ItemDescription(title: s.location, widget: Text(s.translateItemLocationType(locationType)), useColumn: false),
      ],
    );

    return Card(
      color: Colors.amber.withOpacity(0.1),
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll10,
      shape: Styles.cardShape,
      child: Padding(padding: Styles.edgeInsetAll10, child: details),
    );
  }

  Widget _buildDescription(String description, BuildContext context) {
    final s = S.of(context);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ItemDescriptionDetail(
            title: s.description,
            body: Container(margin: const EdgeInsets.symmetric(horizontal: 5), child: Text(description)),
            icon: Icon(Icons.settings),
          ),
        ),
        // ItemDescription(
        //   title: 'Special (Passive) Ability',
        //   subTitle:
        //       'Hitting enemies with Normal and Charged Attacks grants a 50% chance to deal 200% ATK as DMG in a small AoE. This effect can only occur once every 10s. Additionally, if the Traveler equips the Sword of Descension, their ATK is increased by 66',
        // ),
        // ItemDescription(
        //   title: 'Special (Passive) Ability Description',
        //   subTitle: 'A sword of unique craftsmanship. It does not appear to belong to this world.',
        // ),
      ],
    );
    return body;
  }
}
