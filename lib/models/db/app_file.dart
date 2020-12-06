import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'character_file_model.dart';

part 'app_file.freezed.dart';
part 'app_file.g.dart';

@freezed
abstract class AppFile implements _$AppFile {
  factory AppFile({
    @required List<CharacterFileModel> characters,
  }) = _AppFile;

  factory AppFile.fromJson(Map<String, dynamic> json) => _$AppFileFromJson(json);
}
