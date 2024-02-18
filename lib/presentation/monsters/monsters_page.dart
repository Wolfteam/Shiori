import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/monsters/widgets/monster_card.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/sliver_nothing_found.dart';
import 'package:shiori/presentation/shared/sliver_page_filter.dart';
import 'package:shiori/presentation/shared/sliver_scaffold_with_fab.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';

class MonstersPage extends StatelessWidget {
  final bool isInSelectionMode;
  final List<String> excludeKeys;

  static Future<String?> forSelection(BuildContext context, {List<String> excludeKeys = const []}) async {
    final route = MaterialPageRoute<String>(
      builder: (ctx) => MonstersPage(isInSelectionMode: true, excludeKeys: excludeKeys),
    );
    final keyName = await Navigator.of(context).push(route);
    await route.completed;
    return keyName;
  }

  const MonstersPage({
    super.key,
    this.isInSelectionMode = false,
    this.excludeKeys = const [],
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (context) => Injection.monstersBloc..add(MonstersEvent.init(excludeKeys: excludeKeys)),
      child: BlocBuilder<MonstersBloc, MonstersState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(),
          loaded: (state) => SliverScaffoldWithFab(
            appbar: AppBar(title: Text(isInSelectionMode ? s.selectAMonster : s.monsters)),
            slivers: [
              SliverPageFilter(
                search: state.search,
                title: s.monsters,
                onPressed: () => ModalBottomSheetUtils.showAppModalBottomSheet(context, EndDrawerItemType.monsters),
                searchChanged: (v) => context.read<MonstersBloc>().add(MonstersEvent.searchChanged(search: v)),
              ),
              if (state.monsters.isNotEmpty)
                SliverPadding(
                  padding: Styles.edgeInsetHorizontal5,
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: MonsterCard.itemWidth,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: MonsterCard.itemHeight,
                      childAspectRatio: MonsterCard.itemWidth / MonsterCard.itemHeight,
                    ),
                    itemCount: state.monsters.length,
                    itemBuilder: (context, index) => MonsterCard.item(
                      item: state.monsters[index],
                      isInSelectionMode: isInSelectionMode,
                    ),
                  ),
                )
              else
                const SliverNothingFound(),
            ],
          ),
        ),
      ),
    );
  }
}
