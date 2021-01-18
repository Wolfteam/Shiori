import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../bloc/bloc.dart';
import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../../models/models.dart';
import '../../models/weapons/weapon_card_model.dart';
import '../widgets/common/loading.dart';
import '../widgets/common/sliver_nothing_found.dart';
import '../widgets/common/sliver_page_filter.dart';
import '../widgets/common/sliver_scaffold_with_fab.dart';
import '../widgets/weapons/weapon_bottom_sheet.dart';
import '../widgets/weapons/weapon_card.dart';

class WeaponsPage extends StatefulWidget {
  final bool isInSelectionMode;

  const WeaponsPage({
    Key key,
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
        body: SafeArea(
          child: child,
        ),
      );
    }

    return child;
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
            keyName: weapon.key,
            baseAtk: weapon.baseAtk,
            image: weapon.image,
            name: weapon.name,
            rarity: weapon.rarity,
            type: weapon.type,
            subStatType: weapon.subStatType,
            subStatValue: weapon.subStatValue,
            isInSelectionMode: widget.isInSelectionMode,
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
