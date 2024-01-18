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

class StatItem {
  final int level;
  final bool isAnAscension;
  final List<StatValue> values;

  StatItem({
    required this.isAnAscension,
    required this.level,
    required this.values,
  });

  StatItem.forCharacter(CharacterFileStatModel charStat, StatType mainSubStatType)
      : isAnAscension = charStat.isAnAscension,
        level = charStat.level,
        values = List.generate(4, (index) => _buildCharacterStatValue(index, charStat, mainSubStatType));

  StatItem.forWeapon(WeaponFileStatModel weaponStat, StatType mainSubStatType)
      : isAnAscension = weaponStat.isAnAscension,
        level = weaponStat.level,
        values = List.generate(2, (index) => _buildWeaponStatValue(index, weaponStat, mainSubStatType));

  static StatValue _buildCharacterStatValue(int index, CharacterFileStatModel charStat, StatType mainSubStatType) {
    final type = switch (index) {
      0 => StatType.hp,
      1 => StatType.atk,
      2 => StatType.def,
      3 => mainSubStatType,
      _ => throw ArgumentError(),
    };
    final value = switch (index) {
      0 => charStat.baseHp,
      1 => charStat.baseAtk,
      2 => charStat.baseDef,
      3 => charStat.statValue,
      _ => throw ArgumentError(),
    };

    return StatValue(type: type, value: value, isBase: index != 3);
  }

  static StatValue _buildWeaponStatValue(int index, WeaponFileStatModel charStat, StatType mainSubStatType) {
    final type = switch (index) {
      0 => StatType.atk,
      1 => mainSubStatType,
      _ => throw ArgumentError(),
    };
    final value = switch (index) {
      0 => charStat.baseAtk,
      1 => charStat.statValue,
      _ => throw ArgumentError(),
    };

    return StatValue(type: type, value: value, isBase: index != 3);
  }
}

class StatValue {
  final StatType type;
  final double value;
  final bool isBase;

  const StatValue({required this.type, required this.value, required this.isBase});
}

class StatsDialog extends StatefulWidget {
  final List<StatItem> stats;
  final StatType mainSubStatType;

  const StatsDialog({required this.stats, required this.mainSubStatType});

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
      content: SizedBox(
        height: mq.getHeightForDialogs(_current.values.length, itemHeight: 80),
        width: mq.getWidthForDialogs(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IncrementButton(
              title: s.level,
              value: _currentIndex,
              onMinus: _levelChanged,
              onAdd: _levelChanged,
              getValueString: (_) => _current.isAnAscension ? '${_current.level} (+)' : '  ${_current.level}  ',
              decrementIsDisabled: _current.level == 1,
              incrementIsDisabled: _current.level == widget.stats.map((e) => e.level).reduce(max),
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (ctx, index) => const Divider(),
                itemCount: _current.values.length,
                itemBuilder: (ctx, index) {
                  final StatValue statValue = _current.values[index];
                  return ListTile(
                    dense: true,
                    title: _StatRow(
                      type: statValue.type,
                      value: statValue.value,
                      removeExtraSigns: statValue.type == StatType.def,
                      isBase: statValue.isBase,
                    ),
                  );
                },
              ),
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

class _StatRow extends StatelessWidget {
  final StatType type;
  final double value;
  final bool isBase;
  final bool removeExtraSigns;

  const _StatRow({
    required this.type,
    required this.value,
    this.isBase = true,
    this.removeExtraSigns = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final String typeText = s.translateStatTypeWithoutValue(type, removeExtraSigns: removeExtraSigns);
    return Row(
      children: [
        Expanded(
          child: Text(
            !isBase ? typeText : s.baseX(typeText),
            textAlign: TextAlign.start,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Text(
            '$value',
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
  final StatType mainSubStatType;
  final List<StatItem> stats;

  const StatsTable({
    required this.color,
    required this.mainSubStatType,
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
                    text: s.baseX(
                      s.translateStatTypeWithoutValue(
                        e.type,
                        removeExtraSigns: e.type == StatType.def,
                      ),
                    ),
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
        ...e.values.map((e) => CommonTableCell(text: '${e.value}', padding: Styles.edgeInsetAll5)),
      ],
    );
  }
}
