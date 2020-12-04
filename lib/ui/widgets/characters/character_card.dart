import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/enums/weapon_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/extensions/weapon_type_extensions.dart';
import '../../../common/styles.dart';
import '../../pages/character_page.dart';
import '../common/rarity.dart';
import 'character_ascention_materials.dart';

class CharacterCard extends StatelessWidget {
  final String logoName;
  final String name;
  final int rarity;
  final WeaponType weaponType;
  final ElementType elementType;
  final bool isNew;
  final bool isComingSoon;
  final List<String> materials;

  const CharacterCard({
    Key key,
    @required this.logoName,
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
    final logoPath = "assets/characters/$logoName";
    final weaponPath = weaponType.getWeaponAssetPath();
    final elementPath = elementType.getElementAsssetPath();

    return InkWell(
      onTap: () => _gotoCharacterPage(context),
      child: Card(
        shape: Styles.mainCardShape,
        elevation: Styles.cardTenElevation,
        color: elementType.getElementColor(),
        child: Padding(
          padding: Styles.edgeInsetAll10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: EdgeInsets.only(top: 5),
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  fit: StackFit.passthrough,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Image.asset(logoPath, fit: BoxFit.fill),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNewOrComingSoonAvatar(context),
                        Tooltip(
                          message: 'Electro',
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.black.withAlpha(100),
                            backgroundImage: AssetImage(elementPath),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Center(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Rarity(stars: rarity),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Tooltip(message: '$weaponType', child: Image.asset(weaponPath, height: 50))),
                    VerticalDivider(color: theme.accentColor),
                    Expanded(child: CharacterAscentionMaterials(images: materials))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewOrComingSoonAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final newOrComingSoon = isNew || isComingSoon;
    final icon = isNew ? Icons.new_releases_outlined : Icons.confirmation_num;
    final newOrComingSoonAvatar = CircleAvatar(
      radius: 15,
      backgroundColor: newOrComingSoon ? theme.accentColor : Colors.transparent,
      child: newOrComingSoon
          ? Icon(
              icon,
              color: Colors.white,
            )
          : null,
    );
    if (newOrComingSoon)
      return Tooltip(
        message: isComingSoon ? 'Coming soon' : 'New',
        child: newOrComingSoonAvatar,
      );

    return newOrComingSoonAvatar;
  }

  Future<void> _gotoCharacterPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => CharacterPage());
    await Navigator.push(context, route);
  }
}
