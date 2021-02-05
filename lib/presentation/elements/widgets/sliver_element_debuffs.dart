import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'element_debuff_card.dart';

class SliverElementDebuffs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<ElementsBloc, ElementsState>(
      builder: (context, state) {
        return state.when(
          loading: () => const SliverToBoxAdapter(child: Loading(useScaffold: false)),
          loaded: (debuffs, _, __) => SliverGrid.count(
            crossAxisCount: isPortrait ? 2 : 3,
            children: debuffs
                .map((item) => Padding(
                      padding: Styles.edgeInsetAll5,
                      child: ElementDebuffCard(
                        key: Key(item.name),
                        effect: item.effect,
                        image: item.image,
                        name: item.name,
                      ),
                    ))
                .toList(),
          ),
          //TODO: COMMENTED UNTIL https://github.com/letsar/flutter_staggered_grid_view/issues/145
          // loaded: (debuffs, _, __) => SliverStaggeredGrid.countBuilder(
          //   crossAxisCount: isPortrait ? 2 : 3,
          //   itemBuilder: (ctx, index) {
          //     final item = debuffs[index];
          //     return ElementDebuffCard(key: Key(item.name), effect: item.effect, image: item.image, name: item.name);
          //   },
          //   itemCount: debuffs.length,
          //   staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
          // ),
        );
      },
    );
  }
}
