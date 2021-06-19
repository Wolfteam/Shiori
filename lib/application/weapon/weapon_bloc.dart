import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/application/common/pop_bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';

part 'weapon_bloc.freezed.dart';
part 'weapon_event.dart';
part 'weapon_state.dart';

class WeaponBloc extends PopBloc<WeaponEvent, WeaponState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final DataService _dataService;

  WeaponBloc(this._genshinService, this._telemetryService, this._dataService) : super(const WeaponState.loading());

  @override
  WeaponEvent getEventForPop(String? key) => WeaponEvent.loadFromName(key: key!, addToQueue: false);

  @override
  Stream<WeaponState> mapEventToState(
    WeaponEvent event,
  ) async* {
    if (event is! _AddedToInventory) {
      yield const WeaponState.loading();
    }

    final s = await event.when(
      loadFromImg: (img, addToQueue) async {
        final weapon = _genshinService.getWeaponByImg(img);
        final translation = _genshinService.getWeaponTranslation(weapon.key);

        if (addToQueue) {
          await _telemetryService.trackWeaponLoaded(img, loadedFromName: false);
          currentItemsInStack.add(weapon.key);
        }
        return _buildInitialState(weapon, translation);
      },
      loadFromName: (name, addToQueue) async {
        final weapon = _genshinService.getWeapon(name);
        final translation = _genshinService.getWeaponTranslation(name);

        if (addToQueue) {
          await _telemetryService.trackWeaponLoaded(name);
          currentItemsInStack.add(weapon.key);
        }
        return _buildInitialState(weapon, translation);
      },
      addedToInventory: (key, wasAdded) async {
        if (state is! _LoadedState) {
          return state;
        }

        final currentState = state as _LoadedState;
        if (currentState.key != key) {
          return state;
        }

        return currentState.copyWith.call(isInInventory: wasAdded);
      },
    );

    yield s;
  }

  WeaponState _buildInitialState(WeaponFileModel weapon, TranslationWeaponFile translation) {
    final charImgs = _genshinService.getCharacterImgsUsingWeapon(weapon.key);
    return WeaponState.loaded(
      key: weapon.key,
      name: translation.name,
      weaponType: weapon.type,
      fullImage: weapon.fullImagePath,
      rarity: weapon.rarity,
      atk: weapon.atk,
      secondaryStat: weapon.secondaryStat,
      secondaryStatValue: weapon.secondaryStatValue,
      description: translation.description,
      locationType: weapon.location,
      isInInventory: _dataService.isItemInInventory(weapon.key, ItemType.weapon),
      ascensionMaterials: weapon.ascensionMaterials,
      refinements: weapon.refinements.map(
        (e) {
          var description = translation.refinement ?? '';
          for (var i = 0; i < e.values.length; i++) {
            description = description.replaceFirst('{{$i}}', '${e.values[i]}');
          }

          return WeaponFileRefinementModel(level: e.level, description: description);
        },
      ).toList(),
      charImages: charImgs,
      stats: weapon.stats,
      craftingMaterials: weapon.craftingMaterials ?? [],
    );
  }
}
