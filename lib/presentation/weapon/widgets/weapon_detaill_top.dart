import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/presentation/shared/extensions/rarity_extensions.dart';

import 'weapon_detail_general_card.dart';

const double imageHeight = 320;
const double imgSize = 28;

class WeaponDetailTop extends StatelessWidget {
  final String name;
  final int atk;
  final int rarity;
  final StatType secondaryStatType;
  final double secondaryStatValue;
  final WeaponType type;
  final ItemLocationType locationType;
  final String image;

  const WeaponDetailTop({
    Key key,
    @required this.name,
    @required this.atk,
    @required this.rarity,
    @required this.secondaryStatType,
    @required this.secondaryStatValue,
    @required this.type,
    @required this.locationType,
    @required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final descriptionWidth = mediaQuery.size.width / (isPortrait ? 1.2 : 2);
    //TODO: IM NOT SURE HOW THIS WILL LOOK LIKE IN BIGGER DEVICES
    // final padding = mediaQuery.padding;
    // final screenHeight = mediaQuery.size.height - padding.top - padding.bottom;

    return Container(
      decoration: BoxDecoration(gradient: rarity.getRarityGradient()),
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Container(
              transform: Matrix4.translationValues(80, -30, 0.0),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  image,
                  width: 350,
                  height: imageHeight,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Image.asset(
              image,
              width: 340,
              height: imageHeight,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: descriptionWidth,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: WeaponDetailGeneralCard(
                type: type,
                atk: atk,
                locationType: locationType,
                name: name,
                rarity: rarity,
                secondaryStatValue: secondaryStatValue,
                statType: secondaryStatType,
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(backgroundColor: Colors.transparent, elevation: 0.0),
          ),
        ],
      ),
    );
  }
}
