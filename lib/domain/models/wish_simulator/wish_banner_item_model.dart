import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'wish_banner_item_model.freezed.dart';

@freezed
class WishBannerItemsPerPeriodModel with _$WishBannerItemsPerPeriodModel {
  const factory WishBannerItemsPerPeriodModel({
    required double version,
    required DateTime from,
    required DateTime until,
    required List<WishBannerItemModel> banners,
  }) = _WishBannerItemsPerPeriodModel;
}

@freezed
class WishBannerItemModel with _$WishBannerItemModel {
  const factory WishBannerItemModel({
    required BannerItemType type,
    required String image,
    required List<ItemCommonWithRarityAndType> promotedItems,
    @Default(<WishBannerCharacterModel>[]) List<WishBannerCharacterModel> characters,
    @Default(<WishBannerWeaponModel>[]) List<WishBannerWeaponModel> weapons,
  }) = _WishBannerItemModel;
}

@freezed
class WishBannerCharacterModel with _$WishBannerCharacterModel {
  const factory WishBannerCharacterModel({
    required String key,
    required int rarity,
    required String image,
    required ElementType elementType,
  }) = _WishBannerCharacterModel;
}

@freezed
class WishBannerWeaponModel with _$WishBannerWeaponModel {
  const factory WishBannerWeaponModel({
    required String key,
    required int rarity,
    required String image,
    required WeaponType weaponType,
  }) = _WishBannerWeaponModel;
}
