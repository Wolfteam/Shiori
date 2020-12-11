import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../bloc/bloc.dart';
import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../../models/characters/character_card_model.dart';
import '../widgets/characters/character_bottom_sheet.dart';
import '../widgets/characters/character_card.dart';
import '../widgets/common/loading.dart';
import '../widgets/common/search_box.dart';

class CharactersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharactersBloc, CharactersState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (s) => CustomScrollView(
            slivers: [
              _buildFiltersSwitch(s.search != null && s.search.isNotEmpty, context),
              _buildGrid(context, s.characters),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<CharacterCardModel> characters) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: isPortrait ? 2 : 3,
        itemBuilder: (ctx, index) {
          final char = characters[index];
          return CharacterCard(
            elementType: char.elementType,
            isComingSoon: char.isComingSoon,
            isNew: char.isNew,
            image: char.logoName,
            name: char.name,
            rarity: char.stars,
            weaponType: char.weaponType,
            materials: char.materials,
          );
        },
        itemCount: characters.length,
        crossAxisSpacing: isPortrait ? 10 : 5,
        mainAxisSpacing: 5,
        staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
      ),
    );
  }

  Widget _buildFiltersSwitch(bool showClearButton, BuildContext context) {
    final s = S.of(context);
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SearchBox(
            showClearButton: showClearButton,
            searchChanged: (newVal) =>
                context.read<CharactersBloc>().add(CharactersEvent.searchChanged(search: newVal)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  s.all,
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
      builder: (_) => CharacterBottomSheet(),
    );
  }
}
