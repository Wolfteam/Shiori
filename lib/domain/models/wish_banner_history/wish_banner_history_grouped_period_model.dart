import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';

part 'wish_banner_history_grouped_period_model.freezed.dart';

@freezed
abstract class WishBannerHistoryGroupedPeriodModel with _$WishBannerHistoryGroupedPeriodModel {
  const factory WishBannerHistoryGroupedPeriodModel({
    required String groupingKey,
    required String groupingTitle,
    required List<WishBannerHistoryPartItemModel> parts,
  }) = _WishBannerHistoryGroupedPeriodModel;
}

@freezed
abstract class WishBannerHistoryPartItemModel with _$WishBannerHistoryPartItemModel {
  const factory WishBannerHistoryPartItemModel({
    required List<ItemCommonWithNameAndRarity> featuredCharacters,
    required List<ItemCommonWithNameAndRarity> featuredWeapons,
    required List<String> bannerImages,
    required DateTime from,
    required DateTime until,
    required double version,
  }) = _WishBannerHistoryPartItemModel;
}
