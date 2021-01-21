import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/models.dart';
import '../../services/genshing_service.dart';
import '../../telemetry.dart';

part 'materials_bloc.freezed.dart';
part 'materials_event.dart';
part 'materials_state.dart';

class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  final GenshinService _genshinService;
  MaterialsBloc(this._genshinService) : super(const MaterialsState.loading());

  @override
  Stream<MaterialsState> mapEventToState(
    MaterialsEvent event,
  ) async* {
    await trackAscentionMaterialsOpened();
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

        final charMaterials = <TodayCharAscentionMaterialsModel>[];
        final weaponMaterials = <TodayWeaponAscentionMaterialModel>[];
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

        return MaterialsState.loaded(charAscMaterials: charMaterials, weaponAscMaterials: weaponMaterials);
      },
    );

    yield s;
  }
}
