part of 'banner_version_history_bloc.dart';

@freezed
sealed class BannerVersionHistoryEvent with _$BannerVersionHistoryEvent {
  const factory BannerVersionHistoryEvent.init({
    required double version,
  }) = BannerVersionHistoryEventInit;
}
