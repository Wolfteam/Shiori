import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/comingsoon_new_avatar.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/utils/toast_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class MonsterCard extends StatelessWidget {
  final String itemKey;
  final String image;
  final String name;
  final MonsterType type;
  final bool isComingSoon;

  const MonsterCard({
    Key key,
    @required this.itemKey,
    @required this.image,
    @required this.name,
    @required this.type,
    @required this.isComingSoon,
  }) : super(key: key);

  MonsterCard.item({
    Key key,
    @required MonsterCardModel item,
  })  : itemKey = item.key,
        type = item.type,
        name = item.name,
        image = item.image,
        isComingSoon = item.isComingSoon,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return InkWell(
      borderRadius: Styles.mainCardBorderRadius,
      onTap: () => ToastUtils.showWarningToast(s.comingSoon),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: Styles.mainCardShape,
        elevation: Styles.cardTenElevation,
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.topCenter,
              fit: StackFit.passthrough,
              children: [
                FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: AssetImage(image),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ComingSoonNewAvatar(isNew: false, isComingSoon: isComingSoon),
                  ],
                ),
              ],
            ),
            Container(
              margin: Styles.edgeInsetAll10,
              child: Center(
                child: Tooltip(
                  message: name,
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
