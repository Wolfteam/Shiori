import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dialogs/number_picker_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

enum _Options {
  delete,
  refinements,
}

//TODO: LIMIT THE NUMBER OF ROWS TO 10
//TODO: ADD TEAMS
class WeaponRow extends StatelessWidget {
  final CustomBuildWeaponModel weapon;
  final Color color;
  final double maxImageWidth;
  final int weaponCount;

  const WeaponRow({
    Key? key,
    required this.weapon,
    required this.color,
    required this.maxImageWidth,
    required this.weaponCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: maxImageWidth,
          child: Stack(
            alignment: Alignment.topCenter,
            fit: StackFit.passthrough,
            children: [
              WeaponCard.withoutDetails(
                keyName: weapon.key,
                name: weapon.name,
                rarity: weapon.rarity,
                image: weapon.image,
                isComingSoon: false,
                withShape: false,
                imgWidth: 94,
                imgHeight: 84,
              ),
              if (weapon.refinement > 0)
                Tooltip(
                  message: s.refinements,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      backgroundColor: weapon.rarity.getRarityColors().last,
                      radius: 10,
                      child: Text(
                        weapon.refinement.toString(),
                        style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: Styles.edgeInsetHorizontal16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weapon.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${s.translateStatTypeWithoutValue(StatType.atk)}: ${weapon.baseAtk}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '${s.subStat}: ${s.translateStatType(weapon.subStatType, weapon.subStatValue)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        ItemPopupMenuFilter<_Options>.withoutSelectedValue(
          values: _Options.values,
          tooltipText: s.options,
          icon: const Icon(Icons.more_vert),
          onSelected: (type) => _handleOptionSelected(context, type),
          isItemEnabled: (type) {
            if (type == _Options.refinements && !canWeaponBeRefined(weapon.rarity)) {
              return false;
            }
            return true;
          },
          childBuilder: (e) {
            Widget icon;
            switch (e.enumValue) {
              case _Options.delete:
                icon = const Icon(Icons.delete);
                break;
              case _Options.refinements:
                icon = const Icon(Icons.notes);
                break;
              default:
                throw Exception('The provided weapon option type = ${e.enumValue} is not valid');
            }

            return Row(
              children: [
                icon,
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(e.translation, overflow: TextOverflow.ellipsis),
                ),
              ],
            );
          },
          itemText: (type, _) {
            switch (type) {
              case _Options.delete:
                return s.delete;
              case _Options.refinements:
                return s.refinements;
              default:
                throw Exception('The provided weapon option type = $type is not valid');
            }
          },
        ),
      ],
    );
  }

  Future<void> _handleOptionSelected(BuildContext context, _Options option) async {
    final s = S.of(context);
    final bloc = context.read<CustomBuildBloc>();
    switch (option) {
      case _Options.delete:
        bloc.add(CustomBuildEvent.deleteWeapon(key: weapon.key));
        break;
      case _Options.refinements:
        final newValue = await showDialog<int>(
          context: context,
          builder: (_) => NumberPickerDialog(
            minItemLevel: minWeaponRefinementLevel,
            maxItemLevel: getWeaponMaxRefinementLevel(weapon.rarity),
            value: weapon.refinement,
            title: s.refinements,
          ),
        );
        if (newValue == null) {
          return;
        }
        bloc.add(CustomBuildEvent.weaponRefinementChanged(key: weapon.key, newValue: newValue));
        break;
      default:
        throw Exception('The weapon option is not valid');
    }
  }
}
