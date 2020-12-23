import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/enums/weapon_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/extensions/weapon_type_extensions.dart';
import '../../../common/genshin_db_icons.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../widgets/characters/character_detail.dart';
import '../../widgets/common/element_image.dart';
import '../../widgets/common/item_description.dart';
import '../../widgets/common/rarity.dart';

class CharacterDetailGeneralCard extends StatelessWidget {
  final String name;
  final int rarity;
  final ElementType elementType;
  final WeaponType weaponType;
  final String region;
  final String role;
  final bool isFemale;

  const CharacterDetailGeneralCard({
    Key key,
    @required this.name,
    @required this.rarity,
    @required this.elementType,
    @required this.weaponType,
    @required this.region,
    @required this.role,
    @required this.isFemale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Card(
      color: elementType.getElementColorFromContext(context).withOpacity(0.1),
      elevation: Styles.cardTenElevation,
      margin: Styles.edgeInsetAll5,
      shape: Styles.cardShape,
      child: Padding(
        padding: Styles.edgeInsetAll10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: theme.textTheme.headline5.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            Rarity(stars: rarity, starSize: 25, alignment: MainAxisAlignment.start),
            ItemDescription(
              title: s.element,
              widget: ElementImage.fromType(type: elementType, radius: 12, useDarkForBackgroundColor: true),
              useColumn: false,
            ),
            ItemDescription(
              title: s.region,
              widget: Text(
                region,
                style: const TextStyle(color: Colors.white),
              ),
              useColumn: false,
            ),
            ItemDescription(
              title: s.weapon,
              widget: Image.asset(weaponType.getWeaponAssetPath(), width: imgSize, height: imgSize),
              useColumn: false,
            ),
            ItemDescription(
              title: s.role,
              widget: Text(
                role,
                style: const TextStyle(color: Colors.white),
              ),
              useColumn: false,
            ),
            ItemDescription(
              title: s.gender,
              widget: Icon(isFemale ? GenshinDb.female : GenshinDb.male, color: isFemale ? Colors.pink : Colors.blue),
              useColumn: false,
            ),
          ],
        ),
      ),
    );
  }
}
