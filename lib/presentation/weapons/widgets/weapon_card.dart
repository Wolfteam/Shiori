import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/custom_divider.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/gradient_card.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';
import 'package:transparent_image/transparent_image.dart';

class WeaponCard extends StatelessWidget {
  final String keyName;
  final String image;
  final String name;
  final int rarity;
  final double? baseAtk;
  final WeaponType? type;
  final StatType? subStatType;
  final double? subStatValue;
  final bool isComingSoon;

  final double imgWidth;
  final double imgHeight;
  final bool withoutDetails;
  final bool isInSelectionMode;
  final bool withElevation;
  final bool withShape;

  const WeaponCard({
    super.key,
    required this.keyName,
    required this.image,
    required this.name,
    required this.rarity,
    required this.baseAtk,
    required this.type,
    required this.subStatType,
    required this.subStatValue,
    required this.isComingSoon,
    this.imgWidth = 160,
    this.imgHeight = 140,
    this.isInSelectionMode = false,
    this.withElevation = true,
    this.withShape = true,
  }) : withoutDetails = false;

  const WeaponCard.withoutDetails({
    super.key,
    required this.keyName,
    required this.image,
    required this.name,
    required this.rarity,
    required this.isComingSoon,
    this.imgWidth = 80,
    this.imgHeight = 70,
    this.withShape = true,
  })  : type = null,
        baseAtk = null,
        subStatType = null,
        subStatValue = null,
        withoutDetails = true,
        isInSelectionMode = false,
        withElevation = false;

  WeaponCard.item({
    super.key,
    required WeaponCardModel weapon,
    this.imgWidth = 160,
    this.imgHeight = 140,
    this.isInSelectionMode = false,
    this.withElevation = true,
    this.withShape = true,
  })  : keyName = weapon.key,
        baseAtk = weapon.baseAtk,
        image = weapon.image,
        name = weapon.name,
        rarity = weapon.rarity,
        type = weapon.type,
        subStatType = weapon.subStatType,
        subStatValue = weapon.subStatValue,
        isComingSoon = weapon.isComingSoon,
        withoutDetails = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: imgWidth * 1.5,
      height: imgHeight * 2.3,
      child: InkWell(
        borderRadius: Styles.mainCardBorderRadius,
        onTap: () => _gotoWeaponPage(context),
        child: GradientCard(
          clipBehavior: Clip.hardEdge,
          shape: withShape ? Styles.mainCardShape : null,
          elevation: withElevation ? Styles.cardTenElevation : 0,
          gradient: rarity.getRarityGradient(),
          child: Padding(
            padding: Styles.edgeInsetAll5,
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
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _Bottom(
                    name: name,
                    rarity: rarity,
                    baseAtk: baseAtk,
                    type: type,
                    subStatType: subStatType,
                    subStatValue: subStatValue,
                    withoutDetails: withoutDetails,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _gotoWeaponPage(BuildContext context) async {
    if (isInSelectionMode) {
      Navigator.pop(context, keyName);
      return;
    }

    final route = MaterialPageRoute(builder: (c) => WeaponPage(itemKey: keyName));
    await Navigator.push(context, route);
    await route.completed;
  }
}

class _Bottom extends StatelessWidget {
  final String name;
  final int rarity;
  final double? baseAtk;
  final WeaponType? type;
  final StatType? subStatType;
  final double? subStatValue;
  final bool withoutDetails;

  const _Bottom({
    required this.name,
    required this.rarity,
    this.baseAtk,
    this.type,
    this.subStatType,
    this.subStatValue,
    required this.withoutDetails,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final detailTextStyle = theme.textTheme.bodySmall!.copyWith(color: Colors.white);
    return Container(
      padding: Styles.edgeInsetAll5,
      decoration: BoxDecoration(boxShadow: Styles.commonBlackShadow),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(useScaffold: false),
          loaded: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!withoutDetails)
                Tooltip(
                  message: name,
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              Rarity(
                stars: rarity,
                color: Colors.white,
                compact: withoutDetails,
              ),
              if (!withoutDetails && state.showWeaponDetails) const CustomDivider(),
              if (!withoutDetails && state.showWeaponDetails)
                Text(
                  '${s.translateStatTypeWithoutValue(StatType.atk)}: $baseAtk',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: detailTextStyle,
                ),
              if (!withoutDetails && state.showWeaponDetails)
                Text(
                  '${s.type}: ${s.translateWeaponType(type!)}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: detailTextStyle,
                ),
              if (!withoutDetails && state.showWeaponDetails)
                Text(
                  '${s.subStat}: ${s.translateStatType(subStatType!, subStatValue!)}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: detailTextStyle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
