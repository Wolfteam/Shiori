import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'wish_simulator_banner_item_pull_history_model.freezed.dart';

@freezed
class WishSimulatorBannerItemPullHistoryModel with _$WishSimulatorBannerItemPullHistoryModel {
  const factory WishSimulatorBannerItemPullHistoryModel({
    required String key,
    required ItemType type,
    required DateTime pulledOn,
  }) = _WishSimulatorBannerItemPullHistoryModel;
}
