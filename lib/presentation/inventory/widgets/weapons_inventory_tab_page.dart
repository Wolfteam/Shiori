import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/presentation/shared/app_fab.dart';
import 'package:genshindb/presentation/shared/extensions/scroll_controller_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/weapons/weapons_page.dart';
import 'package:genshindb/presentation/weapons/widgets/weapon_card.dart';

class WeaponsInventoryTabPage extends StatefulWidget {
  @override
  _WeaponsInventoryTabPageState createState() => _WeaponsInventoryTabPageState();
}

class _WeaponsInventoryTabPageState extends State<WeaponsInventoryTabPage> with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController, hideOnTop: false));
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Scaffold(
        floatingActionButton: AppFab(
          onPressed: () => _openWeaponsPage(context),
          icon: const Icon(Icons.add),
          hideFabAnimController: _hideFabAnimController,
          scrollController: _scrollController,
          mini: false,
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) => StaggeredGridView.countBuilder(
              controller: _scrollController,
              crossAxisCount: isPortrait ? 2 : 3,
              itemBuilder: (ctx, index) => WeaponCard.item(weapon: state.weapons[index]),
              itemCount: state.weapons.length,
              crossAxisSpacing: isPortrait ? 10 : 5,
              mainAxisSpacing: 5,
              staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openWeaponsPage(BuildContext context) async {
    context.read<WeaponsBloc>().add(const WeaponsEvent.init(includeInventory: false));
    final route = MaterialPageRoute<String>(builder: (ctx) => const WeaponsPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);

    context.read<WeaponsBloc>().add(const WeaponsEvent.init());
    if (keyName.isNullEmptyOrWhitespace) {
      return;
    }

    context.read<InventoryBloc>().add(InventoryEvent.addWeapon(key: keyName));
  }
}
