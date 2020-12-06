import 'package:flutter/material.dart';

import '../../common/enums/weapon_type.dart';
import '../../common/extensions/rarity_extensions.dart';
import '../../common/styles.dart';
import '../../models/models.dart';
import '../../models/weapons/weapon_ascention_model.dart';
import '../widgets/common/item_description.dart';
import '../widgets/common/item_description_detail.dart';
import '../widgets/common/rarity.dart';
import '../widgets/common/wrapped_ascention_material.dart';

class WeaponPage extends StatelessWidget {
  final double imageHeight = 320;
  final name = 'Sword of Descension';
  final type = WeaponType.catalyst;
  final image = 'assets/weapons/swords/sword_of_descension.png';
  final rarity = 5;
  final baseAtk = 42;
  final secodanryStat = 'ATK %';
  final secondaryStatValue = 12;
  final description =
      "Hitting enemies with Normal and Charged Attacks grants a 50% chance to deal 200% ATK as DMG in a small AoE. This effect can only occur once every 10s. Additionally, if the Traveler equips the Sword of Descension, their ATK is increased by 66.";
  final location = 'Gacha';
  final double imgSize = 20;

  final ascentionMaterials = <WeaponAscentionModel>[
    // WeaponAscentionModel(
    //   level: 20,
    //   materials: [
    //     ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
    //     ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
    //     ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
    //     ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
    //   ],
    // ),
    // WeaponAscentionModel(
    //   level: 40,
    //   materials: [
    //     ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
    //     ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
    //     ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
    //     ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
    //   ],
    // ),
    // WeaponAscentionModel(
    //   level: 60,
    //   materials: [
    //     ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
    //     ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
    //     ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
    //     ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
    //   ],
    // ),
    // WeaponAscentionModel(
    //   level: 80,
    //   materials: [
    //     ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
    //     ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
    //     ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
    //     ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
    //   ],
    // ),
    // WeaponAscentionModel(
    //   level: 90,
    //   materials: [
    //     ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
    //     ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
    //     ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
    //     ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
    //   ],
    // ),
    // WeaponAscentionModel(
    //   level: 100,
    //   materials: [
    //     ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
    //     ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
    //     ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
    //     ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
    //   ],
    // ),
  ];

  final refinements = {
    1: 'Hitting enemies with Normal and Charged Attacks grants a 50% chance to deal.',
    2: 'Hitting enemies with Normal and Charged Attacks grants a 55% chance to deal.',
    3: 'Hitting enemies with Normal and Charged Attacks grants a 60% chance to deal.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              _buildTop(context),
              _buildBottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop(BuildContext context) {
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
              transform: Matrix4.translationValues(60, -30, 0.0),
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
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: _buildGeneralCard(context),
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

  Widget _buildBottom() {
    return Card(
      margin: EdgeInsets.only(top: 250, right: 10, left: 10),
      shape: Styles.cardItemDetailShape,
      child: Padding(
        padding: EdgeInsets.only(top: 10, right: 10, left: 10),
        child: Column(
          children: [
            _buildDescription(),
            _buildStatProgressionCard(),
            _buildRefinementsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralCard(BuildContext context) {
    final theme = Theme.of(context);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.headline5.copyWith(fontWeight: FontWeight.bold),
        ),
        ItemDescription(title: 'Rarity', widget: Rarity(stars: rarity), useColumn: false),
        ItemDescription(title: 'Type', widget: Text('$type'), useColumn: false),
        ItemDescription(title: 'Base Atk', widget: Text('$baseAtk'), useColumn: false),
        ItemDescription(title: 'Secondary Stat', widget: Text('$secondaryStatValue $secodanryStat'), useColumn: false),
        ItemDescription(title: 'Location', widget: Text(location), useColumn: false),
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

  Widget _buildDescription() {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: ItemDescriptionDetail(
            title: 'Description',
            body: Container(margin: EdgeInsets.symmetric(horizontal: 5), child: Text(description)),
            icon: Icon(Icons.settings),
          ),
        ),
        ItemDescription(
          title: 'Special (Passive) Ability',
          subTitle:
              'Hitting enemies with Normal and Charged Attacks grants a 50% chance to deal 200% ATK as DMG in a small AoE. This effect can only occur once every 10s. Additionally, if the Traveler equips the Sword of Descension, their ATK is increased by 66',
        ),
        ItemDescription(
          title: 'Special (Passive) Ability Description',
          subTitle: 'A sword of unique craftsmanship. It does not appear to belong to this world.',
        ),
      ],
    );
    return body;
  }

  TableRow _buildStatProgressionRow(WeaponAscentionModel model) {
    final materials =
        model.materials.map((m) => WrappedAscentionMaterial(image: m.image, quantity: m.quantity)).toList();
    return TableRow(children: [
      Padding(
        padding: Styles.edgeInsetAll10,
        child: Center(child: Text('${model.level}')),
      ),
      Center(
        child: Padding(
          padding: Styles.edgeInsetVertical5,
          child: Wrap(children: materials),
        ),
      ),
    ]);
  }

  Widget _buildStatProgressionCard() {
    final body = Card(
      elevation: Styles.cardTenElevation,
      shape: Styles.cardShape,
      margin: Styles.edgeInsetAll5,
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.2),
          1: FractionColumnWidth(.8),
        },
        children: [
          TableRow(
            children: [
              Padding(
                padding: Styles.edgeInsetAll10,
                child: Center(child: Text('Level')),
              ),
              Padding(
                padding: Styles.edgeInsetAll10,
                child: Center(child: Text('Materials')),
              ),
            ],
          ),
          ...ascentionMaterials.map((e) => _buildStatProgressionRow(e)).toList(),
        ],
      ),
    );
    return ItemDescriptionDetail(title: 'Ascention Materials', icon: Icon(Icons.settings), body: body);
  }

  Widget _buildRefinementsCard() {
    final rows = refinements.entries
        .map(
          (kvp) => TableRow(
            children: [
              Padding(
                padding: Styles.edgeInsetAll10,
                child: Center(child: Text('${kvp.key}')),
              ),
              Center(
                child: Padding(
                  padding: Styles.edgeInsetVertical5,
                  child: Center(child: Text('${kvp.value}')),
                ),
              ),
            ],
          ),
        )
        .toList();

    final body = Card(
      elevation: Styles.cardTenElevation,
      shape: Styles.cardShape,
      margin: Styles.edgeInsetAll5,
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.2),
          1: FractionColumnWidth(.8),
        },
        children: [
          TableRow(
            children: [
              Padding(
                padding: Styles.edgeInsetAll10,
                child: Center(child: Text('Level')),
              ),
              Padding(
                padding: Styles.edgeInsetAll10,
                child: Center(child: Text('Description')),
              ),
            ],
          ),
          ...rows,
        ],
      ),
    );

    return ItemDescriptionDetail(title: 'Refinements', icon: Icon(Icons.settings), body: body);
  }
}
