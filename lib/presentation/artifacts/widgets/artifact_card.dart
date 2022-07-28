import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/artifact/artifact_page.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/gradient_card.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:transparent_image/transparent_image.dart';

import 'artifact_stats.dart';

final replaceDigitRegex = RegExp(r'\d{1}');

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
  final bool withShape;
  final bool withTextOverflow;

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
    this.withShape = true,
    this.withTextOverflow = false,
  })  : withoutDetails = false,
        super(key: key);

  const ArtifactCard.withoutDetails({
    Key? key,
    required this.keyName,
    required this.name,
    required this.image,
    required this.rarity,
    this.isInSelectionMode = false,
    this.imgWidth = 70,
    this.imgHeight = 60,
    this.withShape = true,
    this.withTextOverflow = false,
  })  : bonus = const [],
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
    this.withShape = true,
    this.withTextOverflow = false,
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
        shape: withShape ? Styles.mainCardShape : null,
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
                image: FileImage(File(image)),
                imageErrorBuilder: (context, error, stack) {
                  //This can happen when trying to load sets like 'Prayer to xxx'
                  final path = image.replaceFirst(replaceDigitRegex, '4');
                  return Image.file(
                    File(path),
                    width: imgWidth,
                    height: imgHeight,
                  );
                },
              ),
              Tooltip(
                message: name,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  overflow: withTextOverflow ? TextOverflow.ellipsis : null,
                  style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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
