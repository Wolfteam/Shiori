import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/inventory/widgets/characters_inventory_tab_page.dart';
import 'package:shiori/presentation/inventory/widgets/clear_all_dialog.dart';
import 'package:shiori/presentation/inventory/widgets/materials_inventory_tab_page.dart';
import 'package:shiori/presentation/inventory/widgets/weapons_inventory_tab_page.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';

class InventoryPage extends StatelessWidget {
  final tabs = const [
    Tab(icon: Icon(Icons.people)),
    Tab(icon: Icon(Shiori.crossed_swords)),
    Tab(icon: Icon(Shiori.cubes)),
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
