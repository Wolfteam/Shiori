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
import '../widgets/common/sliver_nothing_found.dart';
import '../widgets/common/sliver_page_filter.dart';

class CharactersPage extends StatefulWidget {
  @override
  _CharactersPageState createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> with AutomaticKeepAliveClientMixin<CharactersPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final s = S.of(context);
    return BlocBuilder<CharactersBloc, CharactersState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (state) => CustomScrollView(
            slivers: [
              SliverPageFilter(
                search: state.search,
                title: s.characters,
                onPressed: () => _showFiltersModal(context),
                searchChanged: (v) => context.read<CharactersBloc>().add(CharactersEvent.searchChanged(search: v)),
              ),
              if (s.characters.isNotEmpty) _buildGrid(state.characters, context) else const SliverNothingFound(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<CharacterCardModel> characters, BuildContext context) {
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
