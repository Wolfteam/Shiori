import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/common_table_cell.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/increment_button.dart';
import 'package:shiori/presentation/shared/styles.dart';

class StatValue {
  final String title;
  final String value;

  const StatValue({required this.title, required this.value});
}

class StatItem {
  final int level;
  final bool isAnAscension;
  final List<StatValue> values;

  const StatItem({
    required this.level,
    required this.isAnAscension,
    required this.values,
  });

  StatItem.character(CharacterFileStatModel charStat, StatType mainSubStatType, S s)
      : level = charStat.level,
        isAnAscension = charStat.isAnAscension,
        values = _generateStatItems(
          <StatType, double>{
            StatType.hp: charStat.baseHp,
            StatType.atk: charStat.baseAtk,
            StatType.def: charStat.baseDef,
            mainSubStatType: charStat.statValue,
          },
          mainSubStatType,
          s,
        );

  StatItem.characterSkill(CharacterSkillStatModel skill, S s)
      : level = skill.level,
        isAnAscension = false,
        values = skill.descriptions.map((desc) {
          final split = desc.split('|');
          final String title = split.first;
          final String value = split.last;
          return StatValue(title: title, value: value);
        }).toList();

  StatItem.weapon(WeaponFileStatModel weaponStat, StatType mainSubStatType, S s)
      : level = weaponStat.level,
        isAnAscension = weaponStat.isAnAscension,
        values = _generateStatItems(
          <StatType, double>{
            StatType.atk: weaponStat.baseAtk,
            mainSubStatType: weaponStat.statValue,
          },
          mainSubStatType,
          s,
        );

  static List<StatValue> _generateStatItems(Map<StatType, double> statsMap, StatType mainSubStatType, S s) {
    final items = <StatValue>[];
    for (final kvp in statsMap.entries) {
      final String typeText = s.translateStatTypeWithoutValue(kvp.key, removeExtraSigns: kvp.key == StatType.def);
      final String title = !(mainSubStatType != kvp.key) ? typeText : s.baseX(typeText);
      items.add(StatValue(title: title, value: '${kvp.value}'));
    }

    return items;
  }
}

class StatsDialog extends StatefulWidget {
  final List<StatItem> stats;

  const StatsDialog({required this.stats});

  @override
  State<StatsDialog> createState() => _StatsDialogState();
}

class _StatsDialogState extends State<StatsDialog> {
  int _currentIndex = 0;
  late StatItem _current;

  @override
  void initState() {
    _current = widget.stats.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    return AlertDialog(
      title: Text(s.stats),
      content: Container(
        constraints: mq.getDialogBoxConstraints(_current.values.length + 2),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: IncrementButton(
                title: s.level,
                margin: EdgeInsets.zero,
                value: _currentIndex,
                onMinus: _levelChanged,
                onAdd: _levelChanged,
                getValueString: (_) => _current.isAnAscension ? '${_current.level} (+)' : '  ${_current.level}  ',
                decrementIsDisabled: _current.level == 1,
                incrementIsDisabled: _current.level == widget.stats.map((e) => e.level).reduce(max),
              ),
            ),
            SliverList.separated(
              separatorBuilder: (ctx, index) => const Divider(),
              itemCount: _current.values.length,
              itemBuilder: (ctx, index) {
                final StatValue statValue = _current.values[index];
                return ListTile(
                  dense: true,
                  title: _StatDialogListRow(title: statValue.title, value: statValue.value),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.ok),
        ),
      ],
    );
  }

  void _levelChanged(int index) {
    final newStat = widget.stats[index];
    setState(() {
      _currentIndex = index;
      _current = newStat;
    });
  }
}

class _StatDialogListRow extends StatelessWidget {
  final String title;
  final String value;

  const _StatDialogListRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.start,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class StatsTable extends StatelessWidget {
  final Color color;
  final List<StatItem> stats;

  const StatsTable({
    required this.color,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final List<StatValue> values = stats.first.values;
    return DetailSection.complex(
      title: s.stats,
      color: color,
      children: [
        Table(
          children: [
            TableRow(
              children: [
                CommonTableCell(text: s.level, padding: Styles.edgeInsetAll5),
                ...values.map(
                  (e) => CommonTableCell(
                    text: e.title,
                    padding: Styles.edgeInsetAll5,
                  ),
                ),
              ],
            ),
            ...stats.map((e) => _buildRow(e)),
          ],
        )
      ],
    );
  }

  TableRow _buildRow(StatItem e) {
    final level = e.isAnAscension ? '${e.level}+' : '${e.level}';
    return TableRow(
      children: [
        CommonTableCell(text: level, padding: Styles.edgeInsetAll5),
        ...e.values.map((e) => CommonTableCell(text: e.value, padding: Styles.edgeInsetAll5)),
      ],
    );
  }
}
