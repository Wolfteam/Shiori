import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/assets.dart';
import '../../common/enums/character_type.dart';
import '../../common/enums/element_type.dart';
import '../../common/enums/weapon_type.dart';
import '../../models/models.dart';
import '../../services/genshing_service.dart';
import '../../telemetry.dart';

part 'character_bloc.freezed.dart';
part 'character_event.dart';
part 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final GenshinService _genshinService;
  CharacterBloc(this._genshinService) : super(const CharacterState.loading());

  @override
  Stream<CharacterState> mapEventToState(
    CharacterEvent event,
  ) async* {
    yield const CharacterState.loading();

    final s = await event.when(
      loadFromName: (name) async {
        await trackCharacterLoaded(name);
        final char = _genshinService.getCharacter(name);
        final translation = _genshinService.getCharacterTranslation(name);
        return _buildInitialState(char, translation);
      },
      loadFromImg: (img) async {
        await trackCharacterLoaded(img, loadedFromName: false);
        final char = _genshinService.getCharacterByImg(img);
        final translation = _genshinService.getCharacterTranslation(char.name);
        return _buildInitialState(char, translation);
      },
    );

    yield s;
  }

  CharacterState _buildInitialState(CharacterFileModel char, TranslationCharacterFile translations) {
    return CharacterState.loaded(
      name: char.name,
      region: char.region,
      role: char.role,
      isFemale: char.isFemale,
      fullImage: Assets.getCharacterFullPath(char.fullImage),
      secondFullImage: char.secondFullImage != null ? Assets.getCharacterFullPath(char.secondFullImage) : null,
      description: translations.description,
      rarity: char.rarity,
      elementType: char.elementType,
      weaponType: char.weaponType,
      ascentionMaterials: char.ascentionMaterials,
      talentAscentionsMaterials: char.talentAscentionMaterials,
      skills: translations.skills.map((e) {
        final abilities = e.abilities
            .map((a) => CharacterSkillAbilityModel(
                  name: a.name,
                  description: a.description,
                  descriptions: a.descriptions,
                  secondDescription: a.secondDescription,
                ))
            .toList();
        final skill = char.skills.firstWhere((s) => s.key == e.key);
        return CharacterSkillCardModel(
          image: skill.fullImagePath,
          title: e.title,
          type: skill.type,
          abilities: abilities,
          description: e.description,
        );
      }).toList(),
      passives: translations.passives.map((e) {
        final passive = char.passives.firstWhere((p) => p.key == e.key);
        return CharacterPassiveTalentModel(
          unlockedAt: passive.unlockedAt,
          image: passive.fullImagePath,
          title: e.title,
          description: e.description,
          descriptions: e.descriptions,
        );
      }).toList(),
      constellations: translations.constellations.map((e) {
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
      multiTalentAscentionMaterials: char.multiTalentAscentionMaterials,
      builds: char.builds.map((build) {
        return CharacterBuildCardModel(
          isForSupport: build.isSupport,
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

              return CharacterBuildArtifactModel(one: one, multiples: multiples);
            },
          ).toList(),
        );
      }).toList(),
    );
  }
}
