import 'package:flutter/material.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifact/artifact_page.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/shared/character_skill_priority.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/images/artifact_image_type.dart';
import 'package:shiori/presentation/shared/row_column_item_or.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/sub_stats_to_focus.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

const double _imgHeight = 125;

class CharacterDetailBuildCard extends StatelessWidget {
  final bool isRecommended;
  final ElementType elementType;
  final CharacterRoleType type;
  final CharacterRoleSubType subType;
  final List<CharacterSkillType> skillPriorities;
  final List<WeaponCardModel> weapons;
  final List<CharacterBuildArtifactModel> artifacts;
  final List<StatType> subStatsToFocus;
  final bool isCustomBuild;

  const CharacterDetailBuildCard({
    super.key,
    required this.isRecommended,
    required this.elementType,
    required this.type,
    required this.subType,
    required this.skillPriorities,
    required this.weapons,
    required this.artifacts,
    required this.subStatsToFocus,
    required this.isCustomBuild,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final color = elementType.getElementColorFromContext(context);
    var title = s.translateCharacterRoleType(type);
    if (subType != CharacterRoleSubType.none) {
      title += ' (${s.translateCharacterRoleSubType(subType)}) ';
    }

    return Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Title(title: title, isRecommended: isRecommended, isCustomBuild: isCustomBuild, color: color),
            if (skillPriorities.isNotEmpty)
              CharacterSkillPriority(
                skillPriorities: skillPriorities,
                color: color,
              ),
            Container(
              margin: Styles.edgeInsetAll5,
              child: Text(
                s.weapons,
                style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _Weapons(weapons: weapons, color: color),
            Container(
              margin: Styles.edgeInsetAll5,
              child: Text(
                s.artifacts,
                style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (subStatsToFocus.isNotEmpty)
              SubStatToFocus(
                subStatsToFocus: subStatsToFocus,
                color: color,
              ),
            ...artifacts.mapIndex((e, index) {
              final showOr = index < artifacts.length - 1;
              if (showOr) {
                return RowColumnItemOr(
                  widget: _ArtifactRow(item: e),
                  color: color,
                  useColumn: true,
                  margin: const EdgeInsets.only(bottom: 16),
                );
              }
              return _ArtifactRow(item: e);
            }),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String title;
  final bool isRecommended;
  final bool isCustomBuild;
  final Color color;

  const _Title({
    required this.title,
    required this.isRecommended,
    required this.isCustomBuild,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = Tooltip(
      message: title,
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleLarge!.copyWith(color: color),
      ),
    );

    if (isRecommended && isCustomBuild) {
      return Row(
        children: [
          Icon(Icons.dashboard_customize, color: color),
          Icon(Icons.star, color: color),
          Expanded(child: text),
        ],
      );
    }

    if (isRecommended) {
      return Row(
        children: [
          Icon(Icons.star, color: color),
          Expanded(child: text),
        ],
      );
    }

    if (isCustomBuild) {
      return Row(
        children: [
          Icon(Icons.dashboard_customize, color: color),
          Expanded(child: text),
        ],
      );
    }

    return text;
  }
}

class _Weapons extends StatelessWidget {
  final List<WeaponCardModel> weapons;
  final Color color;

  const _Weapons({
    required this.weapons,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => _showDetails(context),
              label: Text(s.details),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
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

class _WeaponsBuildDialog extends StatelessWidget {
  final List<WeaponCardModel> weapons;

  const _WeaponsBuildDialog({required this.weapons});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      scrollable: true,
      title: Text(s.details),
      content: SizedBox(
        width: MediaQuery.of(context).getWidthForDialogs(),
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
                  title: Text(
                    e.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  subtitle: Text(
                    '${s.subStat}: ${s.translateStatTypeWithoutValue(e.subStatType)}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
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

class _ArtifactRow extends StatelessWidget {
  final CharacterBuildArtifactModel item;

  const _ArtifactRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final int itemCount = item.one != null ? artifactOrder.length : item.multiples.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _imgHeight,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (ctx, index) => _buildItem(index, s),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => _showDetails(context),
              label: Text(s.details),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
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

class _ArtifactBuildDialog extends StatelessWidget {
  final CharacterBuildArtifactModel item;

  const _ArtifactBuildDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final int itemCount = item.one != null ? artifactOrder.length : item.multiples.length;
    const double iconSize = 36;
    return AlertDialog(
      scrollable: true,
      title: Text(s.details),
      content: SizedBox(
        width: MediaQuery.of(context).getWidthForDialogs(),
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
              title: Text(
                '${s.translateArtifactType(type)}: $name',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Text(
                '${s.subStat}: ${s.translateStatTypeWithoutValue(stat)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
