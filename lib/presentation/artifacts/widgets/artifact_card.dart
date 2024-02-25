import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/artifact/artifact_page.dart';
import 'package:shiori/presentation/shared/custom_divider.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/gradient_card.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:transparent_image/transparent_image.dart';

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

  static const double itemWidth = 200;
  static const double itemHeight = 220;

  const ArtifactCard({
    super.key,
    required this.keyName,
    required this.name,
    required this.image,
    required this.rarity,
    required this.bonus,
    this.imgWidth = itemWidth,
    this.imgHeight = itemHeight,
    this.withElevation = true,
    this.isInSelectionMode = false,
    this.withShape = true,
    this.withTextOverflow = false,
  }) : withoutDetails = false;

  const ArtifactCard.withoutDetails({
    super.key,
    required this.keyName,
    required this.name,
    required this.image,
    required this.rarity,
    this.isInSelectionMode = false,
    this.imgWidth = 80,
    this.imgHeight = 60,
    this.withShape = true,
    this.withTextOverflow = false,
  })  : bonus = const [],
        withoutDetails = true,
        withElevation = false;

  ArtifactCard.item({
    super.key,
    required ArtifactCardModel item,
    this.imgWidth = itemWidth,
    this.imgHeight = itemHeight,
    this.withElevation = true,
    this.withoutDetails = false,
    this.isInSelectionMode = false,
    this.withShape = true,
    this.withTextOverflow = false,
  })  : keyName = item.key,
        name = item.name,
        image = item.image,
        rarity = item.rarity,
        bonus = item.bonus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: imgWidth,
      height: imgHeight,
      child: InkWell(
        borderRadius: Styles.mainCardBorderRadius,
        onTap: () => _gotoDetailPage(context),
        child: GradientCard(
          shape: withShape ? Styles.mainCardShape : null,
          elevation: withElevation ? Styles.cardTenElevation : 0,
          gradient: rarity.getRarityGradient(),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              FadeInImage(
                width: imgWidth,
                height: imgHeight,
                placeholder: MemoryImage(kTransparentImage),
                fit: BoxFit.fill,
                placeholderFit: BoxFit.fill,
                alignment: Alignment.topCenter,
                image: FileImage(File(image)),
                imageErrorBuilder: (context, error, stack) {
                  //This can happen when trying to load sets like 'Prayer to xxx'
                  final path = getArtifactPathByOrder(0, image);
                  return Image.file(
                    File(path),
                    width: imgWidth,
                    height: imgHeight,
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _Bottom(
                  name: name,
                  rarity: rarity,
                  bonus: bonus,
                  withoutDetails: withoutDetails,
                ),
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

class _Bottom extends StatelessWidget {
  final String name;
  final int rarity;
  final List<ArtifactCardBonusModel> bonus;
  final bool withoutDetails;

  const _Bottom({
    required this.name,
    required this.rarity,
    required this.bonus,
    required this.withoutDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: withoutDetails ? null : Styles.edgeInsetAll5,
      decoration: Styles.commonCardBoxDecoration,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: name,
            child: Text(
              name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Rarity(
            stars: rarity,
            color: Colors.white,
            compact: withoutDetails,
          ),
          if (!withoutDetails) const CustomDivider(),
        ],
      ),
    );
  }
}
