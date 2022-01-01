import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/artifact/artifact_page.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/gradient_card.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:transparent_image/transparent_image.dart';

import 'artifact_stats.dart';

class ArtifactCard extends StatelessWidget {
  final String keyName;
  final String name;
  final String image;
  final int rarity;
  final List<ArtifactCardBonusModel> bonus;
  final double imgWidth;
  final double imgHeight;
  final bool withoutDetails;
  final bool withElevation;
  final bool isInSelectionMode;

  const ArtifactCard({
    Key? key,
    required this.keyName,
    required this.name,
    required this.image,
    required this.rarity,
    required this.bonus,
    this.imgWidth = 140,
    this.imgHeight = 120,
    this.withElevation = true,
    this.isInSelectionMode = false,
  })  : withoutDetails = false,
        super(key: key);

  const ArtifactCard.withoutDetails({
    Key? key,
    required this.keyName,
    required this.name,
    required this.image,
    required this.rarity,
    this.isInSelectionMode = false,
  })  : imgWidth = 70,
        imgHeight = 60,
        bonus = const [],
        withoutDetails = true,
        withElevation = false,
        super(key: key);

  ArtifactCard.item({
    Key? key,
    required ArtifactCardModel item,
    this.imgWidth = 140,
    this.imgHeight = 120,
    this.withElevation = true,
    this.withoutDetails = false,
    this.isInSelectionMode = false,
  })  : keyName = item.key,
        name = item.name,
        image = item.image,
        rarity = item.rarity,
        bonus = item.bonus,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: Styles.mainCardBorderRadius,
      onTap: () => _gotoDetailPage(context),
      child: GradientCard(
        clipBehavior: Clip.hardEdge,
        shape: Styles.mainCardShape,
        elevation: withElevation ? Styles.cardTenElevation : 0,
        gradient: rarity.getRarityGradient(),
        child: Padding(
          padding: withoutDetails ? Styles.edgeInsetAll5 : Styles.edgeInsetAll10,
          child: Column(
            children: [
              FadeInImage(
                width: imgWidth,
                height: imgHeight,
                placeholder: MemoryImage(kTransparentImage),
                image: AssetImage(image),
              ),
              Center(
                child: Tooltip(
                  message: name,
                  child: !withoutDetails
                      ? Text(
                          name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : Text(
                          name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
              Rarity(stars: rarity),
              if (bonus.isNotEmpty)
                ArtifactStats(
                  bonus: bonus,
                  textColor: Colors.white,
                  maxLines: 10,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _gotoDetailPage(BuildContext context) async {
    if (isInSelectionMode) {
      Navigator.pop(context, keyName);
      return;
    }

    final route = MaterialPageRoute(builder: (ctx) => ArtifactPage(itemKey: keyName));
    await Navigator.of(context).push(route);
  }
}
