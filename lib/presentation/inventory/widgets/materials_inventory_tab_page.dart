import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/presentation/materials/widgets/material_card.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

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
            loaded: (state) => WaterfallFlow.builder(
              controller: scrollController,
              itemCount: state.materials.length,
              itemBuilder: (context, index) => MaterialCard.item(item: state.materials[index]),
              gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: SizeUtils.getCrossAxisCountForGrids(context, itemIsSmall: true),
                crossAxisSpacing: isPortrait ? 10 : 5,
                mainAxisSpacing: 5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
