import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/gradient_card.dart';
import 'package:shiori/presentation/shared/images/comingsoon_new_avatar.dart';
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

  const WeaponCard({
    Key? key,
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
  })  : withoutDetails = false,
        super(key: key);

  const WeaponCard.withoutDetails({
    Key? key,
    required this.keyName,
    required this.image,
    required this.name,
    required this.rarity,
    required this.isComingSoon,
    this.imgWidth = 80,
    this.imgHeight = 70,
  })  : type = null,
        baseAtk = null,
        subStatType = null,
        subStatValue = null,
        withoutDetails = true,
        isInSelectionMode = false,
        withElevation = false,
        super(key: key);

  WeaponCard.item({
    Key? key,
    required WeaponCardModel weapon,
    this.imgWidth = 160,
    this.imgHeight = 140,
    this.isInSelectionMode = false,
    this.withElevation = true,
  })  : keyName = weapon.key,
        baseAtk = weapon.baseAtk,
        image = weapon.image,
        name = weapon.name,
        rarity = weapon.rarity,
        type = weapon.type,
        subStatType = weapon.subStatType,
        subStatValue = weapon.subStatValue,
        isComingSoon = weapon.isComingSoon,
        withoutDetails = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: Styles.mainCardBorderRadius,
      onTap: () => _gotoWeaponPage(context),
      child: GradientCard(
        clipBehavior: Clip.hardEdge,
        shape: Styles.mainCardShape,
        elevation: withElevation ? Styles.cardTenElevation : 0,
        gradient: rarity.getRarityGradient(),
        child: Padding(
          padding: Styles.edgeInsetAll5,
          child: Column(
            children: [
              if (withoutDetails)
                FadeInImage(
                  width: imgWidth,
                  height: imgHeight,
                  placeholder: MemoryImage(kTransparentImage),
                  image: AssetImage(image),
                )
              else
                Stack(
                  alignment: AlignmentDirectional.topCenter,
                  fit: StackFit.passthrough,
                  children: [
                    FadeInImage(
                      width: imgWidth,
                      height: imgHeight,
                      placeholder: MemoryImage(kTransparentImage),
                      image: AssetImage(image),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ComingSoonNewAvatar(
                          isNew: false,
                          isComingSoon: isComingSoon,
                        ),
                      ],
                    ),
                  ],
                ),
              if (!withoutDetails)
                Tooltip(
                  message: name,
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              Rarity(stars: rarity),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return state.map(
                    loading: (_) => const Loading(useScaffold: false),
                    loaded: (settingsState) {
                      if (withoutDetails || !settingsState.showWeaponDetails) {
                        return const SizedBox();
                      }

                      return Container(
                        margin: Styles.edgeInsetHorizontal16,
                        child: Column(
                          children: [
                            Text(
                              '${s.translateStatTypeWithoutValue(StatType.atk)}: $baseAtk',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              '${s.type}: ${s.translateWeaponType(type!)}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              '${s.subStat}: ${s.translateStatType(subStatType!, subStatValue!)}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
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
