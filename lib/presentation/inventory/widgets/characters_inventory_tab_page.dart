import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/presentation/characters/characters_page.dart';
import 'package:genshindb/presentation/characters/widgets/character_card.dart';
import 'package:genshindb/presentation/shared/app_fab.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:genshindb/presentation/shared/utils/size_utils.dart';

class CharactersInventoryTabPage extends StatefulWidget {
  @override
  _CharactersInventoryTabPageState createState() => _CharactersInventoryTabPageState();
}

class _CharactersInventoryTabPageState extends State<CharactersInventoryTabPage> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  bool get isInitiallyVisible => true;

  @override
  bool get hideOnTop => false;

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Scaffold(
        floatingActionButton: AppFab(
          onPressed: () => _openCharactersPage(context),
          icon: const Icon(Icons.add),
          hideFabAnimController: hideFabAnimController,
          scrollController: scrollController,
          mini: false,
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) => StaggeredGridView.countBuilder(
              controller: scrollController,
              crossAxisCount: SizeUtils.getCrossAxisCountForGrids(context),
              itemBuilder: (ctx, index) => CharacterCard.item(char: state.characters[index]),
              itemCount: state.characters.length,
              crossAxisSpacing: isPortrait ? 10 : 5,
              mainAxisSpacing: 5,
              staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCharactersPage(BuildContext context) async {
    final inventoryBloc = context.read<InventoryBloc>();
    final charactersBloc = context.read<CharactersBloc>();
    charactersBloc.add(CharactersEvent.init(excludeKeys: inventoryBloc.getItemsKeysToExclude()));
    final route = MaterialPageRoute<String>(builder: (_) => const CharactersPage(isInSelectionMode: true));
    final keyName = await Navigator.push(context, route);

    charactersBloc.add(const CharactersEvent.init());
    if (keyName.isNullEmptyOrWhitespace) {
      return;
    }

    inventoryBloc.add(InventoryEvent.addCharacter(key: keyName!));
  }
}
