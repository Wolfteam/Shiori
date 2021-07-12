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
import 'package:genshindb/presentation/shared/utils/grid_utils.dart';

import 'widgets/artifact_bottom_sheet.dart';
import 'widgets/artifact_card.dart';
import 'widgets/artifact_info_card.dart';

class ArtifactsPage extends StatefulWidget {
  final bool isInSelectionMode;

  static Future<String?> forSelection(BuildContext context, {List<String> excludeKeys = const []}) async {
    final bloc = context.read<ArtifactsBloc>();
    bloc.add(ArtifactsEvent.init(excludeKeys: excludeKeys));

    final route = MaterialPageRoute<String>(builder: (ctx) => const ArtifactsPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);
    await route.completed;

    bloc.add(const ArtifactsEvent.init());

    return keyName;
  }

  const ArtifactsPage({
    Key? key,
    this.isInSelectionMode = false,
  }) : super(key: key);

  @override
  _ArtifactsPageState createState() => _ArtifactsPageState();
}

class _ArtifactsPageState extends State<ArtifactsPage> with AutomaticKeepAliveClientMixin<ArtifactsPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final s = S.of(context);
    return BlocBuilder<ArtifactsBloc, ArtifactsState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (state) => SliverScaffoldWithFab(
            appbar: !widget.isInSelectionMode ? null : AppBar(title: Text(s.selectAnArtifact)),
            slivers: [
              SliverPageFilter(
                search: state.search,
                title: s.artifacts,
                onPressed: () => _showFiltersModal(context),
                searchChanged: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.searchChanged(search: v)),
              ),
              if (!widget.isInSelectionMode)
                ArtifactInfoCard(
                  isCollapsed: state.collapseNotes,
                  expansionCallback: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.collapseNotes(collapse: v)),
                ),
              if (state.artifacts.isNotEmpty) _buildGrid(state.artifacts, context) else const SliverNothingFound(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<ArtifactCardModel> artifacts, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: GridUtils.getCrossAxisCount(context),
        itemBuilder: (ctx, index) => ArtifactCard.item(item: artifacts[index], isInSelectionMode: widget.isInSelectionMode),
        itemCount: artifacts.length,
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
      builder: (_) => ArtifactBottomSheet(),
    );
  }
}
