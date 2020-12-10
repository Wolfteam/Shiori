import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../bloc/bloc.dart';
import 'weapon_card_ascention_material.dart';

class TodayWeaponMaterials extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return state.when(
          loading: () => const SliverToBoxAdapter(child: CircularProgressIndicator()),
          loaded: (_, weaponAscMaterials) => SliverStaggeredGrid.countBuilder(
            crossAxisCount: isPortrait ? 2 : 3,
            itemBuilder: (ctx, index) {
              final item = weaponAscMaterials[index];
              return WeaponCardAscentionMaterial(name: item.name, image: item.image, days: item.days);
            },
            itemCount: weaponAscMaterials.length,
            staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
          ),
        );
      },
    );
  }
}
