import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../bloc/bloc.dart';
import '../../../common/enums/stat_type.dart';
import '../../../common/enums/weapon_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/extensions/rarity_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../pages/weapon_page.dart';
import '../common/gradient_card.dart';
import '../common/loading.dart';
import '../common/rarity.dart';

class WeaponCard extends StatelessWidget {
  final String keyName;
  final String image;
  final String name;
  final int rarity;
  final int baseAtk;
  final WeaponType type;
  final StatType subStatType;
  final double subStatValue;

  final double imgWidth;
  final double imgHeight;
  final bool withoutDetails;

  const WeaponCard({
    Key key,
    @required this.keyName,
    @required this.image,
    @required this.name,
    @required this.rarity,
    @required this.baseAtk,
    @required this.type,
    @required this.subStatType,
    @required this.subStatValue,
    this.imgWidth = 160,
    this.imgHeight = 140,
  })  : withoutDetails = false,
        super(key: key);

  const WeaponCard.withoutDetails({
    Key key,
    @required this.keyName,
    @required this.image,
    @required this.name,
    @required this.rarity,
    this.imgWidth = 80,
    this.imgHeight = 70,
  })  : type = null,
        baseAtk = null,
        subStatType = null,
        subStatValue = null,
        withoutDetails = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _gotoWeaponPage(context),
      child: GradientCard(
        shape: Styles.mainCardShape,
        elevation: Styles.cardTenElevation,
        gradient: rarity.getRarityGradient(),
        child: Padding(
          padding: Styles.edgeInsetAll5,
          child: Column(
            children: [
              FadeInImage(
                width: imgWidth,
                height: imgHeight,
                placeholder: MemoryImage(kTransparentImage),
                image: AssetImage(image),
              ),
              if (!withoutDetails)
                Center(
                  child: Tooltip(
                    message: name,
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Rarity(stars: rarity),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return state.map(
                    loading: (_) => const Loading(useScaffold: false),
                    loaded: (settingsState) {
                      if (withoutDetails || !settingsState.showWeaponDetails) {
                        return Container();
                      }

                      return Container(
                        margin: Styles.edgeInsetHorizontal16,
                        child: Column(
                          children: [
                            Text(
                              '${s.translateStatTypeWithoutValue(StatType.atk)}: $baseAtk',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${s.type}: ${s.translateWeaponType(type)}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${s.subStat}: ${s.translateStatType(subStatType, subStatValue)}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
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
    context.read<WeaponBloc>().add(WeaponEvent.loadFromName(key: keyName));
    final route = MaterialPageRoute(builder: (c) => WeaponPage());
    await Navigator.push(context, route);
  }
}
