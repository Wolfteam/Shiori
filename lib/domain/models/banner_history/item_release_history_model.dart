import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_release_history_model.freezed.dart';

@freezed
class ItemReleaseHistoryModel with _$ItemReleaseHistoryModel {
  const factory ItemReleaseHistoryModel({
    required double version,
    required List<ItemReleaseHistoryDatesModel> dates,
  }) = _ItemReleaseHistory;
}

@freezed
class ItemReleaseHistoryDatesModel with _$ItemReleaseHistoryDatesModel {
  const factory ItemReleaseHistoryDatesModel({
    required DateTime from,
    required DateTime until,
  }) = _ItemReleaseHistoryDatesModel;
}
