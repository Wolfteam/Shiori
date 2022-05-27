import 'package:flutter/material.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/shared/character_skill_priority.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/row_column_item_or.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/sub_stats_to_focus.dart';
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
    Key? key,
    required this.isRecommended,
    required this.elementType,
    required this.type,
    required this.subType,
    required this.skillPriorities,
    required this.weapons,
    required this.artifacts,
    required this.subStatsToFocus,
    required this.isCustomBuild,
  }) : super(key: key);

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
                style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _Weapons(weapons: weapons, color: color),
            Container(
              margin: Styles.edgeInsetAll5,
              child: Text(
                s.artifacts,
                style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
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
                return RowColumnItemOr(widget: _ArtifactRow(item: e), color: color, useColumn: true);
              }
              return _ArtifactRow(item: e);
            }).toList(),
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
    Key? key,
    required this.title,
    required this.isRecommended,
    required this.isCustomBuild,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = Tooltip(
      message: title,
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.headline6!.copyWith(color: color),
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
    Key? key,
    required this.weapons,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

class _ArtifactRow extends StatelessWidget {
  final CharacterBuildArtifactModel item;

  const _ArtifactRow({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    if (item.one != null) {
      return SizedBox(
        height: _imgHeight,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: artifactOrder.length,
          itemBuilder: (ctx, index) {
            final digit = artifactOrder[index];
            final stat = item.stats[index];
            final path = item.one!.image.replaceFirst(replaceDigitRegex, '$digit');
            return ArtifactCard.withoutDetails(
              name: s.translateStatTypeWithoutValue(stat),
              image: path,
              rarity: item.one!.rarity,
              keyName: item.one!.key,
            );
          },
        ),
      );
    }

    return SizedBox(
      height: _imgHeight,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: item.multiples.length,
        itemBuilder: (ctx, index) {
          final multi = item.multiples[index];
          final digit = artifactOrder[index];
          final stat = item.stats[index];
          final path = multi.image.replaceFirst(replaceDigitRegex, '$digit');
          return ArtifactCard.withoutDetails(
            name: s.translateStatTypeWithoutValue(stat),
            image: path,
            rarity: multi.rarity,
            keyName: multi.key,
          );
        },
      ),
    );
  }
}
