import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';

part 'characters_file.freezed.dart';
part 'characters_file.g.dart';

@freezed
abstract class CharactersFile with _$CharactersFile {
  factory CharactersFile({
    required List<CharacterFileModel> characters,
  }) = _CharactersFile;

  factory CharactersFile.fromJson(Map<String, dynamic> json) => _$CharactersFileFromJson(json);
}
