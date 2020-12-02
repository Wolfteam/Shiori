import 'package:flutter/material.dart';

import '../../common/enums/weapon_type.dart';
import '../../common/styles.dart';
import '../../models/models.dart';
import '../../models/weapons/weapon_ascention_model.dart';
import '../widgets/common/item_description.dart';
import '../widgets/common/item_description_card.dart';
import '../widgets/common/item_expansion_panel.dart';
import '../widgets/common/rarity.dart';
import '../widgets/common/wrapped_ascention_material.dart';

class WeaponPage extends StatelessWidget {
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
    WeaponAscentionModel(
      level: 20,
      materials: [
        ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
        ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
        ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
        ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
      ],
    ),
    WeaponAscentionModel(
      level: 40,
      materials: [
        ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
        ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
        ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
        ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
      ],
    ),
    WeaponAscentionModel(
      level: 60,
      materials: [
        ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
        ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
        ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
        ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
      ],
    ),
    WeaponAscentionModel(
      level: 80,
      materials: [
        ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
        ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
        ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
        ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
      ],
    ),
    WeaponAscentionModel(
      level: 90,
      materials: [
        ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
        ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
        ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
        ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
      ],
    ),
    WeaponAscentionModel(
      level: 100,
      materials: [
        ItemAscentionMaterialModel(imagePath: 'damaged_mask.png', quantity: 3),
        ItemAscentionMaterialModel(imagePath: 'shimmering_nectar.png', quantity: 2),
        ItemAscentionMaterialModel(imagePath: 'crown_of_sagehood.png', quantity: 8),
        ItemAscentionMaterialModel(imagePath: 'mora.png', quantity: 30000),
      ],
    ),
  ];

  final refinements = {
    1: 'Hitting enemies with Normal and Charged Attacks grants a 50% chance to deal.',
    2: 'Hitting enemies with Normal and Charged Attacks grants a 55% chance to deal.',
    3: 'Hitting enemies with Normal and Charged Attacks grants a 60% chance to deal.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Styles.edgeInsetAll5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGeneralCard(),
              _buildDescription(),
              _buildStatProgressionCard(),
              _buildRefinementsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralCard() {
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ItemDescription(title: 'Rarity', widget: Rarity(stars: rarity), useColumn: false),
        ItemDescription(title: 'Type', widget: Text('$type'), useColumn: false),
        ItemDescription(title: 'Base Atk', widget: Text('$baseAtk'), useColumn: false),
        ItemDescription(title: 'Secondary Stat', widget: Text('$secondaryStatValue $secodanryStat'), useColumn: false),
        ItemDescription(title: 'Location', widget: Text(location), useColumn: false),
      ],
    );
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        Card(
          elevation: Styles.cardTenElevation,
          margin: Styles.edgeInsetAll10,
          shape: Styles.cardShape,
          child: Padding(padding: Styles.edgeInsetAll10, child: details),
        ),
        Image.asset(image, alignment: Alignment.topRight, height: 220, width: 100),
      ],
    );
  }

  Widget _buildDescription() {
    final extras = [
      ItemDescription(
        title: 'Special (Passive) Ability',
        subTitle:
            'Hitting enemies with Normal and Charged Attacks grants a 50% chance to deal 200% ATK as DMG in a small AoE. This effect can only occur once every 10s. Additionally, if the Traveler equips the Sword of Descension, their ATK is increased by 66',
      ),
      ItemDescription(
        title: 'Special (Passive) Ability Description',
        subTitle: 'A sword of unique craftsmanship. It does not appear to belong to this world.',
      ),
    ];
    return ItemDescriptionCard(description: description, widgets: extras);
  }

  TableRow _buildStatProgressionRow(WeaponAscentionModel model) {
    final materials = model.materials
        .map((m) => WrappedAscentionMaterial(image: 'assets/items/${m.imagePath}', quantity: m.quantity))
        .toList();
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
      margin: Styles.edgeInsetAll10,
      shape: Styles.cardShape,
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

    return ItemExpansionPanel(title: 'Ascention Materials', body: body);
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
      margin: Styles.edgeInsetAll10,
      shape: Styles.cardShape,
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

    return ItemExpansionPanel(title: 'Refinements', body: body);
  }
}
