import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';

part 'weapon_bloc.freezed.dart';
part 'weapon_event.dart';
part 'weapon_state.dart';

class WeaponBloc extends Bloc<WeaponEvent, WeaponState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  WeaponBloc(this._genshinService, this._telemetryService) : super(const WeaponState.loading());

  @override
  Stream<WeaponState> mapEventToState(
    WeaponEvent event,
  ) async* {
    yield const WeaponState.loading();
    final s = await event.when(
      loadFromImg: (img) async {
        await _telemetryService.trackWeaponLoaded(img, loadedFromName: false);
        final weapon = _genshinService.getWeaponByImg(img);
        final translation = _genshinService.getWeaponTranslation(weapon.key);
        return _buildInitialState(weapon, translation);
      },
      loadFromName: (name) async {
        await _telemetryService.trackWeaponLoaded(name);
        final weapon = _genshinService.getWeapon(name);
        final translation = _genshinService.getWeaponTranslation(name);
        return _buildInitialState(weapon, translation);
      },
    );

    yield s;
  }

  WeaponState _buildInitialState(WeaponFileModel weapon, TranslationWeaponFile translation) {
    final charImgs = _genshinService.getCharactersImgUsingWeapon(weapon.key);
    return WeaponState.loaded(
      name: translation.name,
      weaponType: weapon.type,
      fullImage: weapon.fullImagePath,
      rarity: weapon.rarity,
      atk: weapon.atk,
      secondaryStat: weapon.secondaryStat,
      secondaryStatValue: weapon.secondaryStatValue,
      description: translation.description,
      locationType: weapon.location,
      ascensionMaterials: weapon.ascensionMaterials,
      refinements: weapon.refinements.map(
        (e) {
          var description = translation.refinement;
          for (var i = 0; i < e.values.length; i++) {
            description = description.replaceFirst('{{$i}}', '${e.values[i]}');
          }

          return WeaponFileRefinementModel(level: e.level, description: description);
        },
      ).toList(),
      charImages: charImgs,
    );
  }
}
