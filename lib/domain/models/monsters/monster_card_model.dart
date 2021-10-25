import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'monster_card_model.freezed.dart';

@freezed
class MonsterCardModel with _$MonsterCardModel {
  const factory MonsterCardModel({
    required String key,
    required String image,
    required String name,
    required MonsterType type,
    required bool isComingSoon,
  }) = _MonsterCardModel;
}
