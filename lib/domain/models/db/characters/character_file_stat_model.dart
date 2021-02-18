import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/enums/enums.dart';

part 'character_file_stat_model.freezed.dart';
part 'character_file_stat_model.g.dart';

@freezed
abstract class CharacterFileStatModel implements _$CharacterFileStatModel {
  factory CharacterFileStatModel({
    @required int level,
    @required double baseHp,
    @required double baseAtk,
    @required double baseDef,
    @required bool isAnAscension,
    @required double specificValue,
  }) = _CharacterFileStatModel;

  const CharacterFileStatModel._();

  factory CharacterFileStatModel.fromJson(Map<String, dynamic> json) => _$CharacterFileStatModelFromJson(json);
}