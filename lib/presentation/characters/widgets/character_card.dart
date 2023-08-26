import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/characters/widgets/character_card_ascension_materials_bottom.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/images/comingsoon_new_avatar.dart';
import 'package:shiori/presentation/shared/images/element_image.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class CharacterCard extends StatelessWidget {
  final String keyName;
  final String image;
  final String name;
  final int rarity;
  final WeaponType weaponType;
  final ElementType elementType;
  final bool isNew;
  final bool isComingSoon;
  final List<String> materials;
  final bool isInSelectionMode;
  final bool showMaterials;

  const CharacterCard({
    super.key,
    required this.keyName,
    required this.image,
    required this.name,
    required this.rarity,
    required this.weaponType,
    required this.elementType,
    required this.isNew,
    required this.isComingSoon,
    required this.materials,
    this.isInSelectionMode = false,
    this.showMaterials = true,
  });

  CharacterCard.item({
    super.key,
    required CharacterCardModel char,
    this.isInSelectionMode = false,
    this.showMaterials = true,
  })  : keyName = char.key,
        elementType = char.elementType,
        isComingSoon = char.isComingSoon,
        isNew = char.isNew,
        image = char.image,
        name = char.name,
        rarity = char.stars,
        weaponType = char.weaponType,
        materials = char.materials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final size = MediaQuery.of(context).size;
    var height = size.height / 2.5;
    if (height > 600) {
      height = 600;
    } else if (height < 280) {
      height = 280;
    }
    return InkWell(
      borderRadius: Styles.mainCardBorderRadius,
      onTap: () => _gotoCharacterPage(context),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: Styles.mainCardShape,
        elevation: Styles.cardTenElevation,
        color: elementType.getElementColorFromContext(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: AlignmentDirectional.topCenter,
              fit: StackFit.passthrough,
              children: [
                SizedBox(
                  height: height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.hardEdge,
                    child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: FileImage(File(image)),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ComingSoonNewAvatar(
                      isNew: isNew,
                      isComingSoon: isComingSoon,
                    ),
                    Tooltip(
                      message: s.translateElementType(elementType),
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, right: 5),
                        child: ElementImage.fromType(type: elementType, radius: 15, useDarkForBackgroundColor: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: Styles.edgeInsetAll10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Rarity(stars: rarity),
                  if (showMaterials)
                    CharacterCardAscensionMaterialsBottom(
                      materials: materials,
                      weaponType: weaponType,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _gotoCharacterPage(BuildContext context) async {
    if (isComingSoon && !isInSelectionMode) {
      final s = S.of(context);
      final fToast = ToastUtils.of(context);
      ToastUtils.showWarningToast(fToast, s.comingSoon);
      return;
    }

    if (isInSelectionMode) {
      Navigator.pop(context, keyName);
      return;
    }

    final route = MaterialPageRoute(builder: (c) => CharacterPage(itemKey: keyName));
    await Navigator.push(context, route);
    await route.completed;
  }
}
