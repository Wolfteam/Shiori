import 'package:flutter/material.dart';
import 'package:genshindb/ui/widgets/common/rarity.dart';

import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/extensions/weapon_type_extensions.dart';
import '../../../models/characters/character_card_model.dart';
import '../../pages/character_page.dart';

class CharacterCard extends StatelessWidget {
  final CharacterCardModel model;

  CharacterCard(this.model);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoPath = "assets/characters/${model.logoName}";
    final weaponPath = model.weaponType.getWeaponAssetPath();
    final elementPath = model.elementType.getElementAsssetPath();
    final stars = <Icon>[];
    for (var i = 0; i < model.stars; i++) {
      stars.add(Icon(Icons.star_sharp, color: Colors.yellow, size: 14));
    }

    return InkWell(
      onTap: () => _gotoCharacterPage(context),
      child: Card(
        elevation: 10,
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
                    child: Image.asset(
                      logoPath,
                      fit: BoxFit.fill,
                    ),
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
                model.name,
                style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Rarity(stars: model.stars),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Image.asset(
                      weaponPath,
                      height: 50,
                    ),
                  ),
                  VerticalDivider(color: theme.accentColor),
                  Container(
                    color: Colors.red,
                    height: 50,
                    child: Text('Ascention'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNewOrComingSoonAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final newOrComingSoon = model.isNew || model.isComingSoon;
    final icon = model.isNew ? Icons.new_releases_outlined : Icons.confirmation_num;
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
        message: model.isComingSoon ? 'Coming soon' : 'New',
        child: newOrComingSoonAvatar,
      );

    return newOrComingSoonAvatar;
  }

  Future<void> _gotoCharacterPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => CharacterPage());
    await Navigator.push(context, route);
  }
}
