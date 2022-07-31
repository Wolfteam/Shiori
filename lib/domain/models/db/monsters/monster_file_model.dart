import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'monster_file_model.freezed.dart';
part 'monster_file_model.g.dart';

@freezed
class MonsterFileModel with _$MonsterFileModel {
  factory MonsterFileModel({
    required String key,
    required String image,
    required MonsterType type,
    required bool isComingSoon,
    required List<MonsterDropFileModel> drops,
  }) = _MonsterFileModel;

  MonsterFileModel._();

  factory MonsterFileModel.fromJson(Map<String, dynamic> json) => _$MonsterFileModelFromJson(json);
}

@freezed
class MonsterDropFileModel with _$MonsterDropFileModel {
  factory MonsterDropFileModel({
    required String key,
    required MonsterDropType type,
  }) = _MonsterDropFileModel;

  MonsterDropFileModel._();

  factory MonsterDropFileModel.fromJson(Map<String, dynamic> json) => _$MonsterDropFileModelFromJson(json);
}
