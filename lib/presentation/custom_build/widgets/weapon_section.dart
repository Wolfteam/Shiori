import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/custom_build/widgets/weapon_row.dart';
import 'package:shiori/presentation/shared/dialogs/sort_items_dialog.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapons/weapons_page.dart';

class WeaponSection extends StatelessWidget {
  final double maxItemImageWidth;

  const WeaponSection({
    Key? key,
    required this.maxItemImageWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<CustomBuildBloc, CustomBuildState>(
      builder: (context, state) => state.maybeMap(
        loaded: (state) {
          final color = state.character.elementType.getElementColorFromContext(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: Styles.edgeInsetVertical10,
                // margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: color,
                  border: isPortrait ? const Border(top: BorderSide(color: Colors.white)) : null,
                ),
                child: Text(
                  '${s.weapons} (${state.weapons.length} / ${CustomBuildBloc.maxNumberOfWeapons})',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ButtonBar(
                buttonPadding: EdgeInsets.zero,
                children: [
                  Tooltip(
                    message: s.add,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: Styles.smallButtonSplashRadius,
                      icon: const Icon(Icons.add),
                      onPressed: () => _openWeaponsPage(context, state.weapons.map((e) => e.key).toList(), state.character.weaponType),
                    ),
                  ),
                  Tooltip(
                    message: s.sort,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: Styles.smallButtonSplashRadius,
                      icon: const Icon(Icons.sort),
                      onPressed: state.weapons.length < 2
                          ? null
                          : () => showDialog(
                                context: context,
                                builder: (_) => SortItemsDialog(
                                  items: state.weapons.map((e) => SortableItem(e.key, e.name)).toList(),
                                  onSave: (result) {
                                    if (!result.somethingChanged) {
                                      return;
                                    }

                                    context.read<CustomBuildBloc>().add(CustomBuildEvent.weaponsOrderChanged(weapons: result.items));
                                  },
                                ),
                              ),
                    ),
                  ),
                  Tooltip(
                    message: s.clearAll,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: Styles.smallButtonSplashRadius,
                      icon: const Icon(Icons.clear_all),
                      onPressed: state.weapons.isEmpty ? null : () => context.read<CustomBuildBloc>().add(const CustomBuildEvent.deleteWeapons()),
                    ),
                  ),
                ],
              ),
              if (state.weapons.isEmpty)
                NothingFound(msg: s.startByAddingWeapons)
              else
                ...state.weapons
                    .map(
                      (e) => WeaponRow(
                        weapon: e,
                        color: color,
                        maxImageWidth: maxItemImageWidth,
                        weaponCount: state.weapons.length,
                      ),
                    )
                    .toList(),
            ],
          );
        },
        orElse: () => const Loading(useScaffold: false),
      ),
    );
  }

  Future<void> _openWeaponsPage(BuildContext context, List<String> excludedKeys, WeaponType weaponType) async {
    final bloc = context.read<CustomBuildBloc>();
    final selectedKey = await WeaponsPage.forSelection(
      context,
      excludeKeys: excludedKeys,
      weaponTypes: [weaponType],
      areWeaponTypesEnabled: false,
    );
    if (selectedKey.isNullEmptyOrWhitespace) {
      return;
    }
    bloc.add(CustomBuildEvent.addWeapon(key: selectedKey!));
  }
}
