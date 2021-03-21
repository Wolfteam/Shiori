import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/application/common/pop_bloc.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/data_service.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/locale_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';

part 'character_bloc.freezed.dart';
part 'character_event.dart';
part 'character_state.dart';

class CharacterBloc extends PopBloc<CharacterEvent, CharacterState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final LocaleService _localeService;
  final DataService _dataService;

  CharacterBloc(
    this._genshinService,
    this._telemetryService,
    this._localeService,
    this._dataService,
  ) : super(const CharacterState.loading());

  @override
  CharacterEvent getEventForPop(String key) => CharacterEvent.loadFromName(key: key, addToQueue: false);

  @override
  Stream<CharacterState> mapEventToState(
    CharacterEvent event,
  ) async* {
    if (event is! _AddedToInventory) {
      yield const CharacterState.loading();
    }

    final s = await event.when(
      loadFromName: (key, addToQueue) async {
        final char = _genshinService.getCharacter(key);
        final translation = _genshinService.getCharacterTranslation(key);

        if (addToQueue) {
          await _telemetryService.trackCharacterLoaded(key);
          currentItemsInStack.add(char.key);
        }
        return _buildInitialState(char, translation);
      },
      loadFromImg: (img, addToQueue) async {
        final char = _genshinService.getCharacterByImg(img);
        final translation = _genshinService.getCharacterTranslation(char.key);

        if (addToQueue) {
          await _telemetryService.trackCharacterLoaded(img, loadedFromName: false);
          currentItemsInStack.add(char.key);
        }

        return _buildInitialState(char, translation);
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

  CharacterState _buildInitialState(CharacterFileModel char, TranslationCharacterFile translation) {
    return CharacterState.loaded(
      key: char.key,
      name: translation.name,
      region: char.region,
      role: char.role,
      isFemale: char.isFemale,
      fullImage: Assets.getCharacterFullPath(char.fullImage),
      secondFullImage: char.secondFullImage != null ? Assets.getCharacterFullPath(char.secondFullImage) : null,
      description: translation.description,
      rarity: char.rarity,
      birthday: _localeService.formatCharBirthDate(char.birthday),
      isInInventory: _dataService.isItemInInventory(char.key, ItemType.character),
      elementType: char.elementType,
      weaponType: char.weaponType,
      ascensionMaterials: char.ascensionMaterials,
      talentAscensionsMaterials: char.talentAscensionMaterials,
      skills: translation.skills.map((e) {
        final skill = char.skills.firstWhere((s) => s.key == e.key);
        final abilities = e.abilities.map((a) {
          final type =
              skill.abilities != null && skill.abilities.any((x) => x.key == a.key) ? skill.abilities.firstWhere((x) => x.key == a.key).type : null;
          return CharacterSkillAbilityModel(
            type: type,
            name: a.name,
            description: a.description,
            descriptions: a.descriptions,
            secondDescription: a.secondDescription,
          );
        }).toList();
        return CharacterSkillCardModel(
          image: skill.fullImagePath,
          title: e.title,
          type: skill.type,
          abilities: abilities,
          description: e.description,
        );
      }).toList(),
      passives: translation.passives.map((e) {
        final passive = char.passives.firstWhere((p) => p.key == e.key);
        return CharacterPassiveTalentModel(
          unlockedAt: passive.unlockedAt,
          image: passive.fullImagePath,
          title: e.title,
          description: e.description,
          descriptions: e.descriptions,
        );
      }).toList(),
      constellations: translation.constellations.map((e) {
        final constellation = char.constellations.firstWhere((c) => c.key == e.key);
        return CharacterConstellationModel(
          number: constellation.number,
          image: constellation.fullImagePath,
          title: e.title,
          description: e.description,
          secondDescription: e.secondDescription,
          descriptions: e.descriptions,
        );
      }).toList(),
      multiTalentAscensionMaterials: char.multiTalentAscensionMaterials,
      builds: char.builds.map((build) {
        return CharacterBuildCardModel(
          isForSupport: build.isSupport,
          subStatsToFocus: build.subStatsToFocus,
          weapons: build.weaponImages.map((e) => _genshinService.getWeaponForCardByImg(e)).toList(),
          artifacts: build.artifacts.map(
            (e) {
              final one = e.one != null ? _genshinService.getArtifactForCardByImg(e.one) : null;
              final multiples = e.multiples
                  .map((m) => CharacterBuildMultipleArtifactModel(
                        quantity: m.quantity,
                        artifact: _genshinService.getArtifactForCardByImg(m.image),
                      ))
                  .toList();

              return CharacterBuildArtifactModel(one: one, multiples: multiples, stats: e.stats);
            },
          ).toList(),
        );
      }).toList(),
      subStatType: char.subStatType,
      stats: char.stats,
    );
  }
}
