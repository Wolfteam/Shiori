import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../common/styles.dart';
import '../../models/artifacts/artifact_card_model.dart';
import '../widgets/artifacts/artifact_bottom_sheet.dart';
import '../widgets/artifacts/artifact_card.dart';
import '../widgets/artifacts/artifact_info_card.dart';
import '../widgets/common/search_box.dart';

class ArtifactsPage extends StatelessWidget {
  final artifacts = <ArtifactCardModel>[
    // ArtifactCardModel(
    //   name: 'Glacier and Snowfield',
    //   rarity: 5,
    //   image: 'assets/artifacts/glacier_and_snowfield_4.png',
    //   bonus: {
    //     '2 Piece': 'Cryo DMG Bonus +15%',
    //     '4 Piece':
    //         'Increases Superconduct DMG by 100%. Increases Melt DMG by 15%. Using an Elemental Burst increases Cryo DMG Bonus by 30% for 10s.'
    //   },
    // ),
    // ArtifactCardModel(
    //   name: 'Blizzard Strayer',
    //   rarity: 5,
    //   image: 'assets/artifacts/blizzard_walker_4.png',
    //   bonus: {
    //     '2 Piece': 'Cryo DMG Bonus +15%',
    //     '4 Piece':
    //         'When a character attacks an enemy affected by Cryo, their CRIT Rate is increased by 20%. If the enemy is Frozen, CRIT Rate is increased by an additional 20%.'
    //   },
    // ),
    // ArtifactCardModel(
    //   name: 'Prayers to Springtime',
    //   rarity: 4,
    //   image: 'assets/artifacts/prayers_of_springtime_4.png',
    //   bonus: {
    //     '1 Piece bonus': 'Affected by Cryo for 40% less time.',
    //   },
    // ),
    // ArtifactCardModel(
    //   name: "Gladiator's Finale",
    //   rarity: 5,
    //   image: 'assets/artifacts/gladiators_finale_4.png',
    //   bonus: {
    //     '2 Piece': 'ATK +18%.',
    //     '4 Piece':
    //         ' If the wielder of this artifact set uses a Sword, Claymore or Polearm, increases their Normal Attack DMG by 35%.'
    //   },
    // ),
    // ArtifactCardModel(
    //   name: 'Glacier and Snowfield',
    //   rarity: 5,
    //   image: 'assets/artifacts/glacier_and_snowfield_4.png',
    //   bonus: {
    //     '2 Piece': 'Cryo DMG Bonus +15%',
    //     '4 Piece':
    //         'Increases Superconduct DMG by 100%. Increases Melt DMG by 15%. Using an Elemental Burst increases Cryo DMG Bonus by 30% for 10s.'
    //   },
    // ),
    // ArtifactCardModel(
    //   name: 'Blizzard Strayer',
    //   rarity: 5,
    //   image: 'assets/artifacts/blizzard_walker_4.png',
    //   bonus: {
    //     '2 Piece': 'Cryo DMG Bonus +15%',
    //     '4 Piece':
    //         'When a character attacks an enemy affected by Cryo, their CRIT Rate is increased by 20%. If the enemy is Frozen, CRIT Rate is increased by an additional 20%.'
    //   },
    // ),
    // ArtifactCardModel(
    //   name: 'Prayers to Springtime',
    //   rarity: 4,
    //   image: 'assets/artifacts/prayers_of_springtime_4.png',
    //   bonus: {
    //     '1 Piece bonus': 'Affected by Cryo for 40% less time.',
    //   },
    // ),
    // ArtifactCardModel(
    //   name: "Gladiator's Finale",
    //   rarity: 5,
    //   image: 'assets/artifacts/gladiators_finale_4.png',
    //   bonus: {
    //     '2 Piece': 'ATK +18%.',
    //     '4 Piece':
    //         ' If the wielder of this artifact set uses a Sword, Claymore or Polearm, increases their Normal Attack DMG by 35%.'
    //   },
    // ),
    // ArtifactCardModel(
    //   name: 'Glacier and Snowfield',
    //   rarity: 5,
    //   image: 'assets/artifacts/glacier_and_snowfield_4.png',
    //   bonus: {
    //     '2 Piece': 'Cryo DMG Bonus +15%',
    //     '4 Piece':
    //         'Increases Superconduct DMG by 100%. Increases Melt DMG by 15%. Using an Elemental Burst increases Cryo DMG Bonus by 30% for 10s.'
    //   },
    // ),
    // ArtifactCardModel(
    //   name: 'Blizzard Strayer',
    //   rarity: 5,
    //   image: 'assets/artifacts/blizzard_walker_4.png',
    //   bonus: {
    //     '2 Piece': 'Cryo DMG Bonus +15%',
    //     '4 Piece':
    //         'When a character attacks an enemy affected by Cryo, their CRIT Rate is increased by 20%. If the enemy is Frozen, CRIT Rate is increased by an additional 20%.'
    //   },
    // ),
    // ArtifactCardModel(
    //   name: 'Prayers to Springtime',
    //   rarity: 4,
    //   image: 'assets/artifacts/prayers_of_springtime_4.png',
    //   bonus: {
    //     '1 Piece bonus': 'Affected by Cryo for 40% less time.',
    //   },
    // ),
    // ArtifactCardModel(
    //   name: "Gladiator's Finale",
    //   rarity: 5,
    //   image: 'assets/artifacts/gladiators_finale_4.png',
    //   bonus: {
    //     '2 Piece': 'ATK +18%.',
    //     '4 Piece':
    //         ' If the wielder of this artifact set uses a Sword, Claymore or Polearm, increases their Normal Attack DMG by 35%.'
    //   },
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildFiltersSwitch(context),
        ArtifactInfoCard(),
        _buildGrid(context),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: isPortrait ? 2 : 3,
        itemBuilder: (ctx, index) {
          final item = artifacts[index];
          return ArtifactCard(name: item.name, image: item.image, rarity: item.rarity, bonus: item.bonus);
        },
        itemCount: artifacts.length,
        crossAxisSpacing: isPortrait ? 10 : 5,
        mainAxisSpacing: 5,
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      ),
    );
  }

  Widget _buildFiltersSwitch(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SearchBox(),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'All',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline6,
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () => _showFiltersModal(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFiltersModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => ArtifactBottomSheet(),
    );
  }
}
