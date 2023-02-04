part of 'splash_bloc.dart';

@freezed
class SplashEvent with _$SplashEvent {
  const factory SplashEvent.init({
    @Default(false) bool retry,
    @Default(false) bool restarted,
  }) = _Init;

  const factory SplashEvent.applyUpdate({required CheckForUpdatesResult result}) = _ApplyUpdate;

  const factory SplashEvent.progressChanged({required double progress}) = _ProgressChanged;

  const factory SplashEvent.updateCompleted({
    required bool applied,
    required int resourceVersion,
  }) = _UpdateCompleted;
}
