import 'package:flutter/material.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifact/artifact_page.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/shared/character_skill_priority.dart';
import 'package:shiori/presentation/shared/custom_divider.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/images/artifact_image_type.dart';
import 'package:shiori/presentation/shared/row_column_item_or.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/sub_stats_to_focus.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

class Builds extends StatefulWidget {
  final Color color;
  final ElementType elementType;
  final List<CharacterBuildCardModel> builds;
  final bool expanded;

  const Builds({
    required this.color,
    required this.elementType,
    required this.builds,
    this.expanded = false,
  });

  @override
  State<Builds> createState() => _BuildsState();
}

class _BuildsState extends State<Builds> {
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
                    skillPriorities: build.skillPriorities,
                    subStatsToFocus: build.subStatsToFocus,
                  ),
                  body: _BuildBody(
                    color: widget.color,
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
  final List<CharacterSkillType> skillPriorities;
  final List<StatType> subStatsToFocus;
  final double iconSize;

  const _BuildTitle({
    required this.color,
    required this.type,
    required this.subType,
    required this.isRecommended,
    required this.isCustomBuild,
    required this.skillPriorities,
    required this.subStatsToFocus,
    this.iconSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final IconData icon = isCustomBuild
        ? (isRecommended ? Icons.dashboard_customize : Icons.dashboard_customize_outlined)
        : isRecommended
            ? Icons.star
            : Icons.star_outline;
    return ListTile(
      subtitleTextStyle: theme.textTheme.bodyMedium!.copyWith(color: color),
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: iconSize),
      title: Text(s.translateCharacterRoleType(type)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${s.subType}: ${s.translateCharacterRoleSubType(subType)}'),
          if (skillPriorities.isNotEmpty)
            CharacterSkillPriority(
              skillPriorities: skillPriorities,
              color: color,
              margin: EdgeInsets.zero,
              fontSize: 11,
            ),
          if (subStatsToFocus.isNotEmpty)
            SubStatToFocus(
              subStatsToFocus: subStatsToFocus,
              color: color,
              margin: EdgeInsets.zero,
              fontSize: 11,
            ),
        ],
      ),
      horizontalTitleGap: 5,
      iconColor: color,
      minVerticalPadding: 0,
    );
  }
}

class _BuildBody extends StatelessWidget {
  final Color color;
  final List<WeaponCardModel> weapons;
  final List<CharacterBuildArtifactModel> artifacts;

  const _BuildBody({
    required this.color,
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
          CustomDivider.zeroIndent(color: color, drawShape: false),
        ],
      ),
    );
  }
}

const double _imgHeight = 125;

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
              style: TextButton.styleFrom(foregroundColor: color),
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
              );
              final withOr = index < weapons.length - 1;
              if (withOr) {
                return RowColumnItemOr(widget: child, color: color);
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
              style: TextButton.styleFrom(foregroundColor: color),
            ),
          ],
        ),
        SizedBox(
          height: _imgHeight,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (ctx, index) => _buildItem(index, s),
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

  Widget _buildItem(int index, S s) {
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
      margin: const EdgeInsets.only(right: 40),
      child: ArtifactCard.withoutDetails(
        name: s.translateStatTypeWithoutValue(stat),
        image: path,
        rarity: rarity,
        keyName: key,
      ),
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
