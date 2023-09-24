import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'wish_simulator_banner_item_result_model.freezed.dart';

@freezed
class WishSimulatorBannerItemResultModel with _$WishSimulatorBannerItemResultModel {
  const factory WishSimulatorBannerItemResultModel.character({
    required String key,
    required String image,
    required int rarity,
    required ElementType elementType,
  }) = _WishSimulatorBannerCharacterResultModel;

  const factory WishSimulatorBannerItemResultModel.weapon({
    required String key,
    required String image,
    required int rarity,
    required WeaponType weaponType,
  }) = _WishSimulatorBannerWeaponResultModel;
}
