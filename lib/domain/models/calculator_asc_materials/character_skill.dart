import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'character_skill.freezed.dart';

@freezed
abstract class CharacterSkill with _$CharacterSkill {
  const factory CharacterSkill.skill({
    @required String name,
    @required int currentLevel,
    @required int desiredLevel,
  }) = _CharacterSkill;
}
