part of 'banner_history_versions_bloc.dart';

@freezed
class BannerHistoryVersionsState with _$BannerHistoryVersionsState {
  const factory BannerHistoryVersionsState.initial({
    required List<BannerHistoryItemModel> banners,
    required List<double> versions,
  }) = _InitialState;
}
