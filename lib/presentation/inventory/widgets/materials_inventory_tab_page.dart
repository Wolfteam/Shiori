import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/materials/widgets/material_card.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/mixins/app_fab_mixin.dart';

class MaterialsInventoryTabPage extends StatefulWidget {
  @override
  _MaterialsInventoryTabPageState createState() => _MaterialsInventoryTabPageState();
}

class _MaterialsInventoryTabPageState extends State<MaterialsInventoryTabPage> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Scaffold(
        floatingActionButton: getAppFab(),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) => StaggeredGridView.countBuilder(
              controller: scrollController,
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
}
