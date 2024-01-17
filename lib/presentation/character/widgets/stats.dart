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

class StatsDialog extends StatefulWidget {
  final List<CharacterFileStatModel> stats;
  final StatType subStatType;

  const StatsDialog({required this.stats, required this.subStatType});

  @override
  State<StatsDialog> createState() => _StatsDialogState();
}

class _StatsDialogState extends State<StatsDialog> {
  final List<int> _indexes = [];
  int _currentIndex = 0;
  late CharacterFileStatModel _current;

  @override
  void initState() {
    _indexes.addAll(List.generate(widget.stats.length, (index) => index));
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
        height: mq.getHeightForDialogs(4, itemHeight: 80),
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
                itemCount: 4,
                itemBuilder: (ctx, index) {
                  final type = switch (index) {
                    0 => StatType.hp,
                    1 => StatType.atk,
                    2 => StatType.def,
                    3 => widget.subStatType,
                    _ => throw ArgumentError(),
                  };
                  final value = switch (index) {
                    0 => _current.baseHp,
                    1 => _current.baseAtk,
                    2 => _current.baseDef,
                    3 => _current.statValue,
                    _ => throw ArgumentError()
                  };

                  return ListTile(
                    dense: true,
                    title: _StatRow(
                      type: type,
                      value: value,
                      removeExtraSigns: type == StatType.def,
                      isBase: index != 3,
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
  final StatType subStatType;
  final List<CharacterFileStatModel> stats;

  const StatsTable({
    required this.color,
    required this.subStatType,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: s.stats,
      color: color,
      children: [
        Table(
          children: [
            TableRow(
              children: [
                CommonTableCell(text: s.level, padding: Styles.edgeInsetAll5),
                CommonTableCell(text: s.baseX(s.translateStatTypeWithoutValue(StatType.hp)), padding: Styles.edgeInsetAll5),
                CommonTableCell(text: s.baseX(s.translateStatTypeWithoutValue(StatType.atk)), padding: Styles.edgeInsetAll5),
                CommonTableCell(
                  text: s.baseX(s.translateStatTypeWithoutValue(StatType.defPercentage, removeExtraSigns: true)),
                  padding: Styles.edgeInsetAll5,
                ),
                CommonTableCell(text: s.translateStatTypeWithoutValue(subStatType), padding: Styles.edgeInsetAll5),
              ],
            ),
            ...stats.map((e) => _buildRow(e)),
          ],
        )
      ],
    );
  }

  TableRow _buildRow(CharacterFileStatModel e) {
    final level = e.isAnAscension ? '${e.level}+' : '${e.level}';
    return TableRow(
      children: [
        CommonTableCell(text: level, padding: Styles.edgeInsetAll5),
        CommonTableCell(text: '${e.baseHp}', padding: Styles.edgeInsetAll5),
        CommonTableCell(text: '${e.baseAtk}', padding: Styles.edgeInsetAll5),
        CommonTableCell(text: '${e.baseDef}', padding: Styles.edgeInsetAll5),
        CommonTableCell(text: '${e.statValue}', padding: Styles.edgeInsetAll5),
      ],
    );
  }
}
