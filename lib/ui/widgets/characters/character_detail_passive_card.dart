import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/styles.dart';
import '../../../models/models.dart';
import '../../widgets/common/bullet_list.dart';
import '../common/item_description_detail.dart';

class CharacterDetailPassiveCard extends StatelessWidget {
  final ElementType elementType;
  final List<TranslationCharacterPassive> passives;

  const CharacterDetailPassiveCard({
    Key key,
    @required this.elementType,
    @required this.passives,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = passives.map((e) => _buildPassiveCard(e, context)).toList();
    final body = Wrap(alignment: WrapAlignment.center, children: items);
    return ItemDescriptionDetail(title: 'Passives', icon: Icon(Icons.settings), body: body);
  }

  Widget _buildPassiveCard(TranslationCharacterPassive model, BuildContext context) {
    final theme = Theme.of(context);
    final unlockedAt =
        model.unlockedAt >= 1 ? 'Unlocked at Ascension level ${model.unlockedAt}' : 'Unlocked Automatically';
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
              unlockedAt,
              textAlign: TextAlign.center,
              style: theme.textTheme.subtitle2,
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                model.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyText2.copyWith(fontSize: 12),
              ),
            ),
            if (model.descriptions.isNotEmpty) BulletList(items: model.descriptions)
          ],
        ),
      ),
    );
  }
}
