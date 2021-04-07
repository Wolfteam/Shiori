import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/enums/enums.dart';

part 'monster_file_model.freezed.dart';
part 'monster_file_model.g.dart';

@freezed
abstract class MonsterFileModel implements _$MonsterFileModel {
  @late
  String get fullImagePath => Assets.getMonsterImgPath(image);

  factory MonsterFileModel({
    @required String key,
    @required String image,
    @required MonsterType type,
    @required bool isComingSoon,
    @required List<String> drops,
  }) = _MonsterFileModel;

  MonsterFileModel._();

  factory MonsterFileModel.fromJson(Map<String, dynamic> json) => _$MonsterFileModelFromJson(json);
}
