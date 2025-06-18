import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GenshinService _genshinService;
  final SettingsService _settingsService;
  final LocaleService _localeService;

  HomeBloc(this._genshinService, this._settingsService, this._localeService) : super(const HomeState.loading());

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    switch (event) {
      case HomeEventInit():
        final date = _genshinService.getServerDate(_settingsService.serverResetTime);
        final day = date.weekday;
        yield _buildInitialState(day);
      case HomeEventDayChanged():
        yield _buildInitialState(event.newDay);
    }
  }

  HomeState _buildInitialState(int day) {
    final now = DateTime.now();
    final charMaterials = _genshinService.characters.getCharacterAscensionMaterials(day);
    final weaponMaterials = _genshinService.weapons.getWeaponAscensionMaterials(day);
    final charsForBirthday = _genshinService.characters
        .getCharacterBirthdays(month: now.month, day: now.day)
        .orderBy((e) => e.name)
        .map(
          (e) => ItemCommon(e.key, e.image, e.iconImage),
        )
        .toList();
    final dayName = _localeService.getDayNameFromDay(day);

    return HomeState.loaded(
      charAscMaterials: charMaterials,
      weaponAscMaterials: weaponMaterials,
      characterImgBirthday: charsForBirthday,
      day: day,
      dayName: dayName,
    );
  }
}
