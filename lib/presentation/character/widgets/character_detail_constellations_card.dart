import 'dart:io';

import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/bullet_list.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/item_description_detail.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CharacterDetailConstellationsCard extends StatelessWidget {
  final ElementType elementType;
  final List<CharacterConstellationModel> constellations;

  const CharacterDetailConstellationsCard({
    Key? key,
    required this.elementType,
    required this.constellations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ItemDescriptionDetail(
      title: s.constellations,
      body: ResponsiveGridRow(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: constellations
            .map(
              (e) => ResponsiveGridCol(md: 6, lg: 6, xl: 6, child: _ConstellationCard(model: e, elementType: elementType)),
            )
            .toList(),
      ),
      textColor: elementType.getElementColorFromContext(context),
    );
  }
}

class _ConstellationCard extends StatelessWidget {
  final CharacterConstellationModel model;
  final ElementType elementType;

  const _ConstellationCard({
    Key? key,
    required this.model,
    required this.elementType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: elementType.getElementColorFromContext(context),
              child: model.image == Assets.noImageAvailablePath
                  ? Image.asset(model.image, width: 60, height: 60)
                  : Image.file(File(model.image), width: 60, height: 60),
            ),
            Tooltip(
              message: model.title,
              child: Text(
                model.title,
                style: theme.textTheme.subtitle1!.copyWith(color: elementType.getElementColorFromContext(context)),
                textAlign: TextAlign.center,
              ),
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
                style: theme.textTheme.bodyText2!.copyWith(fontSize: 12),
              ),
            ),
            if (model.descriptions.isNotEmpty) BulletList(items: model.descriptions),
            if (model.secondDescription != null)
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(
                  model.secondDescription!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2!.copyWith(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
