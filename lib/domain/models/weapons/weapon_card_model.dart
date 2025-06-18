import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'weapon_card_model.freezed.dart';

@freezed
abstract class WeaponCardModel with _$WeaponCardModel {
  const factory WeaponCardModel({
    required String key,
    required String image,
    required String name,
    required int rarity,
    required double baseAtk,
    required WeaponType type,
    required StatType subStatType,
    required double subStatValue,
    required bool isComingSoon,
    required ItemLocationType locationType,
  }) = _WeaponCardModel;
}
