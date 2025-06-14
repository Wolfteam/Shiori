import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/utils/filter_utils.dart';

part 'weapons_bloc.freezed.dart';
part 'weapons_event.dart';
part 'weapons_state.dart';

class WeaponsBloc extends Bloc<WeaponsEvent, WeaponsState> {
  final GenshinService _genshinService;
  final SettingsService _settingsService;
  final List<WeaponCardModel> _allWeapons = [];

  WeaponsBloc(this._genshinService, this._settingsService) : super(const WeaponsState.loading());

  WeaponsStateLoaded get currentState => state as WeaponsStateLoaded;

  @override
  Stream<WeaponsState> mapEventToState(WeaponsEvent event) async* {
    switch (event) {
      case WeaponsEventInit():
        if (_allWeapons.isEmpty || event.force) {
          _allWeapons.clear();
          _allWeapons.addAll(_genshinService.weapons.getWeaponsForCard());
        }

        yield _buildInitialState(
          excludeKeys: event.excludeKeys,
          weaponTypes: event.weaponTypes.isEmpty ? WeaponType.values : event.weaponTypes,
          areWeaponTypesEnabled: event.areWeaponTypesEnabled,
        );
      case WeaponsEventSearchChanged():
        yield _buildInitialState(
          search: event.search,
          weaponFilterType: currentState.weaponFilterType,
          rarity: currentState.rarity,
          sortDirectionType: currentState.sortDirectionType,
          weaponTypes: currentState.weaponTypes,
          weaponSubStatType: currentState.weaponSubStatType,
          locationType: currentState.weaponLocationType,
          excludeKeys: currentState.excludeKeys,
          areWeaponTypesEnabled: currentState.areWeaponTypesEnabled,
        );
      case WeaponsEventWeaponTypesChanged():
        yield _weaponTypeChanged(event.weaponType);
      case WeaponsEventRarityChanged():
        yield currentState.copyWith.call(tempRarity: event.rarity);
      case WeaponsEventWeaponFilterChanged():
        yield currentState.copyWith.call(tempWeaponFilterType: event.filterType);
      case WeaponsEventApplyFilterChanges():
        yield _buildInitialState(
          search: currentState.search,
          weaponFilterType: currentState.tempWeaponFilterType,
          rarity: currentState.tempRarity,
          sortDirectionType: currentState.tempSortDirectionType,
          weaponTypes: currentState.tempWeaponTypes,
          weaponSubStatType: currentState.tempWeaponSubStatType,
          locationType: currentState.tempWeaponLocationType,
          excludeKeys: currentState.excludeKeys,
          areWeaponTypesEnabled: currentState.areWeaponTypesEnabled,
        );
      case WeaponsEventSortDirectionTypeChanged():
        yield currentState.copyWith.call(tempSortDirectionType: event.sortDirectionType);
      case WeaponsEventWeaponSubStatTypeChanged():
        yield currentState.copyWith.call(tempWeaponSubStatType: event.subStatType);
      case WeaponsEventWeaponLocationTypeChanged():
        yield currentState.copyWith.call(tempWeaponLocationType: event.locationType);
      case WeaponsEventCancelChanges():
        yield currentState.copyWith.call(
          tempWeaponFilterType: currentState.weaponFilterType,
          tempRarity: currentState.rarity,
          tempSortDirectionType: currentState.sortDirectionType,
          tempWeaponTypes: currentState.weaponTypes,
          tempWeaponSubStatType: currentState.weaponSubStatType,
          tempWeaponLocationType: currentState.weaponLocationType,
          excludeKeys: currentState.excludeKeys,
          areWeaponTypesEnabled: currentState.areWeaponTypesEnabled,
        );
      case WeaponsEventResetFilters():
        final excludedKeys = switch (state) {
          WeaponsStateLoading() => <String>[],
          final WeaponsStateLoaded state => state.excludeKeys,
        };
        yield _buildInitialState(excludeKeys: excludedKeys, weaponTypes: WeaponType.values);
    }
  }

  WeaponsState _weaponTypeChanged(WeaponType selectedValue) {
    final List<WeaponType> types = FilterUtils.handleTypeSelected(WeaponType.values, currentState.tempWeaponTypes, selectedValue);
    return currentState.copyWith.call(tempWeaponTypes: types);
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
    final isLoaded = state is WeaponsStateLoaded;
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
      case WeaponFilterType.name:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.name.compareTo(y.name));
        } else {
          data.sort((x, y) => y.name.compareTo(x.name));
        }

      case WeaponFilterType.rarity:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.rarity.compareTo(y.rarity));
        } else {
          data.sort((x, y) => y.rarity.compareTo(x.rarity));
        }
      case WeaponFilterType.subStat:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.subStatValue.compareTo(y.subStatValue));
        } else {
          data.sort((x, y) => y.subStatValue.compareTo(x.subStatValue));
        }
    }
  }
}
