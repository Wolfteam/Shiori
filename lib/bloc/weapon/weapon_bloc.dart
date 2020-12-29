import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums/item_location_type.dart';
import '../../common/enums/stat_type.dart';
import '../../common/enums/weapon_type.dart';
import '../../models/models.dart';
import '../../services/genshing_service.dart';

part 'weapon_bloc.freezed.dart';
part 'weapon_event.dart';
part 'weapon_state.dart';

class WeaponBloc extends Bloc<WeaponEvent, WeaponState> {
  final GenshinService _genshinService;
  WeaponBloc(this._genshinService) : super(const WeaponState.loading());

  @override
  Stream<WeaponState> mapEventToState(
    WeaponEvent event,
  ) async* {
    yield const WeaponState.loading();
    final s = event.when(
      loadFromImg: (img) {
        final weapon = _genshinService.getWeaponByImg(img);
        final translation = _genshinService.getWeaponTranslation(weapon.name);
        return _buildInitialState(weapon, translation);
      },
      loadFromName: (name) {
        final weapon = _genshinService.getWeapon(name);
        final translation = _genshinService.getWeaponTranslation(name);
        return _buildInitialState(weapon, translation);
      },
    );

    yield s;
  }

  WeaponState _buildInitialState(WeaponFileModel weapon, TranslationWeaponFile translation) {
    return WeaponState.loaded(
      name: weapon.name,
      weaponType: weapon.type,
      fullImage: weapon.fullImagePath,
      rarity: weapon.rarity,
      atk: weapon.atk,
      secondaryStat: weapon.secondaryStat,
      secondaryStatValue: weapon.secondaryStatValue,
      description: translation.description,
      locationType: weapon.location,
      ascentionMaterials: weapon.ascentionMaterials,
      refinements: weapon.refinements.map(
        (e) {
          var description = translation.refinement;
          for (var i = 0; i < e.values.length; i++) {
            description = description.replaceFirst('{{$i}}', '${e.values[i]}');
          }

          return WeaponFileRefinementModel(level: e.level, description: description);
        },
      ).toList(),
    );
  }
}
