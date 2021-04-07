import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/sliver_nothing_found.dart';
import 'package:genshindb/presentation/shared/sliver_page_filter.dart';
import 'package:genshindb/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'widgets/monster_bottom_sheet.dart';
import 'widgets/monster_card.dart';

class MonstersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final s = S.of(context);
    return BlocBuilder<MonstersBloc, MonstersState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (state) => SliverScaffoldWithFab(
            appbar: AppBar(title: Text(s.monsters)),
            slivers: [
              SliverPageFilter(
                search: state.search,
                title: s.monsters,
                onPressed: () => _showFiltersModal(context),
                searchChanged: (v) => context.read<MonstersBloc>().add(MonstersEvent.searchChanged(search: v)),
              ),
              if (state.monsters.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  sliver: SliverStaggeredGrid.countBuilder(
                    crossAxisCount: isPortrait ? 3 : 5,
                    itemBuilder: (ctx, index) => MonsterCard.item(item: state.monsters[index]),
                    itemCount: state.monsters.length,
                    crossAxisSpacing: isPortrait ? 10 : 5,
                    mainAxisSpacing: 5,
                    staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
                  ),
                )
              else
                const SliverNothingFound(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showFiltersModal(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => MonsterBottomSheet(),
    );
  }
}
