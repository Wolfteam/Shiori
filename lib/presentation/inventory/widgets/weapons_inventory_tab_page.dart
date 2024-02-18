import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/weapons/weapons_page.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

class WeaponsInventoryTabPage extends StatefulWidget {
  @override
  _WeaponsInventoryTabPageState createState() => _WeaponsInventoryTabPageState();
}

class _WeaponsInventoryTabPageState extends State<WeaponsInventoryTabPage> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  bool get isInitiallyVisible => true;

  @override
  bool get hideOnTop => false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Scaffold(
        floatingActionButton: AppFab(
          onPressed: () => _openWeaponsPage(context),
          icon: const Icon(Icons.add),
          hideFabAnimController: hideFabAnimController,
          scrollController: scrollController,
          mini: false,
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (ctx, state) => GridView.builder(
            controller: scrollController,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: WeaponCard.itemWidth,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: WeaponCard.itemHeight,
              childAspectRatio: WeaponCard.itemWidth / WeaponCard.itemHeight,
            ),
            itemCount: state.weapons.length,
            itemBuilder: (context, index) => WeaponCard.item(weapon: state.weapons[index]),
          ),
        ),
      ),
    );
  }

  Future<void> _openWeaponsPage(BuildContext context) async {
    final inventoryBloc = context.read<InventoryBloc>();
    final weaponsBloc = context.read<WeaponsBloc>();
    weaponsBloc.add(WeaponsEvent.init(excludeKeys: inventoryBloc.getItemsKeysToExclude()));
    final route = MaterialPageRoute<String>(builder: (ctx) => const WeaponsPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);

    weaponsBloc.add(const WeaponsEvent.init());
    if (keyName.isNullEmptyOrWhitespace) {
      return;
    }

    inventoryBloc.add(InventoryEvent.addWeapon(key: keyName!));
  }
}
