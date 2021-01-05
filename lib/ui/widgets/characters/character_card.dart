import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../bloc/bloc.dart';
import '../../../common/enums/element_type.dart';
import '../../../common/enums/weapon_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../pages/character_page.dart';
import '../common/comingsoon_new_avatar.dart';
import '../common/element_image.dart';
import '../common/rarity.dart';
import 'character_card_ascention_materials_bottom.dart';

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return InkWell(
      onTap: () => _gotoCharacterPage(context),
      child: Card(
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
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Rarity(stars: rarity),
                  CharacterCardAscentionMaterialsBottom(
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
    if (isComingSoon) {
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

    context.read<CharacterBloc>().add(CharacterEvent.loadFromName(key: keyName));
    final route = MaterialPageRoute(builder: (c) => const CharacterPage());
    await Navigator.push(context, route);
  }
}
