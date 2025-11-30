import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'today_materials_bloc.freezed.dart';
part 'today_materials_event.dart';
part 'today_materials_state.dart';

class TodayMaterialsBloc extends Bloc<TodayMaterialsEvent, TodayMaterialsState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  static final days = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  TodayMaterialsBloc(this._genshinService, this._telemetryService) : super(const TodayMaterialsState.loading()) {
    on<TodayMaterialsEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(TodayMaterialsEvent event, Emitter<TodayMaterialsState> emit) async {
    await _telemetryService.trackAscensionMaterialsOpened();
    switch (event) {
      case TodayMaterialsEventInit():
        final charMaterials = <TodayCharAscensionMaterialsModel>[];
        final weaponMaterials = <TodayWeaponAscensionMaterialModel>[];
        //TODO: YOU MAY WANT TO SHOW THE BOSS ITEMS AS WELL
        for (final day in days) {
          final charMaterialsForDay = _genshinService.characters.getCharacterAscensionMaterials(day);
          final weaponMaterialsForDay = _genshinService.weapons.getWeaponAscensionMaterials(day);

          for (final material in charMaterialsForDay) {
            if (charMaterials.any((m) => m.name == material.name)) {
              continue;
            }
            charMaterials.add(material);
          }

          for (final material in weaponMaterialsForDay) {
            if (weaponMaterials.any((m) => m.name == material.name)) {
              continue;
            }
            weaponMaterials.add(material);
          }
        }

        emit(TodayMaterialsState.loaded(charAscMaterials: charMaterials, weaponAscMaterials: weaponMaterials));
    }
  }
}
