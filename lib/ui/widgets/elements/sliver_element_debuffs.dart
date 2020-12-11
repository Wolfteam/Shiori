import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../bloc/elements/elements_bloc.dart';
import '../common/loading.dart';
import 'element_debuff_card.dart';

class SliverElementDebuffs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<ElementsBloc, ElementsState>(
      builder: (context, state) {
        return state.when(
          loading: () => const SliverToBoxAdapter(child: Loading(useScaffold: false)),
          loaded: (debuffs, _, __) => SliverStaggeredGrid.countBuilder(
            crossAxisCount: isPortrait ? 2 : 3,
            itemBuilder: (ctx, index) {
              final item = debuffs[index];
              return ElementDebuffCard(key: Key(item.name), effect: item.effect, image: item.image, name: item.name);
            },
            itemCount: debuffs.length,
            staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
          ),
        );
      },
    );
  }
}
