part of 'splash_bloc.dart';

@freezed
sealed class SplashEvent with _$SplashEvent {
  const factory SplashEvent.init({
    @Default(false) bool retry,
    @Default(false) bool restarted,
  }) = SplashEventInit;

  const factory SplashEvent.applyUpdate({required CheckForUpdatesResult result}) = SplashEventApplyUpdate;

  const factory SplashEvent.progressChanged({
    required double progress,
    required int downloadedBytes,
  }) = SplashEventProgressChanged;

  const factory SplashEvent.updateCompleted({
    required bool applied,
    required int resourceVersion,
  }) = SplashEventUpdateCompleted;
}
