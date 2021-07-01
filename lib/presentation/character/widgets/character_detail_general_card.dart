import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/extensions/weapon_type_extensions.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/element_image.dart';
import 'package:genshindb/presentation/shared/extensions/element_type_extensions.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';
import 'package:genshindb/presentation/shared/item_description.dart';
import 'package:genshindb/presentation/shared/rarity.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'character_detail.dart';

class CharacterDetailGeneralCard extends StatelessWidget {
  final String name;
  final int rarity;
  final ElementType elementType;
  final WeaponType weaponType;
  final RegionType region;
  final String role;
  final bool isFemale;
  final String? birthday;

  const CharacterDetailGeneralCard({
    Key? key,
    required this.name,
    required this.rarity,
    required this.elementType,
    required this.weaponType,
    required this.region,
    required this.role,
    required this.isFemale,
    this.birthday,
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
            Text(name, style: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            Rarity(stars: rarity, starSize: 25, alignment: MainAxisAlignment.start),
            ItemDescription(
              title: s.element,
              widget: ElementImage.fromType(type: elementType, radius: 12, useDarkForBackgroundColor: true),
              useColumn: false,
            ),
            ItemDescription(
              title: s.region,
              widget: Text(
                s.translateRegionType(region),
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
            if (birthday.isNotNullEmptyOrWhitespace)
              ItemDescription(
                title: s.birthday,
                widget: Text(birthday!, style: const TextStyle(color: Colors.white)),
                useColumn: false,
              ),
          ],
        ),
      ),
    );
  }
}
