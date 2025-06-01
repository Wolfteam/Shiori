import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';

part 'banner_history_file.freezed.dart';
part 'banner_history_file.g.dart';

@freezed
abstract class BannerHistoryFile with _$BannerHistoryFile {
  const factory BannerHistoryFile({
    required List<BannerHistoryPeriodFileModel> banners,
  }) = _BannerHistoryFile;

  factory BannerHistoryFile.fromJson(Map<String, dynamic> json) => _$BannerHistoryFileFromJson(json);
}
