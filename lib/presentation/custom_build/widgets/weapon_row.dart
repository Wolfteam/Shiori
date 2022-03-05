import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/dialogs/number_picker_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

enum _Options {
  delete,
  refinements,
  level,
}

class WeaponRow extends StatelessWidget {
  final CustomBuildWeaponModel weapon;
  final Color color;
  final double maxImageWidth;
  final int weaponCount;
  final bool readyForScreenshot;

  const WeaponRow({
    Key? key,
    required this.weapon,
    required this.color,
    required this.maxImageWidth,
    required this.weaponCount,
    required this.readyForScreenshot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final color = weapon.rarity.getRarityColors().last;
    String level = '${weapon.stat.level}';
    if (weapon.stat.isAnAscension) {
      level += ' +';
    }
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
              _TopDecoration.right(
                color: color,
                text: level,
                tooltip: s.level,
              ),
              if (weapon.refinement > 0)
                _TopDecoration.left(
                  color: color,
                  text: weapon.refinement.toString(),
                  tooltip: s.refinements,
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
                  '${s.translateStatTypeWithoutValue(StatType.atk)}: ${weapon.stat.baseAtk}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '${s.subStat}: ${s.translateStatType(weapon.subStatType, weapon.stat.statValue)}',
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
        if (!readyForScreenshot)
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
                case _Options.level:
                  icon = const Icon(Icons.arrow_upward);
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
                case _Options.level:
                  return s.level;
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
      case _Options.level:
        final newValue = await showDialog<WeaponFileStatModel>(
          context: context,
          builder: (_) => _LevelDialog(
            statType: weapon.subStatType,
            stat: weapon.stat,
            stats: weapon.stats,
          ),
        );
        if (newValue == null) {
          return;
        }

        bloc.add(CustomBuildEvent.weaponStatChanged(key: weapon.key, newValue: newValue));
        break;
      default:
        throw Exception('The weapon option is not valid');
    }
  }
}

class _TopDecoration extends StatelessWidget {
  final Color color;
  final String tooltip;
  final String text;
  final Alignment alignment;

  const _TopDecoration.right({
    Key? key,
    required this.color,
    required this.tooltip,
    required this.text,
  })  : alignment = Alignment.topRight,
        super(key: key);

  const _TopDecoration.left({
    Key? key,
    required this.color,
    required this.tooltip,
    required this.text,
  })  : alignment = Alignment.topLeft,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final margin = alignment == Alignment.topRight ? const EdgeInsets.only(top: 5, right: 5) : const EdgeInsets.only(top: 5, left: 5);
    final borderRadius = alignment == Alignment.topRight
        ? const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          );
    return Align(
      alignment: alignment,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: color),
          borderRadius: borderRadius,
        ),
        child: Tooltip(
          message: tooltip,
          child: Text(
            text,
            style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _LevelDialog extends StatefulWidget {
  final StatType statType;
  final WeaponFileStatModel stat;
  final List<WeaponFileStatModel> stats;

  const _LevelDialog({
    Key? key,
    required this.statType,
    required this.stat,
    required this.stats,
  }) : super(key: key);

  @override
  _LevelDialogState createState() => _LevelDialogState();
}

class _LevelDialogState extends State<_LevelDialog> {
  late WeaponFileStatModel _currentValue;

  @override
  void initState() {
    _currentValue = widget.stat;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.level),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop<WeaponFileStatModel>(context, _currentValue),
          child: Text(s.ok),
        )
      ],
      content: SizedBox(
        width: mq.getWidthForDialogs(),
        height: mq.getHeightForDialogs(widget.stats.length),
        child: ListView.builder(
          itemCount: widget.stats.length,
          itemBuilder: (ctx, index) {
            final item = widget.stats.elementAt(index);
            String subtitle = '${s.baseAtk}: ${item.baseAtk}';
            if (widget.statType != StatType.none) {
              final stat = s.translateStatType(widget.statType, item.statValue);
              subtitle += ' / $stat';
            }
            return ListTile(
              selected: item == _currentValue,
              trailing: item.isAnAscension ? const Icon(Icons.arrow_upward) : null,
              title: Text('${s.level}: ${item.level}'),
              subtitle: Text(subtitle),
              onTap: () => setState(() => _currentValue = item),
            );
          },
        ),
      ),
    );
  }
}
