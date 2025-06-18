part of 'banner_version_history_bloc.dart';

@freezed
sealed class BannerVersionHistoryState with _$BannerVersionHistoryState {
  const factory BannerVersionHistoryState.loading() = BannerVersionHistoryStateLoading;

  const factory BannerVersionHistoryState.loadedState({
    required double version,
    required List<BannerHistoryGroupedPeriodModel> items,
  }) = BannerVersionHistoryStateLoaded;
}
