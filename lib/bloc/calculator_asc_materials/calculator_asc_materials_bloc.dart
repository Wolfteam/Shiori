import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/assets.dart';
import '../../models/models.dart';
import '../../services/genshing_service.dart';

part 'calculator_asc_materials_bloc.freezed.dart';

part 'calculator_asc_materials_event.dart';

part 'calculator_asc_materials_state.dart';

class CalculatorAscMaterialsBloc extends Bloc<CalculatorAscMaterialsEvent, CalculatorAscMaterialsState> {
  final GenshinService _genshinService;

  _InitialState get currentState => state as _InitialState;

  CalculatorAscMaterialsBloc(this._genshinService) : super(const CalculatorAscMaterialsState.initial(items: [], summary: []));

  //TODO: CALCULATE THE SUMMARY
  @override
  Stream<CalculatorAscMaterialsState> mapEventToState(
    CalculatorAscMaterialsEvent event,
  ) async* {
    final s = event.map(
      init: (_) => const CalculatorAscMaterialsState.initial(items: [], summary: []),
      addCharacter: (e) {
        final char = _genshinService.getCharacter(e.key);
        final translation = _genshinService.getCharacterTranslation(e.key);
        final materials = char.ascentionMaterials.expand((e) => e.materials).map((e) => e).toList();
        final items = [
          ...currentState.items,
          ItemAscentionMaterials.forCharacters(
            key: e.key,
            image: Assets.getCharacterFullPath(char.fullImage),
            name: translation.name,
            rarity: char.rarity,
            materials: materials,
          )
        ];
        return currentState.copyWith.call(items: items);
      },
      addWeapon: (e) {
        final weapon = _genshinService.getWeapon(e.key);
        final translation = _genshinService.getWeaponTranslation(e.key);
        final items = [
          ...currentState.items,
          ItemAscentionMaterials.forWeapons(
            key: e.key,
            image: weapon.fullImagePath,
            name: translation.name,
            rarity: weapon.rarity,
            materials: [],
          )
        ];
        return currentState.copyWith.call(items: items);
      },
      removeItem: (e) {
        final items = [...currentState.items];
        items.removeAt(e.index);
        return currentState.copyWith.call(items: items);
      },
    );

    yield s;
  }
}
