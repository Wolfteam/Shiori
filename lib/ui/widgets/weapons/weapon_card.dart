import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/enums/weapon_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/extensions/rarity_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../pages/weapon_page.dart';
import '../common/gradient_card.dart';
import '../common/rarity.dart';

class WeaponCard extends StatelessWidget {
  final String image;
  final String name;
  final int rarity;
  final int baseAtk;
  final WeaponType type;

  const WeaponCard({
    Key key,
    @required this.image,
    @required this.name,
    @required this.rarity,
    @required this.baseAtk,
    @required this.type,
  }) : super(key: key);

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(image, width: 160, height: 140),
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
              Text('Atk: $baseAtk', textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              Text(
                'Type: ${s.translateWeaponType(type)}',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _gotoWeaponPage(BuildContext context) async {
    context.read<WeaponBloc>().add(WeaponEvent.loadWeapon(name: name));
    final route = MaterialPageRoute(builder: (c) => WeaponPage());
    await Navigator.push(context, route);
  }
}
