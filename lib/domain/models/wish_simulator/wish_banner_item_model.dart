import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/wish_banner_constants.dart';

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
  List<String> get featuredImages {
    switch (type) {
      case BannerItemType.character:
      case BannerItemType.weapon:
        return featuredItems.where((el) => el.rarity == WishBannerConstants.maxObtainableRarity).map((e) => e.iconImage).toList();
      case BannerItemType.standard:
        return [characters.firstWhere((el) => el.key == WishBannerConstants.commonFiveStarCharacterKeys.first).iconImage];
    }
  }

  const factory WishBannerItemModel({
    required BannerItemType type,
    required String image,
    required List<WishBannerFeaturedItemModel> featuredItems,
    @Default(<WishBannerCharacterModel>[]) List<WishBannerCharacterModel> characters,
    @Default(<WishBannerWeaponModel>[]) List<WishBannerWeaponModel> weapons,
  }) = _WishBannerItemModel;

  const WishBannerItemModel._();
}

@freezed
class WishBannerFeaturedItemModel with _$WishBannerFeaturedItemModel {
  const factory WishBannerFeaturedItemModel({
    required String key,
    required String iconImage,
    required int rarity,
    required ItemType type,
  }) = _WishBannerFeaturedItemModel;
}

@freezed
class WishBannerCharacterModel with _$WishBannerCharacterModel {
  const factory WishBannerCharacterModel({
    required String key,
    required int rarity,
    required String iconImage,
    required String image,
    required ElementType elementType,
  }) = _WishBannerCharacterModel;
}

@freezed
class WishBannerWeaponModel with _$WishBannerWeaponModel {
  const factory WishBannerWeaponModel({
    required String key,
    required int rarity,
    required String iconImage,
    required String image,
    required WeaponType weaponType,
  }) = _WishBannerWeaponModel;
}
