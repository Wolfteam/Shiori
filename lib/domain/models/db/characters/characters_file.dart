import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'character_file_model.dart';

part 'characters_file.freezed.dart';
part 'characters_file.g.dart';

@freezed
class CharactersFile with _$CharactersFile {
  factory CharactersFile({
    required List<CharacterFileModel> characters,
  }) = _CharactersFile;

  factory CharactersFile.fromJson(Map<String, dynamic> json) => _$CharactersFileFromJson(json);
}
