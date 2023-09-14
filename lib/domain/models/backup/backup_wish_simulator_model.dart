import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'backup_wish_simulator_model.freezed.dart';
part 'backup_wish_simulator_model.g.dart';

@freezed
class BackupWishSimulatorModel with _$BackupWishSimulatorModel {
  const factory BackupWishSimulatorModel({
    required List<BackupWishSimulatorBannerPullHistory> pullHistory,
    required List<BackupWishSimulatorBannerItemPullHistory> itemPullHistory,
  }) = _BackupWishSimulatorModel;

  factory BackupWishSimulatorModel.fromJson(Map<String, dynamic> json) => _$BackupWishSimulatorModelFromJson(json);
}

@freezed
class BackupWishSimulatorBannerPullHistory with _$BackupWishSimulatorBannerPullHistory {
  const factory BackupWishSimulatorBannerPullHistory({
    required BannerItemType type,
    required Map<int, int> currentXStarCount,
    required Map<int, bool> fiftyFiftyXStarGuaranteed,
  }) = _BackupWishSimulatorBannerPullHistory;

  factory BackupWishSimulatorBannerPullHistory.fromJson(Map<String, dynamic> json) =>
      _$BackupWishSimulatorBannerPullHistoryFromJson(json);
}

@freezed
class BackupWishSimulatorBannerItemPullHistory with _$BackupWishSimulatorBannerItemPullHistory {
  const factory BackupWishSimulatorBannerItemPullHistory({
    required String bannerKey,
    required String itemKey,
    required DateTime pulledOn,
  }) = _BackupWishSimulatorBannerItemPullHistory;

  factory BackupWishSimulatorBannerItemPullHistory.fromJson(Map<String, dynamic> json) =>
      _$BackupWishSimulatorBannerItemPullHistoryFromJson(json);
}
