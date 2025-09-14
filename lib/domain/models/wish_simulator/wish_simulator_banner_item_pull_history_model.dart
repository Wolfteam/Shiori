import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'wish_simulator_banner_item_pull_history_model.freezed.dart';

@freezed
abstract class WishSimulatorBannerItemPullHistoryModel with _$WishSimulatorBannerItemPullHistoryModel {
  const factory WishSimulatorBannerItemPullHistoryModel({
    required String key,
    required String name,
    required int rarity,
    required ItemType type,
    required String pulledOn,
  }) = _WishSimulatorBannerItemPullHistoryModel;
}
