import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/settings_service.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GenshinService _genshinService;
  final SettingsService _settingsService;

  HomeBloc(this._genshinService, this._settingsService) : super(const HomeState.loading());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    final s = event.when(
      init: () {
        final day = _genshinService.getServerDay(_settingsService.serverResetTime);

        final charMaterials = _genshinService.getCharacterAscensionMaterials(day);
        final weaponMaterials = _genshinService.getWeaponAscensionMaterials(day);
        final charsForBirthday = _genshinService.getCharactersForBirthday(DateTime.now()).map((e) => Assets.getCharacterPath(e.image)).toList();

        return HomeState.loaded(charAscMaterials: charMaterials, weaponAscMaterials: weaponMaterials, characterImgBirthday: charsForBirthday);
      },
    );

    yield s;
  }
}
