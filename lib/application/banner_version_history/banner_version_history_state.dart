part of 'banner_version_history_bloc.dart';

@freezed
class BannerVersionHistoryState with _$BannerVersionHistoryState {
  const factory BannerVersionHistoryState.loading() = _LoadingState;

  const factory BannerVersionHistoryState.loadedState({
    required double version,
    required List<BannerHistoryGroupedPeriodModel> items,
  }) = _LoadedState;
}
