import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../bloc/bloc.dart';
import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../../models/models.dart';
import '../../models/weapons/weapon_card_model.dart';
import '../widgets/common/loading.dart';
import '../widgets/common/search_box.dart';
import '../widgets/common/sliver_nothing_found.dart';
import '../widgets/weapons/weapon_bottom_sheet.dart';
import '../widgets/weapons/weapon_card.dart';

class WeaponsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeaponsBloc, WeaponsState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (s) => CustomScrollView(
            slivers: [
              _buildFiltersSwitch(s.search, context),
              if (s.weapons.isNotEmpty) _buildGrid(context, s.weapons) else const SliverNothingFound(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltersSwitch(String search, BuildContext context) {
    final showClearButton = search != null && search.isNotEmpty;
    final s = S.of(context);
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SearchBox(
            value: search,
            showClearButton: showClearButton,
            searchChanged: (e) => context.read<WeaponsBloc>().add(WeaponsEvent.searchChanged(search: e)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  s.weapons,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline6,
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () => _showFiltersModal(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<WeaponCardModel> weapons) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: isPortrait ? 2 : 3,
        itemBuilder: (ctx, index) {
          final weapon = weapons[index];
          return WeaponCard(
            baseAtk: weapon.baseAtk,
            image: weapon.image,
            name: weapon.name,
            rarity: weapon.rarity,
            type: weapon.type,
          );
        },
        itemCount: weapons.length,
        crossAxisSpacing: isPortrait ? 10 : 5,
        mainAxisSpacing: 5,
        staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
      ),
    );
  }

  Future<void> _showFiltersModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => WeaponBottomSheet(),
    );
  }
}
