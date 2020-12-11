import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../bloc/bloc.dart';
import '../common/loading.dart';
import 'char_card_ascention_material.dart';

class TodayCharAscentionMaterials extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return state.when(
          loading: () => const SliverToBoxAdapter(child: Loading(useScaffold: false)),
          loaded: (charAscMaterials, _) => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            sliver: SliverStaggeredGrid.countBuilder(
              crossAxisCount: isPortrait ? 1 : 2,
              itemBuilder: (ctx, index) {
                final e = charAscMaterials[index];
                return e.isFromBoss
                    ? CharCardAscentionMaterial.fromBoss(
                        name: e.name,
                        image: e.image,
                        bossName: e.bossName,
                        charImgs: e.characters,
                      )
                    : CharCardAscentionMaterial.fromDays(
                        name: e.name,
                        image: e.image,
                        days: e.days,
                        charImgs: e.characters,
                      );
              },
              itemCount: charAscMaterials.length,
              staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
            ),
          ),
        );
      },
    );
  }
}
