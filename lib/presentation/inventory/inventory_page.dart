import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/inventory/widgets/characters_inventory_tab_page.dart';
import 'package:genshindb/presentation/inventory/widgets/clear_all_dialog.dart';
import 'package:genshindb/presentation/inventory/widgets/materials_inventory_tab_page.dart';
import 'package:genshindb/presentation/inventory/widgets/weapons_inventory_tab_page.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';

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
          actions: [
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => _showClearInventoryDialog(context),
            )
          ],
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

  Future<void> _showClearInventoryDialog(BuildContext context) async {
    await showDialog(context: context, builder: (_) => const ClearAllDialog());
  }
}
