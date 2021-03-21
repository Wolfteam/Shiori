import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/character/character_page.dart';
import 'package:genshindb/presentation/shared/comingsoon_new_avatar.dart';
import 'package:genshindb/presentation/shared/element_image.dart';
import 'package:genshindb/presentation/shared/extensions/element_type_extensions.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/rarity.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:transparent_image/transparent_image.dart';

import 'character_card_ascension_materials_bottom.dart';

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
    Key key,
    @required this.keyName,
    @required this.image,
    @required this.name,
    @required this.rarity,
    @required this.weaponType,
    @required this.elementType,
    @required this.isNew,
    @required this.isComingSoon,
    @required this.materials,
    this.isInSelectionMode = false,
    this.showMaterials = true,
  }) : super(key: key);

  CharacterCard.item({
    Key key,
    CharacterCardModel char,
    this.isInSelectionMode = false,
    this.showMaterials = true,
  })  : keyName = char.key,
        elementType = char.elementType,
        isComingSoon = char.isComingSoon,
        isNew = char.isNew,
        image = char.logoName,
        name = char.name,
        rarity = char.stars,
        weaponType = char.weaponType,
        materials = char.materials,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
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
                FadeInImage(
                  height: 280,
                  placeholder: MemoryImage(kTransparentImage),
                  image: AssetImage(image),
                  fit: BoxFit.cover,
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
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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
      final theme = Theme.of(context);
      final s = S.of(context);
      Fluttertoast.showToast(
        msg: s.comingSoon,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: theme.accentColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (isInSelectionMode) {
      Navigator.pop(context, keyName);
      return;
    }

    final bloc = context.read<CharacterBloc>();
    bloc.add(CharacterEvent.loadFromName(key: keyName));
    final route = MaterialPageRoute(builder: (c) => const CharacterPage());
    await Navigator.push(context, route);
    bloc.pop();
  }
}
