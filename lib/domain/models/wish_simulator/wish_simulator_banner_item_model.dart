import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/wish_banner_constants.dart';

part 'wish_simulator_banner_item_model.freezed.dart';

@freezed
class WishSimulatorBannerItemsPerPeriodModel with _$WishSimulatorBannerItemsPerPeriodModel {
  const factory WishSimulatorBannerItemsPerPeriodModel({
    required double version,
    required DateTime from,
    required DateTime until,
    required List<WishSimulatorBannerItemModel> banners,
  }) = _WishSimulatorBannerItemsPerPeriodModel;
}

@freezed
class WishSimulatorBannerItemModel with _$WishSimulatorBannerItemModel {
  List<String> get featuredImages {
    switch (type) {
      case BannerItemType.character:
      case BannerItemType.weapon:
        return featuredItems.where((el) => el.rarity == WishBannerConstants.maxObtainableRarity).map((e) => e.iconImage).toList();
      case BannerItemType.standard:
        return [characters.firstWhere((el) => el.key == WishBannerConstants.commonFiveStarCharacterKeys.first).iconImage];
    }
  }

  const factory WishSimulatorBannerItemModel({
    required BannerItemType type,
    required String image,
    required List<WishSimulatorBannerFeaturedItemModel> featuredItems,
    @Default(<WishSimulatorBannerCharacterModel>[]) List<WishSimulatorBannerCharacterModel> characters,
    @Default(<WishSimulatorBannerWeaponModel>[]) List<WishSimulatorBannerWeaponModel> weapons,
  }) = _WishSimulatorBannerItemModel;

  const WishSimulatorBannerItemModel._();
}

@freezed
class WishSimulatorBannerFeaturedItemModel with _$WishSimulatorBannerFeaturedItemModel {
  const factory WishSimulatorBannerFeaturedItemModel({
    required String key,
    required String iconImage,
    required int rarity,
    required ItemType type,
  }) = _WishSimulatorBannerFeaturedItemModel;
}

@freezed
class WishSimulatorBannerCharacterModel with _$WishSimulatorBannerCharacterModel {
  const factory WishSimulatorBannerCharacterModel({
    required String key,
    required int rarity,
    required String iconImage,
    required String image,
    required ElementType elementType,
  }) = _WisBSimulatorBannerCharacterModel;
}

@freezed
class WishSimulatorBannerWeaponModel with _$WishSimulatorBannerWeaponModel {
  const factory WishSimulatorBannerWeaponModel({
    required String key,
    required int rarity,
    required String iconImage,
    required String image,
    required WeaponType weaponType,
  }) = _WishSimulatorBannerWeaponModel;
}
