part of 'banner_version_history_bloc.dart';

@freezed
class BannerVersionHistoryEvent with _$BannerVersionHistoryEvent {
  const factory BannerVersionHistoryEvent.init({
    required double version,
  }) = _Init;
}
