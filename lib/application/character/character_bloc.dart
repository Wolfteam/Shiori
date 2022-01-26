import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'character_bloc.freezed.dart';
part 'character_event.dart';
part 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
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
  Stream<CharacterState> mapEventToState(CharacterEvent event) async* {
    final s = await event.when(
      loadFromKey: (key) async {
        final char = _genshinService.getCharacter(key);
        final translation = _genshinService.getCharacterTranslation(key);

        await _telemetryService.trackCharacterLoaded(key);
        return _buildInitialState(char, translation);
      },
      addToInventory: (key) async => state.map(
        loading: (state) async => state,
        loaded: (state) async {
          await _telemetryService.trackItemAddedToInventory(key, 1);
          await _dataService.addCharacterToInventory(key);
          return state.copyWith.call(isInInventory: true);
        },
      ),
      deleteFromInventory: (key) async => state.map(
        loading: (state) async => state,
        loaded: (state) async {
          await _telemetryService.trackItemDeletedFromInventory(key);
          await _dataService.deleteCharacterFromInventory(key);
          return state.copyWith.call(isInInventory: false);
        },
      ),
    );

    yield s;
  }

  ItemAscensionMaterialModel _mapToItemAscensionModel(ItemAscensionMaterialFileModel m) {
    final img = _genshinService.getMaterial(m.key).fullImagePath;
    return ItemAscensionMaterialModel(key: m.key, type: m.type, quantity: m.quantity, image: img);
  }

  CharacterAscensionModel _mapToAscensionModel(CharacterFileAscensionMaterialModel e) {
    final materials = e.materials.map((m) => _mapToItemAscensionModel(m)).toList();
    return CharacterAscensionModel(rank: e.rank, level: e.level, materials: materials);
  }

  CharacterTalentAscensionModel _mapToTalentAscensionModel(CharacterFileTalentAscensionMaterialModel e) {
    final materials = e.materials.map((m) => _mapToItemAscensionModel(m)).toList();
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
    final isInInventory = _dataService.isItemInInventory(char.key, ItemType.character);

    return CharacterState.loaded(
      key: char.key,
      name: translation.name,
      region: char.region,
      role: char.role,
      isFemale: char.isFemale,
      fullImage: Assets.getCharacterFullPath(char.fullImage),
      secondFullImage: char.secondFullImage != null ? Assets.getCharacterFullPath(char.secondFullImage!) : null,
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
        final stats = _genshinService.getCharacterSkillStats(skill.stats, e.stats);
        return CharacterSkillCardModel(
          image: skill.fullImagePath,
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
      multiTalentAscensionMaterials: multiTalents,
      builds: char.builds.map((build) {
        return CharacterBuildCardModel(
          isRecommended: build.isRecommended,
          type: build.type,
          subType: build.subType,
          skillPriorities: build.skillPriorities,
          subStatsToFocus: build.subStatsToFocus,
          weapons: build.weaponKeys.map((e) => _genshinService.getWeaponForCard(e)).toList(),
          artifacts: build.artifacts.map(
            (e) {
              final one = e.oneKey != null ? _genshinService.getArtifactForCard(e.oneKey!) : null;
              final multiples = e.multiples
                  .map(
                    (m) => CharacterBuildMultipleArtifactModel(
                      quantity: m.quantity,
                      artifact: _genshinService.getArtifactForCard(m.key),
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
      }).toList()
        ..sort((x, y) => x.isRecommended ? -1 : 1),
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
