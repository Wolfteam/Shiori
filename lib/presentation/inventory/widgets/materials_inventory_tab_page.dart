import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/presentation/materials/widgets/material_card.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

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
              crossAxisCount: SizeUtils.getCrossAxisCountForGrids(context, itemIsSmall: true),
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
