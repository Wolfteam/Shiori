import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';

part 'banner_history_period_model.freezed.dart';

@freezed
class BannerHistoryPeriodModel with _$BannerHistoryPeriodModel {
  const factory BannerHistoryPeriodModel({
    required BannerHistoryItemType type,
    required DateTime from,
    required DateTime until,
    required double version,
    required List<ItemCommonWithRarityAndType> items,
  }) = _BannerHistoryPeriodModel;
}

@freezed
class BannerHistoryGroupedPeriodModel with _$BannerHistoryGroupedPeriodModel {
  const factory BannerHistoryGroupedPeriodModel({
    required String from,
    required String until,
    required List<ItemCommonWithRarityAndType> items,
  }) = _BannerHistoryGroupedPeriodModel;
}
