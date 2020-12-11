import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../bloc/bloc.dart';
import '../../common/styles.dart';
import '../../models/artifacts/artifact_card_model.dart';
import '../widgets/artifacts/artifact_bottom_sheet.dart';
import '../widgets/artifacts/artifact_card.dart';
import '../widgets/artifacts/artifact_info_card.dart';
import '../widgets/common/loading.dart';
import '../widgets/common/search_box.dart';

class ArtifactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtifactsBloc, ArtifactsState>(
      builder: (context, state) {
        return state.when(
          loading: () => const Loading(),
          loadedState: (artifacts) => CustomScrollView(
            slivers: [
              _buildFiltersSwitch(context),
              ArtifactInfoCard(),
              _buildGrid(artifacts, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<ArtifactCardModel> artifacts, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: isPortrait ? 2 : 3,
        itemBuilder: (ctx, index) {
          final item = artifacts[index];
          return ArtifactCard(name: item.name, image: item.image, rarity: item.rarity, bonus: item.bonus);
        },
        itemCount: artifacts.length,
        crossAxisSpacing: isPortrait ? 10 : 5,
        mainAxisSpacing: 5,
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      ),
    );
  }

  Widget _buildFiltersSwitch(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SearchBox(),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'All',
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
