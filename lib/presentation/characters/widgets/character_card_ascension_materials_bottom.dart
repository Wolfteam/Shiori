import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/weapon_type_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/characters/widgets/character_ascension_materials.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:transparent_image/transparent_image.dart';

class CharacterCardAscensionMaterialsBottom extends StatelessWidget {
  final WeaponType weaponType;
  final List<String> materials;

  const CharacterCardAscensionMaterialsBottom({
    super.key,
    required this.weaponType,
    required this.materials,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final weaponPath = weaponType.getWeaponNormalSkillAssetPath();
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (settingsState) => !settingsState.showCharacterDetails
            ? const SizedBox.shrink()
            : IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 40,
                      child: Tooltip(
                        message: s.translateWeaponType(weaponType),
                        child: FadeInImage(
                          height: 50,
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
      ),
    );
  }
}
