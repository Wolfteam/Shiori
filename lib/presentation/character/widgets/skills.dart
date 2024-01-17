import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/custom_divider.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/increment_button.dart';
import 'package:shiori/presentation/shared/styles.dart';

class Skills extends StatefulWidget {
  final Color color;
  final List<CharacterSkillCardModel> skills;
  final bool expanded;

  const Skills({
    required this.color,
    required this.skills,
    this.expanded = false,
  });

  @override
  State<Skills> createState() => _SkillsState();
}

class _SkillsState extends State<Skills> {
  final List<bool> _isOpen = [];

  @override
  void initState() {
    _isOpen.clear();
    _isOpen.addAll(List.generate(widget.skills.length, (index) => widget.expanded));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: s.skills,
      color: widget.color,
      children: [
        ExpansionPanelList(
          expansionCallback: (index, isOpen) => setState(() {
            _isOpen[index] = isOpen;
          }),
          dividerColor: Colors.transparent,
          elevation: 0,
          expandIconColor: widget.color,
          expandedHeaderPadding: EdgeInsets.zero,
          materialGapSize: 5,
          children: widget.skills
              .mapIndex(
                (e, i) => ExpansionPanel(
                  isExpanded: _isOpen[i],
                  canTapOnHeader: true,
                  headerBuilder: (context, isOpen) => _SkillTile(color: widget.color, skill: e),
                  body: _SkillBody(color: widget.color, skill: e),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SkillTile extends StatelessWidget {
  final Color color;
  final CharacterSkillCardModel skill;

  const _SkillTile({
    required this.color,
    required this.skill,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    const double iconSize = 50;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: color,
        child: Padding(
          padding: Styles.edgeInsetAll5,
          child: ClipOval(
            child: skill.image == Assets.noImageAvailablePath
                ? Image.asset(skill.image, width: iconSize, height: iconSize, fit: BoxFit.cover)
                : Image.file(File(skill.image), width: iconSize, fit: BoxFit.contain),
          ),
        ),
      ),
      title: Text(skill.title),
      subtitle: Text('${s.type}: ${s.translateCharacterSkillType(skill.type)}'),
      horizontalTitleGap: 5,
      iconColor: color,
      minVerticalPadding: 0,
      subtitleTextStyle: theme.textTheme.bodyMedium!.copyWith(color: color),
      // onTap: () {},
    );
  }
}

class _SkillBody extends StatelessWidget {
  final Color color;
  final CharacterSkillCardModel skill;

  const _SkillBody({
    required this.color,
    required this.skill,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final buttonStyle = TextButton.styleFrom(foregroundColor: color);
    return Padding(
      padding: Styles.edgeInsetHorizontal16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomDivider.zeroIndent(color: color, drawShape: false),
          if (skill.description.isNotNullEmptyOrWhitespace)
            Text(
              skill.description.removeLineBreakAtEnd()!,
            ),
          ...skill.abilities.map(
            (e) => _SkillAbility(
              name: e.name,
              description: e.description,
              secondDescription: e.secondDescription,
              descriptions: e.descriptions,
              color: color,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: Styles.edgeInsetVertical5,
            child: ElevatedButton.icon(
              label: Text(s.stats),
              icon: const Icon(Icons.bar_chart),
              style: buttonStyle,
              onPressed: () => _showSkillStats(context),
            ),
          ),
          CustomDivider.zeroIndent(color: color, drawShape: false),
        ],
      ),
    );
  }

  Future<void> _showSkillStats(BuildContext context) async {
    return showDialog(context: context, builder: (ctx) => CharacterSkillsStatsDialog(stats: skill.stats));
  }
}

class _SkillAbility extends StatelessWidget {
  final String? name;
  final String? description;
  final String? secondDescription;
  final List<String> descriptions;
  final Color color;

  const _SkillAbility({
    this.name,
    this.description,
    this.secondDescription,
    required this.descriptions,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetVertical5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (name.isNotNullEmptyOrWhitespace)
            Text(
              name.removeLineBreakAtEnd()!,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium!.copyWith(color: color),
            ),
          if (description.isNotNullEmptyOrWhitespace)
            Text(
              description.removeLineBreakAtEnd()!,
            ),
          if (descriptions.isNotEmpty)
            BulletList(
              items: descriptions,
              addTooltip: false,
            ),
          if (secondDescription.isNotNullEmptyOrWhitespace)
            Text(
              secondDescription.removeLineBreakAtEnd()!,
            ),
        ],
      ),
    );
  }
}

class CharacterSkillsStatsDialog extends StatefulWidget {
  final List<CharacterSkillStatModel> stats;

  const CharacterSkillsStatsDialog({
    super.key,
    required this.stats,
  });

  @override
  _CharacterSkillsStatsDialogState createState() => _CharacterSkillsStatsDialogState();
}

class _CharacterSkillsStatsDialogState extends State<CharacterSkillsStatsDialog> {
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
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(s.stats),
      content: SizedBox(
        height: mq.getHeightForDialogs(_currentStat.descriptions.length, itemHeight: 80),
        width: mq.getWidthForDialogs(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IncrementButton(
              title: s.level,
              margin: EdgeInsets.zero,
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
                          child: Text(
                            a,
                            textAlign: TextAlign.start,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            b,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
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

  void _levelChanged(int level) {
    final newStat = widget.stats.firstWhere((el) => el.level == level);
    setState(() {
      _currentStat = newStat;
    });
  }
}
