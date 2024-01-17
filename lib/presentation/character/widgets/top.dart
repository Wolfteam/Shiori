import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/extensions/weapon_type_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_general_card.dart';
import 'package:shiori/presentation/shared/details/detail_top_layout.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/images/element_image.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/styles.dart';

class Top extends StatelessWidget {
  final String itemKey;
  final ElementType elementType;
  final String fullImage;
  final String? secondFullImage;
  final String name;
  final int rarity;
  final RegionType region;
  final CharacterRoleType role;
  final WeaponType weaponType;
  final String? birthday;
  final bool isInInventory;

  const Top({
    required this.itemKey,
    required this.elementType,
    required this.fullImage,
    this.secondFullImage,
    required this.name,
    required this.rarity,
    required this.region,
    required this.role,
    required this.weaponType,
    this.birthday,
    required this.isInInventory,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium!.copyWith(color: Colors.white);
    return DetailTopLayout(
      color: elementType.getElementColorFromContext(context),
      fullImage: fullImage,
      secondFullImage: secondFullImage,
      generalCard: DetailGeneralCardNew(
        itemName: name,
        color: elementType.getElementColorFromContext(context),
        rows: [
          GeneralCardRow(
            left: GeneralCardColumn(
              title: s.rarity,
              child: Rarity(
                stars: rarity,
                color: Colors.white,
                centered: false,
              ),
            ),
            right: GeneralCardColumn(
              title: s.element,
              child: Row(
                children: [
                  ElementImage.fromType(
                    type: elementType,
                    radius: 10,
                    useDarkForBackgroundColor: true,
                    imageColor: ElementImageColorType.white,
                    margin: EdgeInsets.zero,
                    useCircleAvatar: false,
                  ),
                  Text(
                    s.translateElementType(elementType),
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          GeneralCardRow(
            left: GeneralCardColumn(
              title: s.weapon,
              child: Row(
                children: [
                  Image.asset(
                    weaponType.getWeaponNormalSkillAssetPath(),
                    width: 20,
                    height: 20,
                  ),
                  Text(
                    s.translateWeaponType(weaponType),
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            right: GeneralCardColumn(
              title: s.role,
              child: Text(
                s.translateCharacterRoleType(role),
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GeneralCardRow(
            left: GeneralCardColumn(
              title: s.region,
              child: Text(
                s.translateRegionType(region),
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            right: GeneralCardColumn(
              title: s.birthday,
              child: Text(
                birthday.isNotNullEmptyOrWhitespace ? birthday! : s.na,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(isInInventory ? Icons.favorite : Icons.favorite_border),
            color: Colors.red,
            splashRadius: Styles.mediumButtonSplashRadius,
            onPressed: () => _favoriteCharacter(itemKey, isInInventory, context),
          ),
        ],
      ),
    );
  }

  void _favoriteCharacter(String key, bool isInInventory, BuildContext context) {
    final event = !isInInventory ? CharacterEvent.addToInventory(key: key) : CharacterEvent.deleteFromInventory(key: key);
    context.read<CharacterBloc>().add(event);
  }
}
