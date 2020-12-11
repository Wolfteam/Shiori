import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/enums/element_type.dart';
import '../../../common/enums/weapon_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/extensions/weapon_type_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../pages/character_page.dart';
import '../common/rarity.dart';
import 'character_ascention_materials.dart';

class CharacterCard extends StatelessWidget {
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
    final weaponPath = weaponType.getWeaponAssetPath();
    final elementPath = elementType.getElementAsssetPath();

    return InkWell(
      onTap: isComingSoon ? null : () => _gotoCharacterPage(name, context),
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
                margin: const EdgeInsets.only(top: 5),
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  fit: StackFit.passthrough,
                  children: [
                    Image.asset(image, fit: BoxFit.fill),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNewOrComingSoonAvatar(context),
                        Tooltip(
                          message: s.translateElementType(elementType),
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
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 40,
                      child: Tooltip(
                        message: s.translateWeaponType(weaponType),
                        child: Image.asset(weaponPath, height: 50),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 5,
                      child: VerticalDivider(color: theme.accentColor),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 55,
                      child: CharacterAscentionMaterials(images: materials),
                    )
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
    final s = S.of(context);
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
    if (newOrComingSoon) {
      return Tooltip(
        message: isComingSoon ? s.comingSoon : s.recent,
        child: newOrComingSoonAvatar,
      );
    }

    return newOrComingSoonAvatar;
  }

  Future<void> _gotoCharacterPage(String name, BuildContext context) async {
    context.read<CharacterBloc>().add(CharacterEvent.loadCharacter(name: name));
    final route = MaterialPageRoute(builder: (c) => CharacterPage());
    await Navigator.push(context, route);
  }
}
