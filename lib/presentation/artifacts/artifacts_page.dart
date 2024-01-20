import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_info_card.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/sliver_nothing_found.dart';
import 'package:shiori/presentation/shared/sliver_page_filter.dart';
import 'package:shiori/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';

class ArtifactsPage extends StatefulWidget {
  final bool isInSelectionMode;

  static Future<String?> forSelection(BuildContext context, {List<String> excludeKeys = const [], ArtifactType? type}) async {
    final bloc = context.read<ArtifactsBloc>();
    bloc.add(ArtifactsEvent.init(excludeKeys: excludeKeys, type: type));

    final route = MaterialPageRoute<String>(builder: (ctx) => const ArtifactsPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);
    await route.completed;

    bloc.add(const ArtifactsEvent.init());

    return keyName;
  }

  const ArtifactsPage({
    super.key,
    this.isInSelectionMode = false,
  });

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
      builder: (context, state) => state.map(
        loading: (_) => const Loading(),
        loaded: (state) => SliverScaffoldWithFab(
          appbar: !widget.isInSelectionMode ? null : AppBar(title: Text(s.selectAnArtifact)),
          slivers: [
            SliverPageFilter(
              search: state.search,
              title: s.artifacts,
              onPressed: () => ModalBottomSheetUtils.showAppModalBottomSheet(context, EndDrawerItemType.artifacts),
              searchChanged: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.searchChanged(search: v)),
            ),
            if (!widget.isInSelectionMode)
              ArtifactInfoCard(
                isCollapsed: state.collapseNotes,
                expansionCallback: (v) => context.read<ArtifactsBloc>().add(ArtifactsEvent.collapseNotes(collapse: v)),
              ),
            if (state.artifacts.isNotEmpty)
              SliverPadding(
                padding: Styles.edgeInsetHorizontal5,
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: ArtifactCard.itemWidth,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: ArtifactCard.itemHeight,
                    childAspectRatio: ArtifactCard.itemWidth / ArtifactCard.itemHeight,
                  ),
                  itemCount: state.artifacts.length,
                  itemBuilder: (context, index) => ArtifactCard.item(
                    item: state.artifacts[index],
                    isInSelectionMode: widget.isInSelectionMode,
                  ),
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
