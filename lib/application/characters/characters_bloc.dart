import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/utils/filter_utils.dart';

part 'characters_bloc.freezed.dart';
part 'characters_event.dart';
part 'characters_state.dart';

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  final GenshinService _genshinService;
  final SettingsService _settingsService;
  final List<CharacterCardModel> _allCharacters = [];

  CharactersBloc(this._genshinService, this._settingsService) : super(const CharactersState.loading()) {
    on<CharactersEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  CharactersStateLoaded get currentState => state as CharactersStateLoaded;

  Future<void> _mapEventToState(CharactersEvent event, Emitter<CharactersState> emit) async {
    switch (event) {
      case CharactersEventInit():
        if (_allCharacters.isEmpty || event.force) {
          _allCharacters.clear();
          _allCharacters.addAll(_genshinService.characters.getCharactersForCard());
        }

        emit(
          _buildInitialState(
            excludeKeys: event.excludeKeys,
            elementTypes: ElementType.values,
            weaponTypes: WeaponType.values,
          ),
        );
      case CharactersEventSearchChanged():
        emit(
          _buildInitialState(
            search: event.search,
            characterFilterType: currentState.characterFilterType,
            elementTypes: currentState.elementTypes,
            rarity: currentState.rarity,
            statusType: currentState.statusType,
            sortDirectionType: currentState.sortDirectionType,
            weaponTypes: currentState.weaponTypes,
            roleType: currentState.tempRoleType,
            excludeKeys: currentState.excludeKeys,
          ),
        );
      case CharactersEventWeaponTypeChanged():
        emit(_weaponTypeChanged(event.weaponType));
      case CharactersEventElementTypeChanged():
        emit(_elementTypeChanged(event.elementType));
      case CharactersEventRarityChanged():
        emit(currentState.copyWith.call(tempRarity: event.rarity));
      case CharactersEventItemStatusTypeChanged():
        emit(currentState.copyWith.call(tempStatusType: event.statusType));
      case CharactersEventCharacterFilterTypeChanged():
        emit(currentState.copyWith.call(tempCharacterFilterType: event.characterFilterType));
      case CharactersEventSortDirectionTypeChanged():
        emit(currentState.copyWith.call(tempSortDirectionType: event.sortDirectionType));
      case CharactersEventCharacterRoleTypeChanged():
        emit(currentState.copyWith.call(tempRoleType: event.roleType));
      case CharactersEventRegionTypeChanged():
        emit(currentState.copyWith.call(tempRegionType: event.regionType));
      case CharactersEventApplyFilterChanges():
        emit(
          _buildInitialState(
            search: currentState.search,
            characterFilterType: currentState.tempCharacterFilterType,
            elementTypes: currentState.tempElementTypes,
            rarity: currentState.tempRarity,
            statusType: currentState.tempStatusType,
            sortDirectionType: currentState.tempSortDirectionType,
            weaponTypes: currentState.tempWeaponTypes,
            roleType: currentState.tempRoleType,
            excludeKeys: currentState.excludeKeys,
            regionType: currentState.tempRegionType,
          ),
        );
      case CharactersEventCancelChanges():
        emit(
          currentState.copyWith.call(
            tempCharacterFilterType: currentState.characterFilterType,
            tempElementTypes: currentState.elementTypes,
            tempRarity: currentState.rarity,
            tempStatusType: currentState.statusType,
            tempSortDirectionType: currentState.sortDirectionType,
            tempWeaponTypes: currentState.weaponTypes,
            tempRoleType: currentState.roleType,
            excludeKeys: currentState.excludeKeys,
            tempRegionType: currentState.regionType,
          ),
        );
      case CharactersEventResetFilters():
        final excludedKeys = switch (state) {
          CharactersStateLoading() => <String>[],
          final CharactersStateLoaded state => state.excludeKeys,
        };
        emit(_buildInitialState(excludeKeys: excludedKeys, elementTypes: ElementType.values, weaponTypes: WeaponType.values));
    }
  }

  CharactersState _elementTypeChanged(ElementType selectedValue) {
    final List<ElementType> types = FilterUtils.handleTypeSelected(
      ElementType.values,
      currentState.tempElementTypes,
      selectedValue,
    );
    return currentState.copyWith.call(tempElementTypes: types);
  }

  CharactersState _weaponTypeChanged(WeaponType selectedValue) {
    final List<WeaponType> types = FilterUtils.handleTypeSelected(WeaponType.values, currentState.tempWeaponTypes, selectedValue);
    return currentState.copyWith.call(tempWeaponTypes: types);
  }

  CharactersState _buildInitialState({
    String? search,
    List<String> excludeKeys = const [],
    List<WeaponType> weaponTypes = const [],
    List<ElementType> elementTypes = const [],
    int rarity = 0,
    ItemStatusType? statusType,
    CharacterFilterType characterFilterType = CharacterFilterType.name,
    SortDirectionType sortDirectionType = SortDirectionType.asc,
    CharacterRoleType? roleType,
    RegionType? regionType,
  }) {
    final isLoaded = state is CharactersStateLoaded;
    var characters = [..._allCharacters];
    if (excludeKeys.isNotEmpty) {
      characters = characters.where((el) => !excludeKeys.contains(el.key)).toList();
    }

    if (!isLoaded) {
      final selectedWeaponTypes = WeaponType.values.toList();
      final selectedElementTypes = ElementType.values.toList();
      _sortData(characters, characterFilterType, sortDirectionType);
      return CharactersState.loaded(
        characters: characters,
        search: search,
        weaponTypes: selectedWeaponTypes,
        tempWeaponTypes: selectedWeaponTypes,
        elementTypes: selectedElementTypes,
        tempElementTypes: selectedElementTypes,
        rarity: rarity,
        tempRarity: rarity,
        statusType: statusType,
        tempStatusType: statusType,
        characterFilterType: characterFilterType,
        tempCharacterFilterType: characterFilterType,
        sortDirectionType: sortDirectionType,
        tempSortDirectionType: sortDirectionType,
        showCharacterDetails: _settingsService.showCharacterDetails,
        roleType: roleType,
        tempRoleType: roleType,
        excludeKeys: excludeKeys,
        regionType: regionType,
        tempRegionType: regionType,
      );
    }

    if (search != null && search.isNotEmpty) {
      characters = characters.where((el) => el.name.toLowerCase().contains(search.toLowerCase())).toList();
    }

    if (rarity > 0) {
      characters = characters.where((el) => el.stars == rarity).toList();
    }

    if (weaponTypes.isNotEmpty) {
      characters = characters.where((el) => weaponTypes.contains(el.weaponType)).toList();
    }

    if (elementTypes.isNotEmpty) {
      characters = characters.where((el) => elementTypes.contains(el.elementType)).toList();
    }

    if (roleType != null) {
      characters = characters.where((el) => el.roleType == roleType).toList();
    }

    if (regionType != null) {
      characters = characters.where((el) => el.regionType == regionType).toList();
    }

    switch (statusType) {
      case ItemStatusType.released:
        characters = characters.where((el) => !el.isComingSoon).toList();
      case ItemStatusType.comingSoon:
        characters = characters.where((el) => el.isComingSoon).toList();
      case ItemStatusType.newItem:
        characters = characters.where((el) => el.isNew).toList();
      default:
        break;
    }

    _sortData(characters, characterFilterType, sortDirectionType);

    final s = currentState.copyWith.call(
      characters: characters,
      search: search,
      weaponTypes: weaponTypes,
      tempWeaponTypes: weaponTypes,
      elementTypes: elementTypes,
      tempElementTypes: elementTypes,
      rarity: rarity,
      tempRarity: rarity,
      statusType: statusType,
      tempStatusType: statusType,
      characterFilterType: characterFilterType,
      tempCharacterFilterType: characterFilterType,
      sortDirectionType: sortDirectionType,
      tempSortDirectionType: sortDirectionType,
      excludeKeys: excludeKeys,
      roleType: roleType,
      tempRoleType: roleType,
      regionType: regionType,
      tempRegionType: regionType,
    );
    return s;
  }

  void _sortData(List<CharacterCardModel> data, CharacterFilterType characterFilterType, SortDirectionType sortDirectionType) {
    switch (characterFilterType) {
      case CharacterFilterType.name:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.name.compareTo(y.name));
        } else {
          data.sort((x, y) => y.name.compareTo(x.name));
        }
      case CharacterFilterType.rarity:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.stars.compareTo(y.stars));
        } else {
          data.sort((x, y) => y.stars.compareTo(x.stars));
        }
    }
  }
}
