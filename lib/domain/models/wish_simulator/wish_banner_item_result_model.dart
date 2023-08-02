import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'wish_banner_item_result_model.freezed.dart';

@freezed
class WishBannerItemResultModel with _$WishBannerItemResultModel {
  const factory WishBannerItemResultModel.character({
    required String key,
    required String image,
    required int rarity,
    required ElementType elementType,
  }) = _WishBannerCharacterResultModel;

  const factory WishBannerItemResultModel.weapon({
    required String key,
    required String image,
    required int rarity,
    required WeaponType weaponType,
  }) = _WishBannerWeaponResultModel;
}
