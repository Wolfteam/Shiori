import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/custom_build/widgets/weapon_row.dart';
import 'package:shiori/presentation/shared/nothing_found.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapons/weapons_page.dart';

class WeaponSection extends StatelessWidget {
  final List<WeaponCardModel> weapons;
  final Color color;
  final double maxItemImageWidth;

  const WeaponSection({
    Key? key,
    required this.weapons,
    required this.color,
    required this.maxItemImageWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    //TODO: WEAPON REFINEMENTS
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
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
            s.weapons,
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
                onPressed: () => _openWeaponsPage(context),
              ),
            ),
            Tooltip(
              message: s.clearAll,
              child: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: Styles.smallButtonSplashRadius,
                icon: const Icon(Icons.clear_all),
                onPressed: weapons.isEmpty ? null : () => context.read<CustomBuildBloc>().add(const CustomBuildEvent.deleteWeapons()),
              ),
            ),
          ],
        ),
        if (weapons.isEmpty) NothingFound(msg: s.startByAddingWeapons),
        ...weapons
            .map(
              (e) => WeaponRow(
                weapon: e,
                color: color,
                maxImageWidth: maxItemImageWidth,
                weaponCount: weapons.length,
              ),
            )
            .toList(),
      ],
    );
  }

  Future<void> _openWeaponsPage(BuildContext context) async {
    final bloc = context.read<CustomBuildBloc>();
    final selectedKey = await WeaponsPage.forSelection(context, excludeKeys: weapons.map((e) => e.key).toList());
    if (selectedKey.isNullEmptyOrWhitespace) {
      return;
    }
    bloc.add(CustomBuildEvent.addWeapon(key: selectedKey!));
  }
}
