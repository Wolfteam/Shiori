import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/extensions/iterable_extensions.dart';
import '../../../common/styles.dart';
import '../../../models/models.dart';
import '../common/bullet_list.dart';
import '../common/item_description_detail.dart';

class CharacterDetailSkillsCard extends StatelessWidget {
  final ElementType elementType;
  final List<TranslationCharacterSkillFile> skills;
  const CharacterDetailSkillsCard({
    Key key,
    @required this.elementType,
    @required this.skills,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cards = skills.mapIndex((e, index) => _buildSkillCard(context, e, index.isEven)).toList();
    final body = Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Wrap(alignment: WrapAlignment.center, children: cards),
    );

    return ItemDescriptionDetail(title: 'Skills', icon: Icon(Icons.settings), body: body);
  }

  Widget _buildSkillCard(BuildContext context, TranslationCharacterSkillFile model, bool isEven) {
    final theme = Theme.of(context);
    final img = Expanded(
      child: CircleAvatar(
        radius: 40,
        backgroundColor: elementType.getElementColor(),
        child: Image.asset(model.fullImagePath, width: 65, height: 65),
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
              style: theme.textTheme.headline6.copyWith(color: theme.accentColor),
            ),
          ),
          Tooltip(
            message: model.subTitle,
            child: Text(
              model.subTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    final widgets = <Widget>[];
    if (model.description != null) {
      widgets.add(Text(model.description, style: theme.textTheme.bodyText2.copyWith(fontSize: 12)));
    }

    if (model.abilities.isNotEmpty) {
      widgets.addAll(
        model.abilities.map(
          (e) => Container(
            margin: Styles.edgeInsetAll5,
            child: Column(
              children: [
                Text(
                  e.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.subtitle1.copyWith(color: theme.accentColor),
                ),
                if (e.description != null) Text(e.description, style: theme.textTheme.bodyText2.copyWith(fontSize: 12)),
                if (e.descriptions.isNotEmpty) BulletList(items: e.descriptions),
                if (e.secondDescription != null)
                  Text(e.secondDescription, style: theme.textTheme.bodyText2.copyWith(fontSize: 12)),
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
