import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/characters/characters_page.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/styles.dart';

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
    final size = MediaQuery.of(context).size;
    double itemHeight = CharacterCard.maxHeight;
    if (size.height / 2.5 < CharacterCard.maxHeight) {
      itemHeight = CharacterCard.minHeight;
    }
    return Padding(
      padding: Styles.edgeInsetHorizontal5,
      child: Scaffold(
        floatingActionButton: AppFab(
          onPressed: () => _openCharactersPage(context),
          icon: const Icon(Icons.add),
          hideFabAnimController: hideFabAnimController,
          scrollController: scrollController,
          mini: false,
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (ctx, state) => GridView.builder(
            controller: scrollController,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: CharacterCard.itemWidth,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: itemHeight,
              childAspectRatio: CharacterCard.itemWidth / itemHeight,
            ),
            itemCount: state.characters.length,
            itemBuilder: (context, index) => CharacterCard.item(char: state.characters[index]),
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
