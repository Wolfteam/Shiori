import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/models.dart';
import '../../services/genshing_service.dart';

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

        for (final day in days) {
          charMaterials.addAll(_genshinService.getCharacterAscentionMaterials(day));
          weaponMaterials.addAll(_genshinService.getWeaponAscentionMaterials(day));
        }

        return MaterialsState.loaded(charAscMaterials: charMaterials, weaponAscMaterials: weaponMaterials);
      },
    );

    yield s;
  }
}
