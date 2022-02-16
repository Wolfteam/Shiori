import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/sliver_nothing_found.dart';
import 'package:shiori/presentation/shared/sliver_page_filter.dart';
import 'package:shiori/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'widgets/character_card.dart';

class CharactersPage extends StatefulWidget {
  final bool isInSelectionMode;

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
    Key? key,
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
    return BlocBuilder<CharactersBloc, CharactersState>(
      builder: (context, state) => state.map(
        loading: (_) => const Loading(),
        loaded: (state) => SliverScaffoldWithFab(
          appbar: widget.isInSelectionMode ? AppBar(title: Text(s.selectCharacter)) : null,
          slivers: [
            SliverPageFilter(
              search: state.search,
              title: s.characters,
              onPressed: () => ModalBottomSheetUtils.showAppModalBottomSheet(context, EndDrawerItemType.characters),
              searchChanged: (v) => context.read<CharactersBloc>().add(CharactersEvent.searchChanged(search: v)),
            ),
            if (state.characters.isNotEmpty) _buildGrid(state.characters, context) else const SliverNothingFound(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<CharacterCardModel> characters, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverWaterfallFlow(
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisCount: SizeUtils.getCrossAxisCountForGrids(context, isOnMainPage: !widget.isInSelectionMode),
          crossAxisSpacing: isPortrait ? 10 : 5,
          mainAxisSpacing: 5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => CharacterCard.item(char: characters[index], isInSelectionMode: widget.isInSelectionMode),
          childCount: characters.length,
        ),
      ),
    );
  }
}
