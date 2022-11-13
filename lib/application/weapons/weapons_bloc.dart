import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/settings_service.dart';

part 'weapons_bloc.freezed.dart';
part 'weapons_event.dart';
part 'weapons_state.dart';

class WeaponsBloc extends Bloc<WeaponsEvent, WeaponsState> {
  final GenshinService _genshinService;
  final SettingsService _settingsService;
  final List<WeaponCardModel> _allWeapons = [];

  WeaponsBloc(this._genshinService, this._settingsService) : super(const WeaponsState.loading());

  _LoadedState get currentState => state as _LoadedState;

  @override
  Stream<WeaponsState> mapEventToState(WeaponsEvent event) async* {
    final s = event.map(
      init: (e) {
        if (_allWeapons.isEmpty) {
          _allWeapons.addAll(_genshinService.weapons.getWeaponsForCard());
        }

        return _buildInitialState(
          excludeKeys: e.excludeKeys,
          weaponTypes: e.weaponTypes.isEmpty ? WeaponType.values : e.weaponTypes,
          areWeaponTypesEnabled: e.areWeaponTypesEnabled,
        );
      },
      weaponFilterTypeChanged: (e) => currentState.copyWith.call(tempWeaponFilterType: e.filterType),
      rarityChanged: (e) => currentState.copyWith.call(tempRarity: e.rarity),
      sortDirectionTypeChanged: (e) => currentState.copyWith.call(tempSortDirectionType: e.sortDirectionType),
      weaponTypeChanged: (e) {
        var types = <WeaponType>[];
        if (currentState.tempWeaponTypes.contains(e.weaponType)) {
          types = currentState.tempWeaponTypes.where((t) => t != e.weaponType).toList();
        } else {
          types = currentState.tempWeaponTypes + [e.weaponType];
        }
        return currentState.copyWith.call(tempWeaponTypes: types);
      },
      weaponSubStatTypeChanged: (e) => currentState.copyWith.call(tempWeaponSubStatType: e.subStatType),
      weaponLocationTypeChanged: (e) => currentState.copyWith.call(tempWeaponLocationType: e.locationType),
      searchChanged: (e) => _buildInitialState(
        search: e.search,
        weaponFilterType: currentState.weaponFilterType,
        rarity: currentState.rarity,
        sortDirectionType: currentState.sortDirectionType,
        weaponTypes: currentState.weaponTypes,
        weaponSubStatType: currentState.weaponSubStatType,
        locationType: currentState.weaponLocationType,
        excludeKeys: currentState.excludeKeys,
        areWeaponTypesEnabled: currentState.areWeaponTypesEnabled,
      ),
      applyFilterChanges: (_) => _buildInitialState(
        search: currentState.search,
        weaponFilterType: currentState.tempWeaponFilterType,
        rarity: currentState.tempRarity,
        sortDirectionType: currentState.tempSortDirectionType,
        weaponTypes: currentState.tempWeaponTypes,
        weaponSubStatType: currentState.tempWeaponSubStatType,
        locationType: currentState.tempWeaponLocationType,
        excludeKeys: currentState.excludeKeys,
        areWeaponTypesEnabled: currentState.areWeaponTypesEnabled,
      ),
      cancelChanges: (_) => currentState.copyWith.call(
        tempWeaponFilterType: currentState.weaponFilterType,
        tempRarity: currentState.rarity,
        tempSortDirectionType: currentState.sortDirectionType,
        tempWeaponTypes: currentState.weaponTypes,
        tempWeaponSubStatType: currentState.weaponSubStatType,
        tempWeaponLocationType: currentState.weaponLocationType,
        excludeKeys: currentState.excludeKeys,
        areWeaponTypesEnabled: currentState.areWeaponTypesEnabled,
      ),
      resetFilters: (_) => _buildInitialState(
        excludeKeys: state.maybeMap(loaded: (state) => state.excludeKeys, orElse: () => []),
        weaponTypes: WeaponType.values,
      ),
    );

    yield s;
  }

  WeaponsState _buildInitialState({
    String? search,
    List<String> excludeKeys = const [],
    List<WeaponType> weaponTypes = const [],
    int rarity = 0,
    WeaponFilterType weaponFilterType = WeaponFilterType.rarity,
    SortDirectionType sortDirectionType = SortDirectionType.asc,
    StatType? weaponSubStatType,
    ItemLocationType? locationType,
    bool areWeaponTypesEnabled = true,
  }) {
    final isLoaded = state is _LoadedState;
    var data = [..._allWeapons];
    if (excludeKeys.isNotEmpty) {
      data = data.where((el) => !excludeKeys.contains(el.key)).toList();
    }

    if (!isLoaded) {
      final selectedWeaponTypes = weaponTypes.isEmpty ? WeaponType.values.toList() : weaponTypes;
      _sortData(data, weaponFilterType, sortDirectionType);
      return WeaponsState.loaded(
        weapons: data,
        search: search,
        weaponTypes: selectedWeaponTypes,
        tempWeaponTypes: selectedWeaponTypes,
        rarity: rarity,
        tempRarity: rarity,
        weaponFilterType: weaponFilterType,
        tempWeaponFilterType: weaponFilterType,
        sortDirectionType: sortDirectionType,
        tempSortDirectionType: sortDirectionType,
        showWeaponDetails: _settingsService.showWeaponDetails,
        weaponSubStatType: weaponSubStatType,
        tempWeaponSubStatType: weaponSubStatType,
        weaponLocationType: locationType,
        tempWeaponLocationType: locationType,
        excludeKeys: excludeKeys,
        areWeaponTypesEnabled: areWeaponTypesEnabled,
      );
    }

    if (search != null && search.isNotEmpty) {
      data = data.where((el) => el.name.toLowerCase().contains(search.toLowerCase())).toList();
    }

    if (rarity > 0) {
      data = data.where((el) => el.rarity == rarity).toList();
    }

    if (weaponTypes.isNotEmpty) {
      data = data.where((el) => weaponTypes.contains(el.type)).toList();
    }

    if (weaponSubStatType != null) {
      data = data.where((el) => el.subStatType == weaponSubStatType).toList();
    }

    if (locationType != null) {
      data = data.where((el) => el.locationType == locationType).toList();
    }

    _sortData(data, weaponFilterType, sortDirectionType);

    final s = currentState.copyWith.call(
      weapons: data,
      search: search,
      weaponTypes: weaponTypes,
      tempWeaponTypes: weaponTypes,
      rarity: rarity,
      tempRarity: rarity,
      weaponFilterType: weaponFilterType,
      tempWeaponFilterType: weaponFilterType,
      sortDirectionType: sortDirectionType,
      tempSortDirectionType: sortDirectionType,
      weaponSubStatType: weaponSubStatType,
      tempWeaponSubStatType: weaponSubStatType,
      weaponLocationType: locationType,
      tempWeaponLocationType: locationType,
      excludeKeys: excludeKeys,
      areWeaponTypesEnabled: areWeaponTypesEnabled,
    );
    return s;
  }

  void _sortData(List<WeaponCardModel> data, WeaponFilterType weaponFilterType, SortDirectionType sortDirectionType) {
    switch (weaponFilterType) {
      case WeaponFilterType.atk:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.baseAtk.compareTo(y.baseAtk));
        } else {
          data.sort((x, y) => y.baseAtk.compareTo(x.baseAtk));
        }
        break;
      case WeaponFilterType.name:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.name.compareTo(y.name));
        } else {
          data.sort((x, y) => y.name.compareTo(x.name));
        }
        break;

      case WeaponFilterType.rarity:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.rarity.compareTo(y.rarity));
        } else {
          data.sort((x, y) => y.rarity.compareTo(x.rarity));
        }
        break;
      case WeaponFilterType.subStat:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.subStatValue.compareTo(y.subStatValue));
        } else {
          data.sort((x, y) => y.subStatValue.compareTo(x.subStatValue));
        }
        break;
      default:
        break;
    }
  }
}
