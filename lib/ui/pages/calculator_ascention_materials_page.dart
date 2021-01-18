import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:genshindb/common/styles.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';

import '../../bloc/bloc.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/genshin_db_icons.dart';
import '../../generated/l10n.dart';
import '../widgets/ascension_materials/add_edit_item_bottom_sheet.dart';
import '../widgets/ascension_materials/item_card.dart';
import '../widgets/common/nothing_found_column.dart';
import 'characters_page.dart';
import 'weapons_page.dart';

class CalculatorAscensionMaterialsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(title: Text(s.ascensionMaterials)),
      // body: SafeArea(
      //   child: Container(
      //     padding: Styles.edgeInsetAll10,
      //     child: SingleChildScrollView(
      //       child: Column(
      //         children: [],
      //       ),
      //     ),
      //   ),
      // ),
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
                    return NothingFoundColumn(
                      msg: s.startByAddingMsg,
                      icon: Icons.add_circle_outline,
                    );
                  }
                  // final items = s.items
                  //     .map((e) => ItemCard(
                  //           itemKey: e.key,
                  //           image: e.image,
                  //           name: e.name,
                  //           rarity: e.rarity,
                  //           materials: e.materials,
                  //         ))
                  //     .toList();
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: isPortrait ? 2 : 3,
                    itemBuilder: (ctx, index) {
                      final e = state.items[index];
                      return ItemCard(
                        index: index,
                        itemKey: e.key,
                        image: e.image,
                        name: e.name,
                        rarity: e.rarity,
                        isWeapon: !e.isCharacter,
                        materials: e.materials,
                      );
                    },
                    itemCount: state.items.length,
                    crossAxisSpacing: isPortrait ? 10 : 5,
                    mainAxisSpacing: 5,
                    staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openCharacterPage(BuildContext context) async {
    context.read<CharactersBloc>().add(const CharactersEvent.init());
    final route = MaterialPageRoute<String>(builder: (ctx) => const CharactersPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);

    context.read<CharactersBloc>().add(const CharactersEvent.init());
    if (keyName.isNullEmptyOrWhitespace) {
      return;
    }

    context.read<CalculatorAscMaterialsItemBloc>().add(CalculatorAscMaterialsItemEvent.load(key: keyName, isCharacter: true));

    await showModalBottomSheet(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => AddEditItemBottomSheet.toAddItem(keyName: keyName, isAWeapon: false),
    );
  }

  Future<void> _openWeaponPage(BuildContext context) async {
    context.read<WeaponsBloc>().add(const WeaponsEvent.init());
    final route = MaterialPageRoute<String>(builder: (ctx) => const WeaponsPage(isInSelectionMode: true));
    final keyName = await Navigator.of(context).push(route);

    context.read<WeaponsBloc>().add(const WeaponsEvent.init());
    if (keyName.isNullEmptyOrWhitespace) {
      return;
    }

    context.read<CalculatorAscMaterialsItemBloc>().add(CalculatorAscMaterialsItemEvent.load(key: keyName, isCharacter: false));

    await showModalBottomSheet<bool>(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => AddEditItemBottomSheet.toAddItem(keyName: keyName, isAWeapon: true),
    );
  }
}
