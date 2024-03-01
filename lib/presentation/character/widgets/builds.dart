part of '../character_page.dart';

class _Builds extends StatefulWidget {
  final Color color;
  final ElementType elementType;
  final List<CharacterBuildCardModel> builds;
  final bool expanded;

  const _Builds({
    required this.color,
    required this.elementType,
    required this.builds,
    this.expanded = false,
  });

  @override
  State<_Builds> createState() => _BuildsState();
}

class _BuildsState extends State<_Builds> {
  final List<bool> _isOpen = [];

  @override
  void initState() {
    _isOpen.clear();
    _isOpen.addAll(List.generate(widget.builds.length, (index) => widget.expanded));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: s.builds,
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
          children: widget.builds
              .mapIndex(
                (build, i) => ExpansionPanel(
                  isExpanded: _isOpen[i],
                  canTapOnHeader: true,
                  headerBuilder: (context, isOpen) => _BuildTitle(
                    color: widget.color,
                    type: build.type,
                    subType: build.subType,
                    isRecommended: build.isRecommended,
                    isCustomBuild: build.isCustomBuild,
                  ),
                  body: _BuildBody(
                    color: widget.color,
                    skillPriorities: build.skillPriorities,
                    subStatsToFocus: build.subStatsToFocus,
                    weapons: build.weapons,
                    artifacts: build.artifacts,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _BuildTitle extends StatelessWidget {
  final Color color;
  final CharacterRoleType type;
  final CharacterRoleSubType subType;
  final bool isRecommended;
  final bool isCustomBuild;

  const _BuildTitle({
    required this.color,
    required this.type,
    required this.subType,
    required this.isRecommended,
    required this.isCustomBuild,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final IconData icon = isCustomBuild
        ? (isRecommended ? Icons.dashboard_customize : Icons.dashboard_customize_outlined)
        : isRecommended
            ? Icons.star
            : Icons.star_outline;
    return DetailListTile.icon(
      title: s.translateCharacterRoleType(type),
      subtitle: '${s.subType}: ${s.translateCharacterRoleSubType(subType)}',
      icon: icon,
      color: color,
    );
  }
}

class _BuildBody extends StatelessWidget {
  final Color color;
  final List<CharacterSkillType> skillPriorities;
  final List<StatType> subStatsToFocus;
  final List<WeaponCardModel> weapons;
  final List<CharacterBuildArtifactModel> artifacts;

  const _BuildBody({
    required this.color,
    required this.skillPriorities,
    required this.subStatsToFocus,
    required this.weapons,
    required this.artifacts,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Styles.edgeInsetHorizontal16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomDivider.zeroIndent(color: color, drawShape: false),
          _Weapons(weapons: weapons, color: color),
          ...artifacts.mapIndex((e, index) => _ArtifactRow(index: index, color: color, item: e)),
          if (skillPriorities.isNotEmpty)
            CharacterSkillPriority(
              skillPriorities: skillPriorities,
              color: color,
            ),
          if (subStatsToFocus.isNotEmpty)
            SubStatToFocus(
              subStatsToFocus: subStatsToFocus,
              color: color,
            ),
          CustomDivider.zeroIndent(color: color, drawShape: false),
        ],
      ),
    );
  }
}

const double _imgHeight = 100;
const double _imgWidth = 90;
const double _orRadius = 12;

class _Weapons extends StatelessWidget {
  final Color color;
  final List<WeaponCardModel> weapons;

  const _Weapons({
    required this.color,
    required this.weapons,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.weapons),
            TextButton.icon(
              onPressed: () => _showDetails(context),
              label: Text(s.details),
              icon: const Icon(Icons.chevron_right),
              style: TextButton.styleFrom(
                foregroundColor: color,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        SizedBox(
          height: _imgHeight,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: weapons.length,
            itemBuilder: (ctx, index) {
              final weapon = weapons[index];
              final child = WeaponCard.withoutDetails(
                keyName: weapon.key,
                name: weapon.name,
                rarity: weapon.rarity,
                image: weapon.image,
                isComingSoon: weapon.isComingSoon,
                imgHeight: _imgHeight,
                imgWidth: _imgWidth,
              );
              final withOr = index < weapons.length - 1;
              if (withOr) {
                return RowColumnItemOr(widget: child, color: color, radius: _orRadius);
              }
              return child;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showDetails(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => _WeaponsBuildDialog(weapons: weapons),
    );
  }
}

class _ArtifactRow extends StatelessWidget {
  final int index;
  final Color color;
  final CharacterBuildArtifactModel item;

  const _ArtifactRow({
    required this.index,
    required this.color,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final int itemCount = item.one != null ? artifactOrder.length : item.multiples.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${s.artifacts} (#${index + 1})'),
            TextButton.icon(
              onPressed: () => _showDetails(context),
              label: Text(s.details),
              icon: const Icon(Icons.chevron_right),
              style: TextButton.styleFrom(
                foregroundColor: color,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        SizedBox(
          height: _imgHeight,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (ctx, index) {
              String key;
              int rarity;
              String path;
              final StatType stat = item.stats[index];
              if (item.one != null) {
                key = item.one!.key;
                rarity = item.one!.rarity;
                path = getArtifactPathByOrder(index, item.one!.image);
              } else {
                final multi = item.multiples[index];
                key = multi.key;
                rarity = multi.rarity;
                path = getArtifactPathByOrder(index, multi.image);
              }
              return Container(
                margin: index == itemCount - 1 ? null : const EdgeInsets.only(right: _orRadius * 2),
                child: ArtifactCard.withoutDetails(
                  name: s.translateStatTypeWithoutValue(stat),
                  image: path,
                  rarity: rarity,
                  keyName: key,
                  imgHeight: _imgHeight,
                  imgWidth: _imgWidth,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showDetails(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => _ArtifactBuildDialog(item: item),
    );
  }
}

class _WeaponsBuildDialog extends StatelessWidget {
  final List<WeaponCardModel> weapons;

  const _WeaponsBuildDialog({required this.weapons});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      scrollable: true,
      title: Text(s.details),
      content: SizedBox(
        width: mq.getWidthForDialogs(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: weapons
              .map(
                (e) => ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${e.rarity}', style: theme.textTheme.bodyMedium),
                      const Icon(Icons.star),
                    ],
                  ),
                  title: Text(e.name),
                  subtitle: Text('${s.subStat}: ${s.translateStatTypeWithoutValue(e.subStatType)}'),
                  onTap: () => WeaponPage.route(e.key, context),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.ok),
        ),
      ],
    );
  }
}

class _ArtifactBuildDialog extends StatelessWidget {
  final CharacterBuildArtifactModel item;

  const _ArtifactBuildDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    final int itemCount = item.one != null ? artifactOrder.length : item.multiples.length;
    const double iconSize = 36;
    return AlertDialog(
      scrollable: true,
      title: Text(s.details),
      content: SizedBox(
        width: mq.getWidthForDialogs(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(itemCount, (index) {
            final String key = item.one != null ? item.one!.key : item.multiples[index].key;
            final String name = item.one != null ? item.one!.name : item.multiples[index].name;
            final ArtifactType type = ArtifactType.values[index];
            final StatType stat = item.stats[index];
            return ListTile(
              leading: ArtifactImageType.fromType(
                type: type,
                width: iconSize,
                height: iconSize,
              ),
              title: Text('${s.translateArtifactType(type)}: $name'),
              subtitle: Text('${s.subStat}: ${s.translateStatTypeWithoutValue(stat)}'),
              onTap: () => ArtifactPage.route(key, context),
            );
          }),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.ok),
        ),
      ],
    );
  }
}
