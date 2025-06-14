import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';

part 'banner_history_period_file_model.freezed.dart';
part 'banner_history_period_file_model.g.dart';

@freezed
abstract class BannerHistoryPeriodFileModel with _$BannerHistoryPeriodFileModel {
  const factory BannerHistoryPeriodFileModel({
    required BannerHistoryItemType type,
    required DateTime from,
    required DateTime until,
    required double version,
    required List<String> itemKeys,
    required String imageFilename,
  }) = _BannerHistoryPeriodFileModel;

  factory BannerHistoryPeriodFileModel.fromJson(Map<String, dynamic> json) => _$BannerHistoryPeriodFileModelFromJson(json);
}
