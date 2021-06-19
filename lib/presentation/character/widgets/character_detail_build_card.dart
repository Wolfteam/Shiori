import 'package:flutter/material.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/iterable_extensions.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/artifacts/widgets/artifact_card.dart';
import 'package:genshindb/presentation/shared/extensions/element_type_extensions.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/weapons/widgets/weapon_card.dart';

class CharacterDetailBuildCard extends StatelessWidget {
  final ElementType elementType;
  final bool isForSupport;
  final List<WeaponCardModel> weapons;
  final List<CharacterBuildArtifactModel> artifacts;
  final List<StatType> subStatsToFocus;
  final double imgHeight = 125;

  final replaceDigitRegex = RegExp(r'\d{1}');

  CharacterDetailBuildCard({
    Key? key,
    required this.elementType,
    required this.isForSupport,
    required this.weapons,
    required this.artifacts,
    required this.subStatsToFocus,
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
            Text(
              isForSupport ? s.support : s.dps,
              style: theme.textTheme.headline6!.copyWith(color: elementType.getElementColorFromContext(context)),
            ),
            Container(
              margin: Styles.edgeInsetAll5,
              child: Text(
                s.weapons,
                style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _buildWeapons(context),
            Container(
              margin: Styles.edgeInsetAll5,
              child: Text(
                s.artifacts,
                style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (subStatsToFocus.isNotEmpty) _buildSubStatsToFocus(context),
            ..._buildArtifacts(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWeapons(BuildContext context) {
    final widgets = <Widget>[];

    for (var i = 0; i < weapons.length; i++) {
      final weapon = weapons[i];
      final child = WeaponCard.withoutDetails(
        keyName: weapon.key,
        name: weapon.name,
        rarity: weapon.rarity,
        image: weapon.image,
        isComingSoon: weapon.isComingSoon,
      );
      widgets.add(child);

      if (i < weapons.length - 1) {
        widgets.add(_buildOrWidget(context));
      }
    }

    return SizedBox(
      height: imgHeight,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: widgets,
      ),
    );
  }

  List<Widget> _buildArtifacts(BuildContext context) {
    final s = S.of(context);
    final widgets = <Widget>[];
    for (var i = 0; i < artifacts.length; i++) {
      final artifact = artifacts[i];
      if (artifact.one != null) {
        final widget = _buildArtifactOne(s, artifact);
        widgets.add(widget);
      }

      if (artifact.multiples.isNotEmpty) {
        final widget = _buildMultipleArtifact(s, artifact);
        widgets.add(widget);
      }

      if (i < artifacts.length - 1) {
        widgets.add(_buildOrWidget(context));
      }
    }

    return widgets;
  }

  Widget _buildArtifactOne(S s, CharacterBuildArtifactModel artifact) {
    final items = artifactOrder.mapIndex(
      (digit, index) {
        final stat = artifact.stats[index];
        final path = artifact.one!.image.replaceFirst(replaceDigitRegex, '$digit');
        return ArtifactCard.withoutDetails(
          name: s.translateStatTypeWithoutValue(stat),
          image: path,
          rarity: artifact.one!.rarity,
          keyName: artifact.one!.key,
        );
      },
    ).toList();
    return SizedBox(
      height: imgHeight,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: items,
      ),
    );
  }

  Widget _buildMultipleArtifact(S s, CharacterBuildArtifactModel artifact) {
    final children = <Widget>[];
    final order = [...artifactOrder];
    var statIndex = 0;

    for (var y = 0; y < artifact.multiples.length; y++) {
      final art = artifact.multiples[y];
      for (var i = 0; i < art.quantity; i++) {
        final startFrom = order.first;
        final widget = _buildWidgetForMultipleArtifact(statIndex, startFrom, artifact, art, s);
        children.add(widget);

        order.remove(startFrom);
        statIndex++;
      }
    }

    if (order.isNotEmpty) {
      final art = artifact.multiples.last;
      final until = order.length;
      for (var i = 0; i < until; i++) {
        final startFrom = order.first;
        final widget = _buildWidgetForMultipleArtifact(statIndex, startFrom, artifact, art, s);
        children.add(widget);

        order.remove(startFrom);
        statIndex++;
      }
    }

    final widget = SizedBox(
      height: imgHeight,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: children,
      ),
    );
    return widget;
  }

  Widget _buildOrWidget(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetAll5,
      padding: Styles.edgeInsetAll5,
      decoration: BoxDecoration(
        color: elementType.getElementColorFromContext(context),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          s.or,
          textAlign: TextAlign.center,
          style: theme.textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildWidgetForMultipleArtifact(
    int statIndex,
    int startFrom,
    CharacterBuildArtifactModel artifact,
    CharacterBuildMultipleArtifactModel current,
    S s,
  ) {
    final stat = artifact.stats[statIndex];
    final path = current.artifact.image.replaceFirst(replaceDigitRegex, '$startFrom');
    return ArtifactCard.withoutDetails(
      name: s.translateStatTypeWithoutValue(stat),
      image: path,
      rarity: current.artifact.rarity,
      keyName: current.artifact.key,
    );
  }

  Widget _buildSubStatsToFocus(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final text = subStatsToFocus.map((e) => s.translateStatTypeWithoutValue(e)).join(' > ');
    return Container(
      margin: Styles.edgeInsetHorizontal5,
      child: Text(
        '${s.subStats}: $text',
        style: theme.textTheme.subtitle2!.copyWith(
          fontWeight: FontWeight.bold,
          color: elementType.getElementColorFromContext(context),
          fontSize: 12,
        ),
      ),
    );
  }
}
