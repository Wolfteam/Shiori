import 'dart:ui';

import 'package:flutter/material.dart';

import '../../common/enums/element_type.dart';
import '../../common/enums/weapon_type.dart';
import '../../common/extensions/element_type_extensions.dart';
import '../../common/extensions/iterable_extensions.dart';
import '../../common/extensions/weapon_type_extensions.dart';
import '../../common/styles.dart';
import '../../models/characters/character_ascention_model.dart';
import '../../models/items/item_ascention_material_model.dart';
import '../../models/models.dart';
import '../widgets/common/item_description.dart';
import '../widgets/common/item_description_detail.dart';
import '../widgets/common/rarity.dart';
import '../widgets/common/wrapped_ascention_material.dart';

class CharacterPage extends StatelessWidget {
  final double imgSize = 20;
  final double imgHeight = 550;
  final fullImgPath = 'assets/characters/Keqing_full.png';
  final description =
      "The Yuheng of the Liyue Qixing. Has much to say about Rex Lapis' unilateral approach to policymaking in Liyue - but in truth, gods admire skeptics such as her quite a lot";
  final stars = 5;
  final elementType = ElementType.electro;
  final weaponType = WeaponType.bow;

  final ascentionMaterials = <CharacterAscentionModel>[
    CharacterAscentionModel(
      rank: 1,
      level: 1,
      materials: [
        ItemAscentionMaterialModel(quantity: 1, imagePath: 'vajrada_amethyst_sliver.png'),
        ItemAscentionMaterialModel(quantity: 3, imagePath: 'cor_lapis.png'),
        ItemAscentionMaterialModel(quantity: 3, imagePath: 'whopperflower_nectar.png'),
        ItemAscentionMaterialModel(quantity: 20000, imagePath: 'mora.png'),
      ],
    ),
    CharacterAscentionModel(
      rank: 2,
      level: 20,
      materials: [
        ItemAscentionMaterialModel(quantity: 3, imagePath: 'vajrada_amethyst_fragment.png'),
        ItemAscentionMaterialModel(quantity: 2, imagePath: 'lightning_prism.png'),
        ItemAscentionMaterialModel(quantity: 10, imagePath: 'cor_lapis.png'),
        ItemAscentionMaterialModel(quantity: 15, imagePath: 'whopperflower_nectar.png'),
        ItemAscentionMaterialModel(quantity: 40000, imagePath: 'mora.png'),
      ],
    ),
  ];

  final talentAscentionMaterials = <CharacterTalentAscentionModel>[
    CharacterTalentAscentionModel(
      level: 1,
      materials: [
        ItemAscentionMaterialModel(quantity: 3, imagePath: 'teaching_of_diligence.png'),
        ItemAscentionMaterialModel(quantity: 6, imagePath: 'whopperflower_nectar.png'),
        ItemAscentionMaterialModel(quantity: 12500, imagePath: 'mora.png'),
      ],
    ),
    CharacterTalentAscentionModel(
      level: 2,
      materials: [
        ItemAscentionMaterialModel(quantity: 2, imagePath: 'guide_to_diligence.png'),
        ItemAscentionMaterialModel(quantity: 3, imagePath: 'shimmering_nectar.png'),
        ItemAscentionMaterialModel(quantity: 17500, imagePath: 'mora.png'),
      ],
    ),
  ];

  final skills = <CharacterSkillCardModel>[
    CharacterSkillCardModel(
      image: 'assets/skills/normal_atack_yunlai_swordmanship.png',
      skillTitle: 'Yunlai Swordsmanship',
      skillSubTitle: 'Normal Attack',
      abilities: {
        'Normal Attack': 'Performs up to 5 rapid strikes.',
        'Charged Attack': 'Consumes a certain amount of Stamina to unleash 2 rapid sword strikes.',
        'Plunging Attack':
            'Plunges from mid-air to strike the ground below, damaging enemeies along the path and dealing AoE DMG upon impact.'
      },
    ),
    CharacterSkillCardModel(
      image: 'assets/skills/stellar_restoration.png',
      skillTitle: 'Stellar Restoration',
      skillSubTitle: 'Elemental Skill',
      description:
          'Hurls a Lightning Stiletto that annihilates her enemies like the swift thunder. When the Stiletto hits its target, it deals Electro DMG to enemies in a small AoE, and places a Stiletto Mark on the spot hit.',
      abilities: {
        'Hold':
            'Hold to adjust the direction in which the Stiletto shall be thrown.Stilettos thrown by the Hold attack mode can be suspended in mid-air, allowing Keqing to jump to them when using Stellar Restoration a second time.',
        'Lightning Stiletto':
            'If Keqing uses Stellar Restoration again or uses a Charged Attack while its duration lasts, it will clear the Stiletto Mark and produce different effects: If she uses Stellar Restoration again, she will blink to the location of the Mark and unleashed one slashing attack that deals AoE Electro DMG. When blinking to a Stiletto that was thrown from a Holding attack, Keqing can leap across obstructing terrain. If Keqing uses a Charged Attack, she will ignite a series of thundering cuts at the Marks location, dealing AoE Electro DMG.',
      },
    ),
  ];

  final passives = <CharacterPassiveTalentModel>[
    CharacterPassiveTalentModel(
      image: 'assets/skills/thundering_penance.png',
      title: 'Thundering Penance',
      subtitle: 'Unlocked at Ascension level 1',
      description:
          "Within 5s of recasting Stellar Restoration while a Lightning Stiletto is present, Keqing's Normal and Charged Attacks are converted to Electro DMG.",
    ),
    CharacterPassiveTalentModel(
      image: 'assets/skills/aristocratic_dignity.png',
      title: 'Aristocratic Dignity',
      subtitle: 'Unlocked at Ascension 4',
      description:
          "When casting Starward Sword, Keqing's CRIT Rate is increased by 15%, and her Energy Recharge is increased by 15%. This effect lasts for 8s.",
    ),
    CharacterPassiveTalentModel(
      image: 'assets/skills/lands_overseer.png',
      title: "Land's Overseer",
      subtitle: 'Unlocked Automatically',
      description: "When dispatched on an expedition in Liyue, time consumed is reduced by 25%.",
    ),
  ];

  final constellations = <CharacterConstellationModel>[
    CharacterConstellationModel(
      image: 'assets/skills/thundering_might.png',
      number: 1,
      title: 'Thundering Might',
      description:
          'Recasting Stellar Restoration while a Lightning Stiletto is present causes Keqing to deal 50% of her ATK as AoE Electro DMG at the start point and terminus of her Blink.',
    ),
    CharacterConstellationModel(
      image: 'assets/skills/keen_extraction.png',
      number: 2,
      title: 'Keen Extraction',
      description:
          "When Keqing's Normal and Charged Attack's hit enemies affected by Electro, they have a 50% chance of producing an Elemental Particle. This effect can only occur once every 5s.",
    ),
    CharacterConstellationModel(
      image: 'assets/skills/foreseen_reformation.png',
      number: 3,
      title: 'Forseen Reformation',
      description: 'Increases the Level of Starward Sword by 3. Maximum upgrade level is 15.',
    ),
    CharacterConstellationModel(
      image: 'assets/skills/attunement.png',
      number: 4,
      title: 'Attunement',
      description: 'For 10s after Keqing triggers an Electro-related Elemental Reaction, her ATK is increased by 25%.',
    ),
    CharacterConstellationModel(
      image: 'assets/skills/beckoning_stars.png',
      number: 5,
      title: 'Beckoning Stars',
      description: 'Increase the Level of Stellar Restoration by 3.Maximum upgrade level is 15.',
    ),
    CharacterConstellationModel(
      image: 'assets/skills/tenacious_star.png',
      number: 6,
      title: 'Tenacious Star',
      description:
          'When initiating a Normal Attack, Charged Attack, Elemental Skill or Elemental Burst, Keqing gains a 6% Electro DMG Bonus for 8s. Effects triggered by Normal Attacks, Charged Attacks, Elemental Skills and Elemental Bursts are considered independent entities.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              _buildTop(context),
              _buildBottom(context),
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
                  fullImgPath,
                  width: 350,
                  height: imgHeight,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              fullImgPath,
              width: 340,
              height: imgHeight,
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

  Widget _buildBottom(BuildContext context) {
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
            _buildSkillsCard(context),
            _buildAscentionCard(context),
            _buildTalentAscentionCard(context),
            _buildPassiveCards(context),
            _buildConstellationCards(context),
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
          'Keqing',
          style: theme.textTheme.headline5.copyWith(fontWeight: FontWeight.bold),
        ),
        ItemDescription(title: 'Rarity', widget: Rarity(stars: stars), useColumn: false),
        ItemDescription(
          title: 'Element',
          widget: Image.asset(elementType.getElementAsssetPath(), width: imgSize, height: imgSize),
          useColumn: false,
        ),
        ItemDescription(title: 'Region', widget: Text('Mondstat'), useColumn: false),
        ItemDescription(
          title: 'Weapon',
          widget: Image.asset(weaponType.getWeaponAssetPath(), width: imgSize, height: imgSize),
          useColumn: false,
        ),
        ItemDescription(title: 'Role', widget: Text('Support DPS'), useColumn: false),
        ItemDescription(title: 'Gender', widget: Text('Female'), useColumn: false),
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

  Widget _buildSkillCard(BuildContext context, CharacterSkillCardModel model, bool isEven) {
    final theme = Theme.of(context);
    final widgets = <Widget>[];
    model.abilities.entries.forEach((element) {
      widgets.add(Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Center(
                child: Text(
              element.key,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.subtitle1.copyWith(color: theme.accentColor),
            )),
            Text(element.value, style: theme.textTheme.bodyText2.copyWith(fontSize: 12))
          ],
        ),
      ));
    });

    final img = Expanded(child: Image.asset(model.image, width: 80, height: 80));
    final titles = Expanded(
      child: Column(
        children: [
          Tooltip(
            message: model.skillTitle,
            child: Text(
              model.skillTitle,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headline6.copyWith(color: theme.accentColor),
            ),
          ),
          Tooltip(
            message: model.skillSubTitle,
            child: Text(
              model.skillSubTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return Card(
      elevation: Styles.cardTenElevation,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: isEven ? [img, titles] : [titles, img],
            ),
            ...widgets,
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard(BuildContext context) {
    final theme = Theme.of(context);
    final cards = skills.mapIndex((e, index) => _buildSkillCard(context, e, index.isEven)).toList();
    final body = Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(children: cards),
    );

    return ItemDescriptionDetail(title: 'Skills', icon: Icon(Icons.settings), body: body);
  }

  TableRow _buildAscentionRow(CharacterAscentionModel model) {
    final materials = model.materials
        .map((m) => WrappedAscentionMaterial(image: 'assets/items/${m.imagePath}', quantity: m.quantity))
        .toList();
    return TableRow(children: [
      Padding(
        padding: Styles.edgeInsetAll10,
        child: Center(child: Text('${model.rank}')),
      ),
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

  Widget _buildAscentionCard(BuildContext context) {
    final body = Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.2),
          1: FractionColumnWidth(.2),
          2: FractionColumnWidth(.6),
        },
        children: [
          TableRow(
            children: [
              Padding(
                padding: Styles.edgeInsetAll10,
                child: Center(child: Text('Rank')),
              ),
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
          ...ascentionMaterials.map((e) => _buildAscentionRow(e)).toList(),
        ],
      ),
    );
    return ItemDescriptionDetail(title: 'Ascention Materials', icon: Icon(Icons.settings), body: body);
  }

  TableRow _buildTalentAscentionRow(CharacterTalentAscentionModel model) {
    final materials = model.materials
        .map(
          (m) => Wrap(children: [
            Image.asset('assets/items/${m.imagePath}', width: 20, height: 20),
            Container(
              margin: EdgeInsets.only(left: 5, right: 10),
              child: Text('x ${m.quantity}'),
            ),
          ]),
        )
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

  Widget _buildTalentAscentionCard(BuildContext context) {
    final body = Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(.2),
          2: FractionColumnWidth(.8),
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
          ...talentAscentionMaterials.map((e) => _buildTalentAscentionRow(e)).toList(),
        ],
      ),
    );

    return ItemDescriptionDetail(title: 'Talent Ascention', icon: Icon(Icons.settings), body: body);
  }

  Widget _buildPassiveCard(CharacterPassiveTalentModel model, BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(model.image, width: 40, height: 40),
            Text(
              model.title,
              style: theme.textTheme.subtitle1.copyWith(color: Colors.amber),
              textAlign: TextAlign.center,
            ),
            Text(
              model.subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.subtitle2,
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                model.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyText2.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConstellationCard(CharacterConstellationModel model, BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(model.image, width: 40, height: 40),
            Text(
              model.title,
              style: theme.textTheme.subtitle1.copyWith(color: Colors.amber),
              textAlign: TextAlign.center,
            ),
            Text(
              'Constellation ${model.number}',
              textAlign: TextAlign.center,
              style: theme.textTheme.subtitle2,
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                model.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyText2.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassiveCards(BuildContext context) {
    final items = passives.map((e) => _buildPassiveCard(e, context)).toList();
    final body = Wrap(children: items);
    return ItemDescriptionDetail(title: 'Passives', icon: Icon(Icons.settings), body: body);
  }

  Widget _buildConstellationCards(BuildContext context) {
    final items = constellations.map((e) => _buildConstellationCard(e, context)).toList();
    final body = Wrap(children: items);
    return ItemDescriptionDetail(title: 'Constellations', icon: Icon(Icons.settings), body: body);
  }
}
