import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/iterable_extensions.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/bullet_list.dart';
import 'package:genshindb/presentation/shared/extensions/element_type_extensions.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/styles.dart';

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
    final cards = skills.mapIndex((e, index) => _buildSkillCard(context, e, index.isEven)).toList();
    final body = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(alignment: WrapAlignment.center, children: cards),
    );

    return ItemDescriptionDetail(
      title: s.skills,
      body: body,
      textColor: elementType.getElementColorFromContext(context),
    );
  }

  Widget _buildSkillCard(BuildContext context, CharacterSkillCardModel model, bool isEven) {
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
                if (e.hasCommonTranslation || e.name.isNotNullEmptyOrWhitespace)
                  Text(
                    e.hasCommonTranslation ? s.translateCharacterSkillAbilityType(e.type!) : e.name!,
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
