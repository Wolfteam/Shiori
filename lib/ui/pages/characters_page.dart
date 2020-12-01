import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../common/enums/element_type.dart';
import '../../common/enums/weapon_type.dart';
import '../../common/styles.dart';
import '../../models/characters/character_card_model.dart';
import '../widgets/characters/character_bottom_sheet.dart';
import '../widgets/characters/character_card.dart';
import '../widgets/common/item_counter.dart';
import '../widgets/common/search_box.dart';

class CharactersPage extends StatefulWidget {
  @override
  _CharactersPageState createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  ScrollController _scrollController;
  final characters = <CharacterCardModel>[
    CharacterCardModel(
      name: 'Keqing',
      elementType: ElementType.electro,
      logoName: 'Keqing.png',
      stars: 5,
      weaponType: WeaponType.sword,
    ),
    CharacterCardModel(
        name: 'Qiqi',
        elementType: ElementType.cryo,
        logoName: 'Qiqi.png',
        stars: 5,
        weaponType: WeaponType.sword,
        isComingSoon: true),
    CharacterCardModel(
      name: 'Barbara',
      elementType: ElementType.hydro,
      logoName: 'Barbara.png',
      stars: 4,
      weaponType: WeaponType.catalyst,
    ),
    CharacterCardModel(
      name: 'Beidou',
      elementType: ElementType.electro,
      logoName: 'Beidou.png',
      stars: 4,
      weaponType: WeaponType.claymore,
      isNew: true,
    ),
    CharacterCardModel(
      name: 'Amber',
      elementType: ElementType.pyro,
      logoName: 'Amber.png',
      stars: 4,
      weaponType: WeaponType.bow,
      isNew: true,
    ),
    CharacterCardModel(
      name: 'Venti',
      elementType: ElementType.anemo,
      logoName: 'Venti.png',
      stars: 5,
      weaponType: WeaponType.bow,
    ),
    CharacterCardModel(
      name: 'Mona',
      elementType: ElementType.hydro,
      logoName: 'Mona.png',
      stars: 5,
      weaponType: WeaponType.catalyst,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // _buildAppbar(),
        _buildFiltersSwitch(),
        _buildGrid(context),
      ],
    );
  }

  Widget _buildAppbar() {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final theme = Theme.of(context);
    return SliverAppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Characters',
            style: theme.textTheme.headline6,
          ),
          ItemCounter(characters.length),
        ],
      ),
      floating: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.green,
          // padding: EdgeInsets.only(top: statusBarHeight, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SearchBox(),
              // _buildFilterBar(),
            ],
          ),
        ),
      ),
      expandedHeight: 170,
      pinned: true,
      snap: true,
    );
  }

  Widget _buildGrid(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: isPortrait ? 2 : 3,
        itemBuilder: (ctx, index) => CharacterCard(characters[index]),
        itemCount: characters.length,
        crossAxisSpacing: isPortrait ? 10 : 5,
        mainAxisSpacing: 5,
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
        // gridDelegate: SliverStaggeredGridDelegateWithFixedCrossAxisCount(
        //   crossAxisCount: 2,
        //   crossAxisSpacing: 10,
        //   mainAxisSpacing: 5,
        //   staggeredTileCount: characters.length,
        //   staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
        //   // childAspectRatio: childAspectRatio,
        // ),
        // delegate: SliverChildListDelegate(characters.map((c) => CharacterCard(c)).toList()),
        // itemCount: characters.length,
        // itemBuilder: (ctx, index) => CharacterCard(characters[index]),
      ),
    );
  }

  Widget _buildFilterBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      overflowDirection: VerticalDirection.down,
      buttonPadding: EdgeInsets.all(0),
      children: [
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: () => {},
          tooltip: 'Something',
        ),
        IconButton(
          icon: const Icon(Icons.attach_money),
          onPressed: () => {},
          tooltip: 'Something',
        ),
        IconButton(
          icon: const Icon(Icons.category),
          onPressed: () => {},
          tooltip: 'Something',
        ),
      ],
    );
  }

  Widget _buildFiltersSwitch() {
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

  void _showFiltersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => CharacterBottomSheet(),
    );
  }
}
