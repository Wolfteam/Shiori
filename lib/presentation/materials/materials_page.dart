import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/sliver_nothing_found.dart';
import 'package:shiori/presentation/shared/sliver_page_filter.dart';
import 'package:shiori/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'widgets/material_card.dart';

class MaterialsPage extends StatelessWidget {
  final bool isInSelectionMode;
  final List<String> excludeKeys;

  static Future<String?> forSelection(BuildContext context, {List<String> excludeKeys = const []}) async {
    final route = MaterialPageRoute<String>(builder: (ctx) => const MaterialsPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);
    await route.completed;
    return keyName;
  }

  const MaterialsPage({
    Key? key,
    this.isInSelectionMode = false,
    this.excludeKeys = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocProvider<MaterialsBloc>(
      create: (context) => Injection.materialsBloc..add(MaterialsEvent.init(excludeKeys: excludeKeys)),
      child: BlocBuilder<MaterialsBloc, MaterialsState>(
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
                  sliver: SliverWaterfallFlow(
                    gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                      crossAxisCount: SizeUtils.getCrossAxisCountForGrids(context, itemIsSmall: true),
                      crossAxisSpacing: isPortrait ? 10 : 5,
                      mainAxisSpacing: 5,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => MaterialCard.item(item: state.materials[index], isInSelectionMode: isInSelectionMode),
                      childCount: state.materials.length,
                    ),
                  ),
                )
              else
                const SliverNothingFound(),
            ],
          ),
        ),
      ),
    );
  }
}
