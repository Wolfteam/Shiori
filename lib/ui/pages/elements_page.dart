import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../common/styles.dart';
import '../../models/elements/element_card_model.dart';
import '../../models/elements/element_reaction_card_model.dart';
import '../widgets/elements/element_debuff_card.dart';
import '../widgets/elements/element_reaction_card.dart';

class ElementsPage extends StatelessWidget {
  final debuffs = [
    ElementCardModel(
      image: 'assets/elements/electro.png',
      name: 'Engulfing Storm',
      effect: 'Continuously drains Energy Recharge.',
    ),
    ElementCardModel(
      image: 'assets/elements/hydro.png',
      name: 'Slowing Water',
      effect: 'Increases skill CD durations.',
    ),
    ElementCardModel(
      image: 'assets/elements/pyro.png',
      name: 'Smoldering Flames',
      effect: 'Continuously inflicts damage over time.',
    ),
    ElementCardModel(
      image: 'assets/elements/cryo.png',
      name: 'Condensed Ice',
      effect: 'Increases stamina consumption.',
    ),
  ];

  final reactions = [
    ElementReactionCardModel.withImages(
      name: 'Burning',
      effect: 'Deals Pyro DMG over time.',
      principal: ['assets/elements/dendro.png'],
      secondary: ['assets/elements/pyro.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'Crystalize',
      effect: 'Creates a crystal that will provide a shield when picked up.',
      principal: ['assets/elements/geo.png'],
      secondary: [
        'assets/elements/cryo.png',
        'assets/elements/electro.png',
        'assets/elements/hydro.png',
        'assets/elements/pyro.png',
      ],
    ),
    ElementReactionCardModel.withImages(
      name: 'Electro-Charged',
      effect: 'Deals Electro DMG over time.',
      principal: ['assets/elements/electro.png'],
      secondary: ['assets/elements/hydro.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'Frozen',
      effect: 'Freezes the target.',
      principal: ['assets/elements/cryo.png'],
      secondary: ['assets/elements/hydro.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'Melt',
      effect: 'Deals extra damage.',
      principal: ['assets/elements/cryo.png'],
      secondary: ['assets/elements/pyro.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'Overloaded',
      effect: 'Deals AoE Pyro DMG.',
      principal: ['assets/elements/electro.png'],
      secondary: ['assets/elements/pyro.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'Superconduct',
      effect: "Deals AoE Cryo DMG and reduces the target's Physical RES by 50%.",
      principal: ['assets/elements/cryo.png'],
      secondary: ['assets/elements/electro.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'Swirl',
      effect: "Deals extra elemental damage and spreads the effect.",
      principal: ['assets/elements/anemo.png'],
      secondary: [
        'assets/elements/cryo.png',
        'assets/elements/electro.png',
        'assets/elements/hydro.png',
        'assets/elements/pyro.png',
      ],
    ),
    ElementReactionCardModel.withImages(
      name: 'Vaporize',
      effect: "Deals extra damage.",
      principal: ['assets/elements/hydro.png'],
      secondary: ['assets/elements/pyro.png'],
    ),
  ];

  final resonance = [
    ElementReactionCardModel.withImages(
      name: 'Enduring Rock',
      effect: 'Increases resistance to interruption. When protected by a shield, increases Attack DMG by 15%.',
      principal: ['assets/elements/geo.png'],
      secondary: ['assets/elements/geo.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'Fervent Flames',
      effect: 'Affected by Cryo for 40% less time. Increases ATK by 25%.',
      principal: ['assets/elements/pyro.png'],
      secondary: ['assets/elements/pyro.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'Soothing Waters',
      effect: 'Affected by Pyro for 40% less time. Increases incoming healing by 30%.',
      principal: ['assets/elements/hydro.png'],
      secondary: ['assets/elements/hydro.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'Impetuous Winds',
      effect: 'Decreases Stamina Consumption by 15%. Increases Movement SPD by 10%. Shortens Skill CD by 5%.',
      principal: ['assets/elements/anemo.png'],
      secondary: ['assets/elements/anemo.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'High Voltage',
      effect:
          'Affected by Hydro for 40% less time. Superconduct, Overloaded, and Electro-Charged have a 100% chance to generate an Electro Elemental Particle (CD: 5s).',
      principal: ['assets/elements/electro.png'],
      secondary: ['assets/elements/electro.png'],
    ),
    ElementReactionCardModel.withImages(
      name: 'Shattering Ice',
      effect:
          'Affected by Electro for 40% less time. Increases CRIT Rate against enemies that are Frozen or affected by Cryo by 15%.',
      principal: ['assets/elements/cryo.png'],
      secondary: ['assets/elements/cryo.png'],
    ),
    ElementReactionCardModel.withoutImages(
      name: 'Protective Canopy',
      effect: 'All Elemental RES by 15%.',
      description: 'Any 4 Unique Elements',
    ),
  ];

//TODO: TRY TO MOVE EACH OF THESE TO ITS OWN WIDGET
//TODO: REMOVE THE NOT USED CLASSES

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        title: Text('Elements'),
      ),
      body: SafeArea(
        child: Container(
          padding: Styles.edgeInsetAll10,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: Styles.edgeInsetAll5,
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Text(
                      'Elemental Debuffs',
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('Each of these have a different negative effect when applied to you or your enemies')
                  ]),
                ),
              ),
              SliverStaggeredGrid.countBuilder(
                crossAxisCount: isPortrait ? 2 : 3,
                itemBuilder: (ctx, index) {
                  final item = debuffs[index];
                  return ElementDebuffCard(
                      key: Key(item.name), effect: item.effect, image: item.image, name: item.name);
                },
                itemCount: debuffs.length,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
              ),
              SliverPadding(
                padding: Styles.edgeInsetAll5,
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Text(
                      'Elemental Reactions',
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('Combinations of different elements produces different reactions'),
                  ]),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    final e = reactions[index];
                    return ElementReactionCard.withImages(
                      key: Key('reaction_$index'),
                      name: e.name,
                      effect: e.effect,
                      principal: e.principal,
                      secondary: e.secondary,
                    );
                  },
                  childCount: reactions.length,
                ),
              ),
              SliverPadding(
                padding: Styles.edgeInsetAll5,
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Text(
                      'Elemental Resonances',
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('Having these types of character in your party will give you the corresponding effect'),
                  ]),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    final e = resonance[index];
                    if (e.principal.isNotEmpty && e.secondary.isNotEmpty) {
                      return ElementReactionCard.withImages(
                        key: Key('resonance_$index'),
                        name: e.name,
                        effect: e.effect,
                        principal: e.principal,
                        secondary: e.secondary,
                        showPlusIcon: false,
                      );
                    }

                    return ElementReactionCard.withoutImage(
                      name: e.name,
                      effect: e.effect,
                      showPlusIcon: false,
                      description: e.description,
                    );
                  },
                  childCount: resonance.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
