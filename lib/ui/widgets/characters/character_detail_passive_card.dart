import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../../models/models.dart';
import '../../widgets/common/bullet_list.dart';
import '../common/item_description_detail.dart';

class CharacterDetailPassiveCard extends StatelessWidget {
  final ElementType elementType;
  final List<CharacterPassiveTalentModel> passives;

  const CharacterDetailPassiveCard({
    Key key,
    @required this.elementType,
    @required this.passives,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = passives.map((e) => _buildPassiveCard(e, context)).toList();
    final body = Wrap(alignment: WrapAlignment.center, children: items);
    return ItemDescriptionDetail(
      title: s.passives,
      body: body,
      textColor: elementType.getElementColorFromContext(context),
    );
  }

  Widget _buildPassiveCard(CharacterPassiveTalentModel model, BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final unlockedAt = model.unlockedAt >= 1 ? s.unlockedAtAscensionLevelX(model.unlockedAt) : s.unlockedAutomatically;
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
              backgroundColor: elementType.getElementColorFromContext(context),
              child: Image.asset(model.image, width: 60, height: 60),
            ),
            Text(
              model.title,
              style: theme.textTheme.subtitle1.copyWith(color: elementType.getElementColorFromContext(context)),
              textAlign: TextAlign.center,
            ),
            Text(
              unlockedAt,
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
            if (model.descriptions.isNotEmpty) BulletList(items: model.descriptions)
          ],
        ),
      ),
    );
  }
}
