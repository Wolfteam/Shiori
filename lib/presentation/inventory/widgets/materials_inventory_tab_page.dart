import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/presentation/materials/widgets/material_card.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';

class MaterialsInventoryTabPage extends StatefulWidget {
  @override
  _MaterialsInventoryTabPageState createState() => _MaterialsInventoryTabPageState();
}

class _MaterialsInventoryTabPageState extends State<MaterialsInventoryTabPage> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Scaffold(
        floatingActionButton: getAppFab(),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (ctx, state) => GridView.builder(
            controller: scrollController,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: MaterialCard.itemWidth,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: MaterialCard.itemHeight,
              childAspectRatio: MaterialCard.itemWidth / MaterialCard.itemHeight,
            ),
            itemCount: state.materials.length,
            itemBuilder: (context, index) => MaterialCard.quantity(item: state.materials[index]),
          ),
        ),
      ),
    );
  }
}
