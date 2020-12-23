import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums/character_filter_type.dart';
import '../../common/enums/element_type.dart';
import '../../common/enums/item_status_type.dart';
import '../../common/enums/sort_direction_type.dart';
import '../../common/enums/weapon_type.dart';
import '../../models/models.dart';
import '../../services/genshing_service.dart';
import '../../services/settings_service.dart';

part 'characters_bloc.freezed.dart';
part 'characters_event.dart';
part 'characters_state.dart';

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  final GenshinService _genshinService;
  final SettingsService _settingsService;

  CharactersBloc(this._genshinService, this._settingsService) : super(const CharactersState.loading());

  _LoadedState get currentState => state as _LoadedState;

  @override
  Stream<CharactersState> mapEventToState(
    CharactersEvent event,
  ) async* {
    final s = event.map(
      init: (_) => _buildInitialState(),
      characterFilterTypeChanged: (e) => currentState.copyWith.call(tempCharacterFilterType: e.characterFilterType),
      elementTypeChanged: (e) {
        var types = <ElementType>[];
        if (currentState.tempElementTypes.contains(e.elementType)) {
          types = currentState.tempElementTypes.where((t) => t != e.elementType).toList();
        } else {
          types = currentState.tempElementTypes + [e.elementType];
        }
        return currentState.copyWith.call(tempElementTypes: types);
      },
      rarityChanged: (e) => currentState.copyWith.call(tempRarity: e.rarity),
      itemStatusChanged: (e) => currentState.copyWith.call(
        tempStatusType: e.statusType,
      ),
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
      searchChanged: (e) => _buildInitialState(
        search: e.search,
        characterFilterType: currentState.characterFilterType,
        elementTypes: currentState.elementTypes,
        rarity: currentState.rarity,
        statusType: currentState.statusType,
        sortDirectionType: currentState.sortDirectionType,
        weaponTypes: currentState.weaponTypes,
      ),
      applyFilterChanges: (_) => _buildInitialState(
        search: currentState.search,
        characterFilterType: currentState.tempCharacterFilterType,
        elementTypes: currentState.tempElementTypes,
        rarity: currentState.tempRarity,
        statusType: currentState.tempStatusType,
        sortDirectionType: currentState.tempSortDirectionType,
        weaponTypes: currentState.tempWeaponTypes,
      ),
      cancelChanges: (_) => currentState.copyWith.call(
        tempCharacterFilterType: currentState.characterFilterType,
        tempElementTypes: currentState.elementTypes,
        tempRarity: currentState.rarity,
        tempStatusType: currentState.statusType,
        tempSortDirectionType: currentState.sortDirectionType,
        tempWeaponTypes: currentState.weaponTypes,
      ),
    );
    yield s;
  }

//TODO: FALTA UN DELAY EN EL SEARCH
  CharactersState _buildInitialState({
    String search,
    List<WeaponType> weaponTypes = const [],
    List<ElementType> elementTypes = const [],
    int rarity = 0,
    ItemStatusType statusType = ItemStatusType.all,
    CharacterFilterType characterFilterType = CharacterFilterType.name,
    SortDirectionType sortDirectionType = SortDirectionType.asc,
  }) {
    final isLoaded = state is _LoadedState;
    var characters = _genshinService.getCharactersForCard();

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

    switch (statusType) {
      case ItemStatusType.released:
        characters = characters.where((el) => !el.isComingSoon).toList();
        break;
      case ItemStatusType.comingSoon:
        characters = characters.where((el) => el.isComingSoon).toList();
        break;
      case ItemStatusType.newItem:
        characters = characters.where((el) => el.isNew).toList();
        break;
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
    );
    return s;
  }

  void _sortData(
    List<CharacterCardModel> data,
    CharacterFilterType characterFilterType,
    SortDirectionType sortDirectionType,
  ) {
    switch (characterFilterType) {
      case CharacterFilterType.name:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.name.compareTo(y.name));
        } else {
          data.sort((x, y) => y.name.compareTo(x.name));
        }
        break;
      case CharacterFilterType.rarity:
        if (sortDirectionType == SortDirectionType.asc) {
          data.sort((x, y) => x.stars.compareTo(y.stars));
        } else {
          data.sort((x, y) => y.stars.compareTo(x.stars));
        }
        break;
      default:
        break;
    }
  }
}
