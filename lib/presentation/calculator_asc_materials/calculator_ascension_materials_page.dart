import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/characters/characters_page.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';
import 'package:genshindb/presentation/shared/hawk_fab_menu.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/nothing_found_column.dart';
import 'package:genshindb/presentation/shared/sliver_row_grid.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/weapons/weapons_page.dart';

import 'widgets/add_edit_item_bottom_sheet.dart';
import 'widgets/ascension_materials_summary.dart';
import 'widgets/item_card.dart';
import 'widgets/reorder_items_dialog.dart';

class CalculatorAscensionMaterialsPage extends StatelessWidget {
  final int sessionKey;

  const CalculatorAscensionMaterialsPage({
    Key? key,
    required this.sessionKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.ascensionMaterials),
        actions: [
          BlocBuilder<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
            builder: (context, state) => state.items.length > 1
                ? IconButton(
                    icon: const Icon(Icons.unfold_more),
                    onPressed: () => _showReorderDialog(state.items, context),
                  )
                : Container(),
          ),
        ],
      ),
      body: SafeArea(
        child: HawkFabMenu(
          icon: AnimatedIcons.menu_arrow,
          fabColor: theme.accentColor,
          iconColor: Colors.white,
          items: [
            HawkFabMenuItem(
              label: s.addCharacter,
              ontap: () => _openCharacterPage(context),
              icon: const Icon(Icons.people),
              color: theme.accentColor,
              labelColor: theme.accentColor,
            ),
            HawkFabMenuItem(
              label: s.addWeapon,
              ontap: () => _openWeaponPage(context),
              icon: const Icon(GenshinDb.crossed_swords),
              color: theme.accentColor,
              labelColor: theme.accentColor,
            ),
          ],
          body: BlocBuilder<CalculatorAscMaterialsBloc, CalculatorAscMaterialsState>(
            builder: (context, state) {
              return state.map(
                initial: (state) {
                  if (state.items.isEmpty) {
                    return NothingFoundColumn(msg: s.startByAddingMsg, icon: Icons.add_circle_outline);
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 10),
                        sliver: SliverToBoxAdapter(
                          child: ItemDescriptionDetail(
                            title: '${s.characters} / ${s.weapons}',
                            textColor: theme.accentColor,
                            body: null,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: Styles.edgeInsetHorizontal16,
                        sliver: SliverRowGrid(
                          crossAxisCount: isPortrait ? 2 : 3,
                          crossAxisSpacing: isPortrait ? 10 : 5,
                          itemsCount: state.items.length,
                          builder: (index) {
                            final e = state.items[index];
                            return ItemCard(
                              sessionKey: sessionKey,
                              isActive: e.isActive,
                              index: index,
                              itemKey: e.key,
                              image: e.image,
                              name: e.name,
                              rarity: e.rarity,
                              isWeapon: !e.isCharacter,
                              materials: e.materials,
                            );
                          },
                        ),
                      ),
                      if (state.summary.isNotEmpty)
                        SliverToBoxAdapter(
                          child: ItemDescriptionDetail(
                            title: s.summary,
                            textColor: theme.accentColor,
                            body: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _buildSummary(s, state.summary),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  List<AscensionMaterialsSummaryWidget> _buildSummary(S s, List<AscensionMaterialsSummary> items) {
    items.sort((x, y) => s.translateAscensionSummaryType(x.type).compareTo(s.translateAscensionSummaryType(y.type)));

    return items.map((e) => AscensionMaterialsSummaryWidget(summary: e)).toList();
  }

  Future<void> _openCharacterPage(BuildContext context) async {
    final charactersBloc = context.read<CharactersBloc>();
    charactersBloc.add(CharactersEvent.init(excludeKeys: context.read<CalculatorAscMaterialsBloc>().getItemsKeysToExclude()));

    final route = MaterialPageRoute<String>(builder: (ctx) => const CharactersPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);

    charactersBloc.add(const CharactersEvent.init());
    if (keyName.isNullEmptyOrWhitespace) {
      return;
    }

    context.read<CalculatorAscMaterialsItemBloc>().add(CalculatorAscMaterialsItemEvent.load(key: keyName!, isCharacter: true));

    await showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => AddEditItemBottomSheet.toAddItem(sessionKey: sessionKey, keyName: keyName, isAWeapon: false),
    );
  }

  Future<void> _openWeaponPage(BuildContext context) async {
    final weaponsBloc = context.read<WeaponsBloc>();
    weaponsBloc.add(WeaponsEvent.init(excludeKeys: context.read<CalculatorAscMaterialsBloc>().getItemsKeysToExclude()));

    final route = MaterialPageRoute<String>(builder: (ctx) => const WeaponsPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);

    weaponsBloc.add(const WeaponsEvent.init());
    if (keyName.isNullEmptyOrWhitespace) {
      return;
    }

    context.read<CalculatorAscMaterialsItemBloc>().add(CalculatorAscMaterialsItemEvent.load(key: keyName!, isCharacter: false));

    await showModalBottomSheet<bool>(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => AddEditItemBottomSheet.toAddItem(sessionKey: sessionKey, keyName: keyName, isAWeapon: true),
    );
  }

  Future<void> _showReorderDialog(List<ItemAscensionMaterials> items, BuildContext context) async {
    context.read<CalculatorAscMaterialsOrderBloc>().add(CalculatorAscMaterialsOrderEvent.init(sessionKey: sessionKey, items: items));
    await showDialog(context: context, builder: (_) => ReorderItemsDialog());
  }
}
