part of 'splash_bloc.dart';

@freezed
class SplashState with _$SplashState {
  const factory SplashState.loading() = _LoadingState;

  const factory SplashState.loaded({
    required AppResourceUpdateResultType updateResultType,
    required LanguageModel language,
    @Default(0) double progress,
  }) = _LoadedState;
}
