import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/characters/characters_page.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

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
          builder: (ctx, state) => WaterfallFlow.builder(
            controller: scrollController,
            itemBuilder: (context, index) => CharacterCard.item(char: state.characters[index]),
            itemCount: state.characters.length,
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: SizeUtils.getCrossAxisCountForGrids(context),
              crossAxisSpacing: isPortrait ? 10 : 5,
              mainAxisSpacing: 5,
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
