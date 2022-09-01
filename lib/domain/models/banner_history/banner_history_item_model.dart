import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'banner_history_item_model.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class BannerHistoryItemModel with _$BannerHistoryItemModel {
  const factory BannerHistoryItemModel({
    required String key,
    required BannerHistoryItemType type,
    required String name,
    required String image,
    required int rarity,
    required List<BannerHistoryItemVersionModel> versions,
  }) = _BannerHistoryItemModel;
}

@freezed
class BannerHistoryItemVersionModel with _$BannerHistoryItemVersionModel {
  const factory BannerHistoryItemVersionModel({
    required double version,
    required bool released,
    int? number,
  }) = _BannerHistoryItemVersionModel;
}
