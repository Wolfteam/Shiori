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

import 'widgets/character_bottom_sheet.dart';
import 'widgets/character_card.dart';

class CharactersPage extends StatefulWidget {
  final bool isInSelectionMode;

  const CharactersPage({
    Key key,
    this.isInSelectionMode = false,
  }) : super(key: key);

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
    final child = BlocBuilder<CharactersBloc, CharactersState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (state) => SliverScaffoldWithFab(
            slivers: [
              SliverPageFilter(
                search: state.search,
                title: s.characters,
                onPressed: () => _showFiltersModal(context),
                searchChanged: (v) => context.read<CharactersBloc>().add(CharactersEvent.searchChanged(search: v)),
              ),
              if (state.characters.isNotEmpty) _buildGrid(state.characters, context) else const SliverNothingFound(),
            ],
          ),
        );
      },
    );

    if (widget.isInSelectionMode) {
      return Scaffold(
        appBar: AppBar(
          title: Text(s.selectCharacter),
        ),
        body: SafeArea(
          child: child,
        ),
      );
    }

    return child;
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
            keyName: char.key,
            elementType: char.elementType,
            isComingSoon: char.isComingSoon,
            isNew: char.isNew,
            image: char.logoName,
            name: char.name,
            rarity: char.stars,
            weaponType: char.weaponType,
            materials: char.materials,
            isInSelectionMode: widget.isInSelectionMode,
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
      builder: (_) => const CharacterBottomSheet(),
    );
  }
}
