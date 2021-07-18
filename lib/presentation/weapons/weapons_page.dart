import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/sliver_nothing_found.dart';
import 'package:genshindb/presentation/shared/sliver_page_filter.dart';
import 'package:genshindb/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/utils/size_utils.dart';

import 'widgets/weapon_bottom_sheet.dart';
import 'widgets/weapon_card.dart';

class WeaponsPage extends StatefulWidget {
  final bool isInSelectionMode;

  static Future<String?> forSelection(BuildContext context, {List<String> excludeKeys = const []}) async {
    final bloc = context.read<WeaponsBloc>();
    bloc.add(WeaponsEvent.init(excludeKeys: excludeKeys));

    final route = MaterialPageRoute<String>(builder: (ctx) => const WeaponsPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);
    await route.completed;

    bloc.add(const WeaponsEvent.init());

    return keyName;
  }

  const WeaponsPage({
    Key? key,
    this.isInSelectionMode = false,
  }) : super(key: key);

  @override
  _WeaponsPageState createState() => _WeaponsPageState();
}

class _WeaponsPageState extends State<WeaponsPage> with AutomaticKeepAliveClientMixin<WeaponsPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = S.of(context);
    final child = BlocBuilder<WeaponsBloc, WeaponsState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (state) => SliverScaffoldWithFab(
            slivers: [
              SliverPageFilter(
                search: state.search,
                title: s.weapons,
                onPressed: () => _showFiltersModal(context),
                searchChanged: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.searchChanged(search: v)),
              ),
              if (state.weapons.isNotEmpty) _buildGrid(context, state.weapons) else const SliverNothingFound(),
            ],
          ),
        );
      },
    );

    if (widget.isInSelectionMode) {
      return Scaffold(
        appBar: AppBar(
          title: Text(s.selectWeapon),
        ),
        body: child,
      );
    }

    return child;
  }

  Widget _buildGrid(BuildContext context, List<WeaponCardModel> weapons) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: SizeUtils.getCrossAxisCountForGrids(context),
        itemBuilder: (ctx, index) {
          final weapon = weapons[index];
          return WeaponCard(
            keyName: weapon.key,
            baseAtk: weapon.baseAtk,
            image: weapon.image,
            name: weapon.name,
            rarity: weapon.rarity,
            type: weapon.type,
            subStatType: weapon.subStatType,
            subStatValue: weapon.subStatValue,
            isInSelectionMode: widget.isInSelectionMode,
            isComingSoon: weapon.isComingSoon,
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
