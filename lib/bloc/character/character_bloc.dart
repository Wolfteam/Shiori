import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/assets.dart';
import '../../common/enums/element_type.dart';
import '../../common/enums/weapon_type.dart';
import '../../models/models.dart';
import '../../services/genshing_service.dart';

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

    final s = event.when(
      loadFromName: (name) {
        final char = _genshinService.getCharacter(name);
        final translation = _genshinService.getCharacterTranslation(name);
        return _buildInitialState(char, translation);
      },
      loadFromImg: (img) {
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
      role: translations.role,
      isFemale: char.isFemale,
      fullImage: Assets.getCharacterFullPath(char.fullImage),
      secondFullImage: char.secondFullImage != null ? Assets.getCharacterFullPath(char.secondFullImage) : null,
      description: translations.description,
      rarity: char.rarity,
      elementType: char.elementType,
      weaponType: char.weaponType,
      ascentionMaterials: char.ascentionMaterials,
      talentAscentionsMaterials: char.talentAscentionMaterials,
      skills: translations.skills,
      passives: translations.passives,
      constellations: translations.constellations,
      multiTalentAscentionMaterials: char.multiTalentAscentionMaterials,
    );
  }
}
