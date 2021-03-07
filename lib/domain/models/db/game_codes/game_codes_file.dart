import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models.dart';

part 'game_codes_file.freezed.dart';
part 'game_codes_file.g.dart';

@freezed
abstract class GameCodesFile implements _$GameCodesFile {
  factory GameCodesFile({
    @required List<GameCodeFileModel> gameCodes,
  }) = _GameCodesFile;

  GameCodesFile._();

  factory GameCodesFile.fromJson(Map<String, dynamic> json) => _$GameCodesFileFromJson(json);
}

@freezed
abstract class GameCodeFileModel implements _$GameCodeFileModel {
  factory GameCodeFileModel({
    String dateAdded,
    @required bool isExpired,
    @required String code,
    @required List<ItemAscensionMaterialModel> rewards,
  }) = _GameCodeFileModel;

  GameCodeFileModel._();

  factory GameCodeFileModel.fromJson(Map<String, dynamic> json) => _$GameCodeFileModelFromJson(json);
}
