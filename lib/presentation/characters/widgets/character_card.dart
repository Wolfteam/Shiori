import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/weapon_type_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/characters/widgets/character_ascension_materials.dart';
import 'package:shiori/presentation/shared/custom_divider.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/images/comingsoon_new_avatar.dart';
import 'package:shiori/presentation/shared/images/element_image.dart';
import 'package:shiori/presentation/shared/images/rarity.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';
import 'package:transparent_image/transparent_image.dart';

const double _minHeight = 400;
const double _maxHeight = 600;

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
    final s = S.of(context);
    final size = MediaQuery.of(context).size;
    double height = size.height / 2.5;
    if (height > _maxHeight) {
      height = _maxHeight;
    } else if (height < _minHeight) {
      height = _minHeight;
    }
    return SizedBox(
      height: height,
      child: InkWell(
        borderRadius: Styles.mainCardBorderRadius,
        onTap: () => _gotoCharacterPage(context),
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: Styles.mainCardShape,
          elevation: Styles.cardTenElevation,
          color: elementType.getElementColorFromContext(context),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                fit: BoxFit.cover,
                placeholderFit: BoxFit.cover,
                alignment: Alignment.topCenter,
                image: FileImage(File(image)),
                height: height,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Row(
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
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _CharBottom(
                  name: name,
                  rarity: rarity,
                  weaponType: weaponType,
                  materials: materials,
                  showMaterials: showMaterials,
                ),
              ),
            ],
          ),
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

class _CharBottom extends StatelessWidget {
  final String name;
  final int rarity;
  final WeaponType weaponType;
  final List<String> materials;
  final bool showMaterials;

  const _CharBottom({
    required this.name,
    required this.rarity,
    required this.weaponType,
    required this.materials,
    required this.showMaterials,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final String weaponPath = weaponType.getWeaponNormalSkillAssetPath();

    return Container(
      decoration: Styles.commonCardBoxDecoration,
      width: double.infinity,
      padding: Styles.edgeInsetAll5,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(useScaffold: false),
          loaded: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: name,
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Rarity(
                stars: rarity,
                starSize: 15,
                color: Colors.white,
              ),
              if (showMaterials && state.showCharacterDetails) const CustomDivider(),
              if (showMaterials && state.showCharacterDetails)
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 40,
                        child: Tooltip(
                          message: s.translateWeaponType(weaponType),
                          child: FadeInImage(
                            height: 40,
                            placeholder: MemoryImage(kTransparentImage),
                            image: AssetImage(weaponPath),
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 60,
                        child: CharacterAscensionMaterials(images: materials),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
