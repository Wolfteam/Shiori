import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/presentation/artifacts/widgets/artifact_card.dart';
import 'package:genshindb/presentation/characters/widgets/character_card.dart';
import 'package:genshindb/presentation/materials/materials_page.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';
import 'package:genshindb/presentation/weapons/widgets/weapon_card.dart';

//TODO: CHANGE THE ITEM ICONS
class InventoryPage extends StatelessWidget {
  final tabs = [
    Tab(icon: Icon(Icons.people)),
    Tab(icon: Icon(GenshinDb.crossed_swords)),
    Tab(icon: Icon(GenshinDb.overmind)),
    Tab(icon: Icon(GenshinDb.cubes)),
  ];

  final characters = <CharacterCardModel>[
    CharacterCardModel(
      key: 'Keqing',
      elementType: ElementType.dendro,
      weaponType: WeaponType.polearm,
      name: 'Keqing',
      roleType: CharacterRoleType.mainDps,
      stars: 5,
      logoName: Assets.getCharacterPath('Keqing.png'),
      materials: [],
    ),
    CharacterCardModel(
      key: 'Keqing',
      elementType: ElementType.electro,
      weaponType: WeaponType.claymore,
      name: 'Beidou',
      roleType: CharacterRoleType.mainDps,
      stars: 4,
      logoName: Assets.getCharacterPath('Beidou.png'),
      materials: [],
    )
  ];

  final weapons = <WeaponCardModel>[
    WeaponCardModel(
      key: 'Whiteblind',
      name: 'Whiteblind',
      image: Assets.getWeaponPath('whiteblind.png', WeaponType.claymore),
      locationType: ItemLocationType.crafting,
      subStatType: StatType.defPercentage,
      type: WeaponType.claymore,
      baseAtk: 40,
      rarity: 4,
      subStatValue: 20,
      isComingSoon: false,
    ),
  ];

  final artifacts = <ArtifactCardModel>[
    ArtifactCardModel(
      key: 'Gladiators Finale',
      name: 'Gladiators Finale',
      rarity: 4,
      image: Assets.getArtifactPath('gladiators_finale_4.png'),
      bonus: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Inventory'),
          bottom: TabBar(
            tabs: tabs,
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildCharactersGrid(context),
              _buildWeaponsGrid(context),
              _buildArtifactsGrid(context),
              MaterialsPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharactersGrid(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: isPortrait ? 2 : 3,
        itemBuilder: (ctx, index) {
          final char = characters[index];
          return CharacterCard(
            keyName: char.key,
            elementType: char.elementType,
            isComingSoon: char.isComingSoon,
            isNew: char.isNew,
            image: char.logoName,
            name: char.name,
            rarity: char.stars,
            weaponType: char.weaponType,
            materials: char.materials,
            showMaterials: false,
          );
        },
        itemCount: characters.length,
        crossAxisSpacing: isPortrait ? 10 : 5,
        mainAxisSpacing: 5,
        staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
      ),
    );
  }

  Widget _buildWeaponsGrid(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: isPortrait ? 2 : 3,
        itemBuilder: (ctx, index) {
          final weapon = weapons[index];
          return WeaponCard(
            keyName: weapon.key,
            baseAtk: weapon.baseAtk,
            image: weapon.image,
            name: weapon.name,
            rarity: weapon.rarity,
            type: weapon.type,
            subStatType: weapon.subStatType,
            subStatValue: weapon.subStatValue,
            isComingSoon: weapon.isComingSoon,
          );
        },
        itemCount: weapons.length,
        crossAxisSpacing: isPortrait ? 10 : 5,
        mainAxisSpacing: 5,
        staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
      ),
    );
  }

  Widget _buildArtifactsGrid(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: isPortrait ? 2 : 3,
        itemBuilder: (ctx, index) {
          final item = artifacts[index];
          return ArtifactCard(
            keyName: item.key,
            name: item.name,
            image: item.image,
            rarity: item.rarity,
            bonus: item.bonus,
          );
        },
        itemCount: artifacts.length,
        crossAxisSpacing: isPortrait ? 10 : 5,
        mainAxisSpacing: 5,
        staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
      ),
    );
  }
}
