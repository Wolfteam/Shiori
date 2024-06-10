part of '../character_page.dart';

class _Skills extends StatefulWidget {
  final Color color;
  final List<CharacterSkillCardModel> skills;
  final bool expanded;

  const _Skills({
    required this.color,
    required this.skills,
    this.expanded = false,
  });

  @override
  State<_Skills> createState() => _SkillsState();
}

class _SkillsState extends State<_Skills> {
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
    return DetailListTile.image(
      title: skill.title,
      subtitle: '${s.type}: ${s.translateCharacterSkillType(skill.type)}',
      image: skill.image,
      color: color,
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
              style: ElevatedButton.styleFrom(
                foregroundColor: color,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => StatsDialog(
                  stats: skill.stats.map((e) => StatItem.characterSkill(e)).toList(),
                ),
              ),
            ),
          ),
          CustomDivider.zeroIndent(color: color, drawShape: false),
        ],
      ),
    );
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
