import 'package:flutter/material.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

final _replaceDigitRegex = RegExp(r'\d{1}');
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
            if (isRecommended)
              Row(
                children: [
                  Icon(Icons.star, color: color),
                  Text(
                    title,
                    style: theme.textTheme.headline6!.copyWith(color: color),
                  ),
                ],
              )
            else
              Text(
                title,
                style: theme.textTheme.headline6!.copyWith(color: color),
              ),
            _SkillPriority(skillPriorities: skillPriorities, color: color),
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
            _SubStatToFocus(
              subStatsToFocus: subStatsToFocus,
              color: color,
            ),
            ...artifacts.mapIndex((e, index) {
              final showOr = index < artifacts.length - 1;
              if (showOr) {
                return _ItemWithOr(widget: _ArtifactRow(item: e), color: color, useColumn: true);
              }
              return _ArtifactRow(item: e);
            }).toList(),
          ],
        ),
      ),
    );
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
            return _ItemWithOr(widget: child, color: color);
          }
          return child;
        },
      ),
    );
  }
}

class _ItemWithOr extends StatelessWidget {
  final Widget widget;
  final Color color;
  final bool useColumn;

  const _ItemWithOr({
    Key? key,
    required this.widget,
    required this.color,
    this.useColumn = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useColumn) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [widget, _OrWidget(color: color)],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [widget, _OrWidget(color: color)],
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
            final path = item.one!.image.replaceFirst(_replaceDigitRegex, '$digit');
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
          final path = multi.image.replaceFirst(_replaceDigitRegex, '$digit');
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

class _OrWidget extends StatelessWidget {
  final Color color;

  const _OrWidget({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetAll5,
      padding: Styles.edgeInsetAll5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          s.or,
          textAlign: TextAlign.center,
          style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class _SubStatToFocus extends StatelessWidget {
  final List<StatType> subStatsToFocus;
  final Color color;

  const _SubStatToFocus({
    Key? key,
    required this.subStatsToFocus,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final text = subStatsToFocus.map((e) => s.translateStatTypeWithoutValue(e)).join(' > ');
    return Container(
      margin: Styles.edgeInsetHorizontal5,
      child: Text(
        '${s.subStats}: $text',
        style: theme.textTheme.subtitle2!.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SkillPriority extends StatelessWidget {
  final List<CharacterSkillType> skillPriorities;
  final Color color;

  const _SkillPriority({
    Key? key,
    required this.skillPriorities,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final text = skillPriorities.map((e) => s.translateCharacterSkillType(e)).join(' > ');
    return Container(
      margin: Styles.edgeInsetHorizontal5,
      child: Text(
        '${s.talentsAscension}: $text',
        style: theme.textTheme.subtitle2!.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}
