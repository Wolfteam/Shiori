import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/inventory/inventory_bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/inventory/widgets/characters_inventory_tab_page.dart';
import 'package:shiori/presentation/inventory/widgets/clear_all_dialog.dart';
import 'package:shiori/presentation/inventory/widgets/materials_inventory_tab_page.dart';
import 'package:shiori/presentation/inventory/widgets/weapons_inventory_tab_page.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/styles.dart';

class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Injection.inventoryBloc..add(const InventoryEvent.init()),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: const _AppBar(),
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
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AppBar(
      title: Text(s.myInventory),
      bottom: TabBar(
        tabs: const [
          Tab(icon: Icon(Icons.people)),
          Tab(icon: Icon(Shiori.crossed_swords)),
          Tab(icon: Icon(Shiori.cubes)),
        ],
        indicatorColor: Theme.of(context).colorScheme.secondary,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.clear_all),
          splashRadius: Styles.mediumButtonSplashRadius,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<InventoryBloc>(),
              child: const ClearAllDialog(),
            ),
          ),
        )
      ],
    );
  }

  @override
  //toolbar + tabbar + indicator height
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 46 + 2);
}
