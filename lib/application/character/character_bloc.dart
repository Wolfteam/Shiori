import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'character_bloc.freezed.dart';
part 'character_event.dart';
part 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final LocaleService _localeService;
  final DataService _dataService;
  final ResourceService _resourceService;

  CharacterBloc(
    this._genshinService,
    this._telemetryService,
    this._localeService,
    this._dataService,
    this._resourceService,
  ) : super(const CharacterState.loading()) {
    on<CharacterEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(CharacterEvent event, Emitter<CharacterState> emit) async {
    switch (event) {
      case CharacterEventLoadFromKey():
        final char = _genshinService.characters.getCharacter(event.key);
        final translation = _genshinService.translations.getCharacterTranslation(event.key);
        await _telemetryService.trackCharacterLoaded(event.key);
        final state = _buildInitialState(char, translation);
        emit(state);
      case CharacterEventAddToInventory():
        await _telemetryService.trackItemAddedToInventory(event.key, 1);
        await _dataService.inventory.addCharacterToInventory(event.key);
        switch (state) {
          case final CharacterStateLoaded state:
            emit(state.copyWith.call(isInInventory: true));
          case CharacterStateLoading():
            break;
        }
      case CharacterEventDeleteFromInventory():
        await _telemetryService.trackItemDeletedFromInventory(event.key);
        await _dataService.inventory.deleteCharacterFromInventory(event.key);
        switch (state) {
          case final CharacterStateLoaded state:
            emit(state.copyWith.call(isInInventory: false));
          case CharacterStateLoading():
            break;
        }
    }
  }

  ItemCommonWithQuantityAndName _mapItemAscensionMaterial(ItemAscensionMaterialFileModel m) {
    final material = _genshinService.materials.getMaterialForCard(m.key);
    return ItemCommonWithQuantityAndName(m.key, material.name, material.image, material.image, m.quantity);
  }

  CharacterAscensionModel _mapToAscensionModel(CharacterFileAscensionMaterialModel e) {
    final materials = e.materials.map((m) => _mapItemAscensionMaterial(m)).toList();
    return CharacterAscensionModel(rank: e.rank, level: e.level, materials: materials);
  }

  CharacterTalentAscensionModel _mapToTalentAscensionModel(CharacterFileTalentAscensionMaterialModel e) {
    final materials = e.materials.map((m) => _mapItemAscensionMaterial(m)).toList();
    return CharacterTalentAscensionModel(level: e.level, materials: materials);
  }

  CharacterState _buildInitialState(CharacterFileModel char, TranslationCharacterFile translation) {
    final ascensionMaterials = char.ascensionMaterials.map((e) => _mapToAscensionModel(e)).toList();

    final talentAscensionMaterials = char.talentAscensionMaterials.map((e) => _mapToTalentAscensionModel(e)).toList();

    final multiTalents = (char.multiTalentAscensionMaterials ?? []).map((e) {
      final materials = e.materials.map((m) => _mapToTalentAscensionModel(m)).toList();
      return CharacterMultiTalentAscensionModel(number: e.number, materials: materials);
    }).toList();

    final birthday = _localeService.formatCharBirthDate(char.birthday);
    final isInInventory = _dataService.inventory.isItemInInventory(char.key, ItemType.character);
    final builds = char.builds.map((build) {
      return CharacterBuildCardModel(
        isRecommended: build.isRecommended,
        type: build.type,
        subType: build.subType,
        skillPriorities: build.skillPriorities,
        subStatsToFocus: build.subStatsToFocus,
        weapons: build.weaponKeys.map((e) => _genshinService.weapons.getWeaponForCard(e)).toList(),
        artifacts: build.artifacts.map(
          (e) {
            final one = e.oneKey != null ? _genshinService.artifacts.getArtifactForCard(e.oneKey!) : null;
            final multiples = e.multiples
                .map(
                  (m) => CharacterBuildMultipleArtifactModel(
                    quantity: m.quantity,
                    artifact: _genshinService.artifacts.getArtifactForCard(m.key),
                  ),
                )
                .toList();

            if (multiples.isNotEmpty) {
              final count = multiples.map((e) => e.quantity).fold(0, (int p, int c) => p + c);
              final diff = artifactOrder.length - count;
              if (diff >= 1) {
                multiples.add(CharacterBuildMultipleArtifactModel(quantity: diff, artifact: multiples.last.artifact));
              }
            }
            return CharacterBuildArtifactModel(one: one, multiples: _flatMultiBuild(multiples), stats: e.stats);
          },
        ).toList(),
      );
    }).toList();

    builds.addAll(_dataService.customBuilds.getCustomBuildsForCharacter(char.key));
    builds.sort((x, y) => x.isRecommended ? -1 : 1);

    return CharacterState.loaded(
      key: char.key,
      name: translation.name,
      region: char.region,
      role: char.role,
      isFemale: char.isFemale,
      fullImage: _resourceService.getCharacterFullImagePath(char.fullImage),
      secondFullImage: char.secondFullImage != null ? _resourceService.getCharacterFullImagePath(char.secondFullImage!) : null,
      description: translation.description,
      rarity: char.rarity,
      birthday: birthday,
      isInInventory: isInInventory,
      elementType: char.elementType,
      weaponType: char.weaponType,
      ascensionMaterials: ascensionMaterials,
      talentAscensionsMaterials: talentAscensionMaterials,
      skills: translation.skills.map((e) {
        final skill = char.skills.firstWhere((s) => s.key == e.key);
        final abilities = e.abilities.map((a) {
          return CharacterSkillAbilityModel(
            name: a.name,
            description: a.description,
            descriptions: a.descriptions,
            secondDescription: a.secondDescription,
          );
        }).toList();
        final stats = _genshinService.characters.getCharacterSkillStats(skill.stats, e.stats);
        return CharacterSkillCardModel(
          image: _resourceService.getSkillImagePath(skill.image),
          stats: stats,
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
          image: _resourceService.getSkillImagePath(passive.image),
          title: e.title,
          description: e.description,
          descriptions: e.descriptions,
        );
      }).toList(),
      constellations: translation.constellations.map((e) {
        final constellation = char.constellations.firstWhere((c) => c.key == e.key);
        return CharacterConstellationModel(
          number: constellation.number,
          image: _resourceService.getSkillImagePath(constellation.image),
          title: e.title,
          description: e.description,
          secondDescription: e.secondDescription,
          descriptions: e.descriptions,
        );
      }).toList(),
      multiTalentAscensionMaterials: multiTalents,
      builds: builds,
      subStatType: char.subStatType,
      stats: char.stats,
    );
  }

  List<ArtifactCardModel> _flatMultiBuild(List<CharacterBuildMultipleArtifactModel> multiArtifactBuild) {
    final multiples = <ArtifactCardModel>[];
    for (var y = 0; y < multiArtifactBuild.length; y++) {
      final multiple = multiArtifactBuild[y];
      for (var x = 1; x <= multiple.quantity; x++) {
        multiples.add(multiple.artifact);
      }
    }
    return multiples;
  }
}
