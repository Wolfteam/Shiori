import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../../models/models.dart';
import '../common/bullet_list.dart';
import '../common/item_description_detail.dart';

class CharacterDetailConstellationsCard extends StatelessWidget {
  final ElementType elementType;
  final List<TranslationCharacterConstellation> constellations;

  const CharacterDetailConstellationsCard({
    Key key,
    @required this.elementType,
    @required this.constellations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = constellations.map((e) => _buildConstellationCard(e, context)).toList();
    final body = Wrap(alignment: WrapAlignment.center, children: items);
    return ItemDescriptionDetail(title: s.constellations, icon: Icon(Icons.settings), body: body);
  }

  Widget _buildConstellationCard(TranslationCharacterConstellation model, BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Card(
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: elementType.getElementColor(),
              child: Image.asset(model.fullImagePath, width: 60, height: 60),
            ),
            Text(
              model.title,
              style: theme.textTheme.subtitle1.copyWith(color: Colors.amber),
              textAlign: TextAlign.center,
            ),
            Text(
              s.constellationX('${model.number}'),
              textAlign: TextAlign.center,
              style: theme.textTheme.subtitle2,
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                model.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyText2.copyWith(fontSize: 12),
              ),
            ),
            if (model.descriptions.isNotEmpty) BulletList(items: model.descriptions),
            if (model.secondDescription != null)
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(
                  model.secondDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2.copyWith(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
