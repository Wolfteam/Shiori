import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';

part 'today_materials_bloc.freezed.dart';
part 'today_materials_event.dart';
part 'today_materials_state.dart';

class TodayMaterialsBloc extends Bloc<TodayMaterialsEvent, TodayMaterialsState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  TodayMaterialsBloc(this._genshinService, this._telemetryService) : super(const TodayMaterialsState.loading());

  @override
  Stream<TodayMaterialsState> mapEventToState(
    TodayMaterialsEvent event,
  ) async* {
    await _telemetryService.trackAscensionMaterialsOpened();
    final s = event.when(
      init: () {
        final days = [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ];

        final charMaterials = <TodayCharAscensionMaterialsModel>[];
        final weaponMaterials = <TodayWeaponAscensionMaterialModel>[];
//TODO: YOU MAY WANT TO SHOW THE BOSS ITEMS AS WELL
        for (final day in days) {
          final charMaterialsForDay = _genshinService.getCharacterAscensionMaterials(day);
          final weaponMaterialsForDay = _genshinService.getWeaponAscensionMaterials(day);

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

        return TodayMaterialsState.loaded(charAscMaterials: charMaterials, weaponAscMaterials: weaponMaterials);
      },
    );

    yield s;
  }
}
