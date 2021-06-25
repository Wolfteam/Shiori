import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/weapon_type_extensions.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:transparent_image/transparent_image.dart';

import 'character_ascension_materials.dart';

class CharacterCardAscensionMaterialsBottom extends StatelessWidget {
  final WeaponType weaponType;
  final List<String> materials;

  const CharacterCardAscensionMaterialsBottom({
    Key? key,
    required this.weaponType,
    required this.materials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final weaponPath = weaponType.getWeaponAssetPath();
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(useScaffold: false),
          loaded: (settingsState) => !settingsState.showCharacterDetails
              ? Container()
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
                      )
                    ],
                  ),
                ),
        );
      },
    );
  }
}
