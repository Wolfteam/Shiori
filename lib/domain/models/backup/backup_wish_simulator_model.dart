import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'backup_wish_simulator_model.freezed.dart';
part 'backup_wish_simulator_model.g.dart';

@freezed
abstract class BackupWishSimulatorModel with _$BackupWishSimulatorModel {
  const factory BackupWishSimulatorModel({
    required List<BackupWishSimulatorBannerPullHistory> pullHistory,
    required List<BackupWishSimulatorBannerItemPullHistory> itemPullHistory,
  }) = _BackupWishSimulatorModel;

  factory BackupWishSimulatorModel.fromJson(Map<String, dynamic> json) => _$BackupWishSimulatorModelFromJson(json);
}

@freezed
abstract class BackupWishSimulatorBannerPullHistory with _$BackupWishSimulatorBannerPullHistory {
  const factory BackupWishSimulatorBannerPullHistory({
    required BannerItemType type,
    required Map<int, int> currentXStarCount,
    required Map<int, bool> fiftyFiftyXStarGuaranteed,
  }) = _BackupWishSimulatorBannerPullHistory;

  factory BackupWishSimulatorBannerPullHistory.fromJson(Map<String, dynamic> json) =>
      _$BackupWishSimulatorBannerPullHistoryFromJson(json);
}

@freezed
abstract class BackupWishSimulatorBannerItemPullHistory with _$BackupWishSimulatorBannerItemPullHistory {
  const factory BackupWishSimulatorBannerItemPullHistory({
    required BannerItemType bannerType,
    required String itemKey,
    required ItemType itemType,
    required DateTime pulledOn,
  }) = _BackupWishSimulatorBannerItemPullHistory;

  factory BackupWishSimulatorBannerItemPullHistory.fromJson(Map<String, dynamic> json) =>
      _$BackupWishSimulatorBannerItemPullHistoryFromJson(json);
}
