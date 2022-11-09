import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/character/widgets/character_stats_dialog.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CharacterDetailSkillsCard extends StatelessWidget {
  final ElementType elementType;
  final List<CharacterSkillCardModel> skills;

  const CharacterDetailSkillsCard({
    super.key,
    required this.elementType,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ItemDescriptionDetail(
      title: s.skills,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: skills.mapIndex((e, index) => _SkillCard(model: e, isEven: index.isEven, elementType: elementType)).toList(),
        ),
      ),
      textColor: elementType.getElementColorFromContext(context),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final CharacterSkillCardModel model;
  final bool isEven;
  final ElementType elementType;

  const _SkillCard({
    required this.model,
    required this.isEven,
    required this.elementType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: Styles.cardTenElevation,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SkillHeader(
              title: model.title,
              image: model.image,
              type: model.type,
              elementType: elementType,
              isEven: isEven,
              stats: model.stats,
            ),
            if (model.description != null) Text(model.description!, style: theme.textTheme.bodyText2!.copyWith(fontSize: 12)),
            ...model.abilities.map(
              (e) => _SkillAbility(
                name: e.name,
                description: e.description,
                secondDescription: e.secondDescription,
                descriptions: e.descriptions,
                elementType: elementType,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillHeader extends StatelessWidget {
  final ElementType elementType;
  final String title;
  final String image;
  final bool isEven;
  final CharacterSkillType type;
  final List<CharacterSkillStatModel> stats;

  const _SkillHeader({
    required this.elementType,
    required this.title,
    required this.image,
    required this.isEven,
    required this.type,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final img = Expanded(
      child: CircleAvatar(
        radius: 40,
        backgroundColor: elementType.getElementColorFromContext(context),
        child: image == Assets.noImageAvailablePath ? Image.asset(image, width: 65, height: 65) : Image.file(File(image), width: 65, height: 65),
      ),
    );
    final titles = Expanded(
      child: Column(
        children: [
          Tooltip(
            message: title,
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headline6!.copyWith(color: elementType.getElementColorFromContext(context)),
            ),
          ),
          Tooltip(
            message: s.translateCharacterSkillType(type),
            child: Text(
              s.translateCharacterSkillType(type),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    final statButton = IconButton(
      icon: const Icon(Icons.bar_chart),
      splashRadius: 20,
      onPressed: () => _showSkillStats(stats, context),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: isEven
            ? [
                img,
                titles,
                if (stats.isNotEmpty) statButton,
              ]
            : [
                titles,
                img,
                if (stats.isNotEmpty) statButton,
              ],
      ),
    );
  }

  Future<void> _showSkillStats(List<CharacterSkillStatModel> stats, BuildContext context) async {
    await showDialog(context: context, builder: (ctx) => CharacterStatsDialog(stats: stats));
  }
}

class _SkillAbility extends StatelessWidget {
  final String? name;
  final String? description;
  final String? secondDescription;
  final List<String> descriptions;
  final ElementType elementType;

  const _SkillAbility({
    this.name,
    this.description,
    this.secondDescription,
    required this.descriptions,
    required this.elementType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetAll5,
      child: Column(
        children: [
          if (name.isNotNullEmptyOrWhitespace)
            Text(
              name!,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.subtitle1!.copyWith(color: elementType.getElementColorFromContext(context)),
            ),
          if (description != null) Text(description!, style: theme.textTheme.bodyText2!.copyWith(fontSize: 12)),
          if (descriptions.isNotEmpty) BulletList(items: descriptions),
          if (secondDescription != null) Text(secondDescription!, style: theme.textTheme.bodyText2!.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
