import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/inventory/widgets/characters_inventory_tab_page.dart';
import 'package:genshindb/presentation/inventory/widgets/materials_inventory_tab_page.dart';
import 'package:genshindb/presentation/inventory/widgets/weapons_inventory_tab_page.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';

//TODO: CHANGE THE ITEM ICONS
class InventoryPage extends StatelessWidget {
  final tabs = const [
    Tab(icon: Icon(Icons.people)),
    Tab(icon: Icon(GenshinDb.crossed_swords)),
    Tab(icon: Icon(GenshinDb.cubes)),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.myInventory),
          bottom: TabBar(tabs: tabs),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              CharactersInventoryTabPage(),
              WeaponsInventoryTabPage(),
              MaterialsInventoryTabPage(),
            ],
          ),
        ),
      ),
    );
  }
}
