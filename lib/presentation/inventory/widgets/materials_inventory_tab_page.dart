import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/materials/widgets/material_card.dart';
import 'package:genshindb/presentation/shared/app_fab.dart';
import 'package:genshindb/presentation/shared/extensions/scroll_controller_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';

class MaterialsInventoryTabPage extends StatefulWidget {
  @override
  _MaterialsInventoryTabPageState createState() => _MaterialsInventoryTabPageState();
}

class _MaterialsInventoryTabPageState extends State<MaterialsInventoryTabPage> with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 0, // initially not visible
    );
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController));
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Scaffold(
        floatingActionButton: AppFab(
          scrollController: _scrollController,
          hideFabAnimController: _hideFabAnimController,
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) => StaggeredGridView.countBuilder(
              controller: _scrollController,
              crossAxisCount: isPortrait ? 3 : 5,
              itemBuilder: (ctx, index) => MaterialCard.quantity(item: state.materials[index]),
              itemCount: state.materials.length,
              crossAxisSpacing: isPortrait ? 10 : 5,
              mainAxisSpacing: 5,
              staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }
}
