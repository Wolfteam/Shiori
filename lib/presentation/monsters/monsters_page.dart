import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/sliver_nothing_found.dart';
import 'package:shiori/presentation/shared/sliver_page_filter.dart';
import 'package:shiori/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';

import 'widgets/monster_card.dart';

class MonstersPage extends StatelessWidget {
  final bool isInSelectionMode;

  static Future<String?> forSelection(BuildContext context, {List<String> excludeKeys = const []}) async {
    final bloc = context.read<MonstersBloc>();
    bloc.add(MonstersEvent.init(excludeKeys: excludeKeys));

    final route = MaterialPageRoute<String>(builder: (ctx) => const MonstersPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);
    await route.completed;

    bloc.add(const MonstersEvent.init());

    return keyName;
  }

  const MonstersPage({
    Key? key,
    this.isInSelectionMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final s = S.of(context);
    return BlocBuilder<MonstersBloc, MonstersState>(
      builder: (context, state) => state.map(
        loading: (_) => const Loading(),
        loaded: (state) => SliverScaffoldWithFab(
          appbar: AppBar(title: Text(isInSelectionMode ? s.selectAMonster : s.monsters)),
          slivers: [
            SliverPageFilter(
              search: state.search,
              title: s.monsters,
              onPressed: () => ModalBottomSheetUtils.showAppModalBottomSheet(context, EndDrawerItemType.monsters),
              searchChanged: (v) => context.read<MonstersBloc>().add(MonstersEvent.searchChanged(search: v)),
            ),
            if (state.monsters.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                sliver: SliverStaggeredGrid.countBuilder(
                  crossAxisCount: isPortrait ? 3 : 5,
                  itemBuilder: (ctx, index) => MonsterCard.item(item: state.monsters[index], isInSelectionMode: isInSelectionMode),
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
      ),
    );
  }
}
