part of 'splash_bloc.dart';

@freezed
class SplashEvent with _$SplashEvent {
  const factory SplashEvent.init({@Default(false) bool retry}) = _Init;

  const factory SplashEvent.progressChanged({required double progress}) = _ProgressChanged;

  const factory SplashEvent.updateCompleted({required bool applied}) = _UpdateCompleted;
}
