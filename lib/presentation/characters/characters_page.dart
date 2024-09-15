import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/characters/widgets/character_card.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/sliver_nothing_found.dart';
import 'package:shiori/presentation/shared/sliver_page_filter.dart';
import 'package:shiori/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';

class CharactersPage extends StatefulWidget {
  final bool isInSelectionMode;
  final ScrollController? scrollController;

  static Future<String?> forSelection(BuildContext context, {List<String> excludeKeys = const []}) async {
    final bloc = context.read<CharactersBloc>();
    //TODO: RECEIVE THE EXCLUDEKEYS IN THE CONSTRUCTOR AND REMOVE THIS BLOC FROM HERE
    bloc.add(CharactersEvent.init(excludeKeys: excludeKeys));

    final route = MaterialPageRoute<String>(builder: (ctx) => const CharactersPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);
    await route.completed;

    bloc.add(const CharactersEvent.init());

    return keyName;
  }

  const CharactersPage({
    super.key,
    this.isInSelectionMode = false,
    this.scrollController,
  });

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
    final size = MediaQuery.of(context).size;
    double itemHeight = CharacterCard.maxHeight;
    if (size.height / 2.5 < CharacterCard.maxHeight) {
      itemHeight = CharacterCard.minHeight;
    }

    return BlocBuilder<CharactersBloc, CharactersState>(
      builder: (context, state) => state.map(
        loading: (_) => const Loading(),
        loaded: (state) => SliverScaffoldWithFab(
          scrollController: widget.scrollController,
          appbar: widget.isInSelectionMode ? AppBar(title: Text(s.selectCharacter)) : null,
          slivers: [
            SliverPageFilter(
              search: state.search,
              title: s.characters,
              onPressed: () => ModalBottomSheetUtils.showAppModalBottomSheet(context, EndDrawerItemType.characters).then((_) {
                if (context.mounted) {
                  context.read<CharactersBloc>().add(const CharactersEvent.cancelChanges());
                }
              }),
              searchChanged: (v) => context.read<CharactersBloc>().add(CharactersEvent.searchChanged(search: v)),
            ),
            if (state.characters.isNotEmpty)
              SliverPadding(
                padding: Styles.edgeInsetHorizontal5,
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: CharacterCard.itemWidth,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: itemHeight,
                    childAspectRatio: CharacterCard.itemWidth / itemHeight,
                  ),
                  itemCount: state.characters.length,
                  itemBuilder: (context, index) => CharacterCard.item(
                    char: state.characters[index],
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
