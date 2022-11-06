import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/sliver_nothing_found.dart';
import 'package:shiori/presentation/shared/sliver_page_filter.dart';
import 'package:shiori/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_bottom_sheet.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class WeaponsPage extends StatefulWidget {
  final bool isInSelectionMode;
  final bool areWeaponTypesEnabled;

  static Future<String?> forSelection(
    BuildContext context, {
    List<String> excludeKeys = const [],
    List<WeaponType> weaponTypes = const [],
    bool areWeaponTypesEnabled = true,
  }) async {
    final bloc = context.read<WeaponsBloc>();
    bloc.add(WeaponsEvent.init(excludeKeys: excludeKeys, weaponTypes: weaponTypes, areWeaponTypesEnabled: areWeaponTypesEnabled));

    final route = MaterialPageRoute<String>(builder: (ctx) => WeaponsPage(isInSelectionMode: true, areWeaponTypesEnabled: areWeaponTypesEnabled));
    final keyName = await Navigator.of(context).push(route);
    await route.completed;

    bloc.add(const WeaponsEvent.init());

    return keyName;
  }

  const WeaponsPage({
    super.key,
    this.isInSelectionMode = false,
    this.areWeaponTypesEnabled = true,
  });

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
    return BlocBuilder<WeaponsBloc, WeaponsState>(
      builder: (context, state) => state.map(
        loading: (_) => const Loading(),
        loaded: (state) => SliverScaffoldWithFab(
          appbar: widget.isInSelectionMode ? AppBar(title: Text(s.selectWeapon)) : null,
          slivers: [
            SliverPageFilter(
              search: state.search,
              title: s.weapons,
              onPressed: () async {
                final args = WeaponBottomSheet.buildNavigationArgs(areWeaponTypesEnabled: widget.areWeaponTypesEnabled);
                await ModalBottomSheetUtils.showAppModalBottomSheet(context, EndDrawerItemType.weapons, args: args);
              },
              searchChanged: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.searchChanged(search: v)),
            ),
            if (state.weapons.isNotEmpty) _buildGrid(context, state.weapons) else const SliverNothingFound(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<WeaponCardModel> weapons) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverWaterfallFlow(
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisCount: SizeUtils.getCrossAxisCountForGrids(context, isOnMainPage: !widget.isInSelectionMode),
          crossAxisSpacing: isPortrait ? 10 : 5,
          mainAxisSpacing: 5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => WeaponCard.item(weapon: weapons[index], isInSelectionMode: widget.isInSelectionMode),
          childCount: weapons.length,
        ),
      ),
    );
  }
}
