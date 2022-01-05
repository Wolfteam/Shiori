import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'custom_build_bloc.freezed.dart';
part 'custom_build_event.dart';
part 'custom_build_state.dart';

class CustomBuildBloc extends Bloc<CustomBuildEvent, CustomBuildState> {
  final GenshinService _genshinService;
  final DataService _dataService;

  CustomBuildBloc(this._genshinService, this._dataService) : super(const CustomBuildState.loading()) {
    on<CustomBuildEvent>(_handleEvent);
  }

  Future<void> _handleEvent(CustomBuildEvent event, Emitter<CustomBuildState> emit) async {
    final s = await event.map(
      load: (e) async => _init(e.key),
      characterChanged: (e) async => state.maybeMap(
        loaded: (state) {
          final newCharacter = _genshinService.getCharacterForCard(e.newKey);
          return state.copyWith.call(character: newCharacter);
        },
        orElse: () => state,
      ),
      titleChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(title: e.newValue),
        orElse: () => state,
      ),
      roleChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(type: e.newValue),
        orElse: () => state,
      ),
      subRoleChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(subType: e.newValue),
        orElse: () => state,
      ),
      showOnCharacterDetailChanged: (e) async => state.maybeMap(
        loaded: (state) => state.copyWith.call(showOnCharacterDetail: e.newValue),
        orElse: () => state,
      ),
      addWeapon: (e) async => state.maybeMap(
        loaded: (state) {
          //TODO: CHECK FOR REPEATED
          if (state.weapons.any((el) => el.key == e.key)) {
            throw Exception('Weapons cannot be repeated');
          }
          final weapon = _genshinService.getWeaponForCard(e.key);
          final weapons = [...state.weapons, weapon];
          return state.copyWith.call(weapons: weapons);
        },
        orElse: () => state,
      ),
      deleteWeapon: (e) async => state,
      weaponOrderChanged: (e) async => state,
      addArtifact: (e) async => state.maybeMap(
        loaded: (state) {
          //TODO: CHECK FOR REPEATED
          if (state.artifacts.any((el) => el.key == e.key && el.type == e.type)) {
            throw Exception('Artifact types cannot be repeated');
          }
          final fullArtifact = _genshinService.getArtifact(e.key);
          final translation = _genshinService.getArtifactTranslation(e.key);
          final img = _genshinService.getArtifactRelatedPart(fullArtifact.fullImagePath, fullArtifact.image, translation.bonus.length, e.type);
          final artifacts = [
            ...state.artifacts,
            CustomBuildArtifactModel(type: e.type, image: img, key: e.key, rarity: fullArtifact.maxRarity, statType: e.statType),
          ]..sort((x, y) => x.type.index.compareTo(y.type.index));
          return state.copyWith.call(artifacts: artifacts);
        },
        orElse: () => state,
      ),
      saveChanges: (e) async => state.maybeMap(
        loaded: (state) => _saveChanges(state),
        orElse: () async => state,
      ),
      reset: (e) async => state,
    );

    emit(s);
  }

  CustomBuildState _init(int? key) {
    if (key != null) {
      final build = _dataService.customBuilds.getCustomBuild(key);
      return CustomBuildState.loaded(
        key: key,
        title: build.title,
        type: build.type,
        subType: build.subType,
        showOnCharacterDetail: build.showOnCharacterDetail,
        character: build.character,
        weapons: build.weapons,
        artifacts: build.artifacts..sort((x, y) => x.type.index.compareTo(y.type.index)),
      );
    }

    final character = _genshinService.getCharactersForCard().first;
    return CustomBuildState.loaded(
      title: '',
      type: CharacterRoleType.dps,
      subType: CharacterRoleSubType.none,
      showOnCharacterDetail: true,
      character: character,
      weapons: [],
      artifacts: []..sort((x, y) => x.type.index.compareTo(y.type.index)),
    );
  }

  Future<CustomBuildState> _saveChanges(_LoadedState state) async {
    if (state.key != null) {
      await _dataService.customBuilds.updateCustomBuild(
        state.key!,
        state.title,
        state.type,
        state.subType,
        state.showOnCharacterDetail,
        state.weapons.map((e) => e.key).toList(),
        [],
        [],
      );

      return _init(state.key);
    }
    final build = await _dataService.customBuilds.saveCustomBuild(
      state.character.key,
      state.title,
      state.type,
      state.subType,
      state.showOnCharacterDetail,
      state.weapons.map((e) => e.key).toList(),
      //TODO: THIS
      [],
      [],
    );

    return _init(build.key);
  }
}
