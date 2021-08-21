import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/sliver_nothing_found.dart';
import 'package:genshindb/presentation/shared/sliver_page_filter.dart';
import 'package:genshindb/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/utils/modal_bottom_sheet_utils.dart';
import 'package:genshindb/presentation/shared/utils/size_utils.dart';

import 'widgets/material_card.dart';

class MaterialsPage extends StatelessWidget {
  final bool isInSelectionMode;

  static Future<String?> forSelection(BuildContext context, {List<String> excludeKeys = const []}) async {
    final bloc = context.read<MaterialsBloc>();
    bloc.add(MaterialsEvent.init(excludeKeys: excludeKeys));

    final route = MaterialPageRoute<String>(builder: (ctx) => const MaterialsPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);
    await route.completed;

    bloc.add(const MaterialsEvent.init());

    return keyName;
  }

  const MaterialsPage({
    Key? key,
    this.isInSelectionMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<MaterialsBloc, MaterialsState>(
      builder: (context, state) => state.map(
        loading: (_) => const Loading(),
        loaded: (state) => SliverScaffoldWithFab(
          appbar: AppBar(title: Text(isInSelectionMode ? s.selectAMaterial : s.materials)),
          slivers: [
            SliverPageFilter(
              search: state.search,
              title: s.materials,
              onPressed: () => ModalBottomSheetUtils.showAppModalBottomSheet(context, EndDrawerItemType.materials),
              searchChanged: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.searchChanged(search: v)),
            ),
            if (state.materials.isNotEmpty)
              SliverPadding(
                padding: Styles.edgeInsetHorizontal5,
                sliver: SliverStaggeredGrid.countBuilder(
                  crossAxisCount: SizeUtils.getCrossAxisCountForGrids(context, itemIsSmall: true),
                  itemBuilder: (ctx, index) => MaterialCard.item(item: state.materials[index], isInSelectionMode: isInSelectionMode),
                  itemCount: state.materials.length,
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
