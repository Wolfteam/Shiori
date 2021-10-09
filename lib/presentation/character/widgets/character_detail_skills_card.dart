import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CharacterDetailSkillsCard extends StatelessWidget {
  final ElementType elementType;
  final List<CharacterSkillCardModel> skills;

  const CharacterDetailSkillsCard({
    Key? key,
    required this.elementType,
    required this.skills,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ItemDescriptionDetail(
      title: s.skills,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: skills
              .mapIndex((e, index) => _SkillCard(
                    model: e,
                    isEven: index.isEven,
                    elementType: elementType,
                  ))
              .toList(),
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
    Key? key,
    required this.model,
    required this.isEven,
    required this.elementType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final img = Expanded(
      child: CircleAvatar(
        radius: 40,
        backgroundColor: elementType.getElementColorFromContext(context),
        child: Image.asset(model.image, width: 65, height: 65),
      ),
    );
    final titles = Expanded(
      child: Column(
        children: [
          Tooltip(
            message: model.title,
            child: Text(
              model.title,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headline6!.copyWith(color: elementType.getElementColorFromContext(context)),
            ),
          ),
          Tooltip(
            message: s.translateCharacterSkillType(model.type),
            child: Text(
              s.translateCharacterSkillType(model.type),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    final widgets = <Widget>[];
    if (model.description != null) {
      widgets.add(Text(model.description!, style: theme.textTheme.bodyText2!.copyWith(fontSize: 12)));
    }

    if (model.abilities.isNotEmpty) {
      widgets.addAll(
        model.abilities.map(
          (e) => Container(
            margin: Styles.edgeInsetAll5,
            child: Column(
              children: [
                if (e.name.isNotNullEmptyOrWhitespace)
                  Text(
                    e.name!,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.subtitle1!.copyWith(color: elementType.getElementColorFromContext(context)),
                  ),
                if (e.description != null) Text(e.description!, style: theme.textTheme.bodyText2!.copyWith(fontSize: 12)),
                if (e.descriptions.isNotEmpty) BulletList(items: e.descriptions),
                if (e.secondDescription != null) Text(e.secondDescription!, style: theme.textTheme.bodyText2!.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: Styles.cardTenElevation,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: isEven ? [img, titles] : [titles, img],
              ),
            ),
            ...widgets,
          ],
        ),
      ),
    );
  }
}
