import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'character_card_model.freezed.dart';

@freezed
class CharacterCardModel with _$CharacterCardModel {
  const factory CharacterCardModel({
    required String key,
    required String image,
    required String name,
    required int stars,
    required WeaponType weaponType,
    required ElementType elementType,
    @Default(false) bool isNew,
    @Default(false) bool isComingSoon,
    required List<String> materials,
    required CharacterRoleType roleType,
    required RegionType regionType,
  }) = _CharacterCardModel;
}
