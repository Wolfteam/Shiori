import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/increment_button.dart';

class CharacterStatsDialog extends StatefulWidget {
  final List<CharacterSkillStatModel> stats;

  const CharacterStatsDialog({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  _CharacterStatsDialogState createState() => _CharacterStatsDialogState();
}

class _CharacterStatsDialogState extends State<CharacterStatsDialog> {
  late CharacterSkillStatModel _currentStat;

  @override
  void initState() {
    _currentStat = widget.stats.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    return AlertDialog(
      content: SizedBox(
        height: mq.getHeightForDialogs(_currentStat.descriptions.length, itemHeight: 80),
        width: mq.getWidthForDialogs(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IncrementButton(
              title: s.level,
              value: _currentStat.level,
              onMinus: _levelChanged,
              onAdd: _levelChanged,
              decrementIsDisabled: _currentStat.level == 1,
              incrementIsDisabled: _currentStat.level == widget.stats.map((e) => e.level).reduce(max),
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (ctx, index) => const Divider(),
                itemCount: _currentStat.descriptions.length,
                itemBuilder: (ctx, index) {
                  final desc = _currentStat.descriptions[index];
                  final splitted = desc.split('|');
                  final a = splitted.first;
                  final b = splitted.last;

                  return ListTile(
                    dense: true,
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(a, textAlign: TextAlign.start),
                        ),
                        Expanded(
                          child: Text(b, textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.ok),
        )
      ],
    );
  }

  void _levelChanged(int level) {
    final newStat = widget.stats.firstWhere((el) => el.level == level);
    setState(() {
      _currentStat = newStat;
    });
  }
}
