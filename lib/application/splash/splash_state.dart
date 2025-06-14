part of 'splash_bloc.dart';

@freezed
sealed class SplashState with _$SplashState {
  const factory SplashState.loading() = SplashStateLoading;

  const factory SplashState.loaded({
    required AppResourceUpdateResultType updateResultType,
    required LanguageModel language,
    required bool noResourcesHasBeenDownloaded,
    required bool isLoading,
    required bool isUpdating,
    required bool updateFailed,
    required bool noInternetConnectionOnFirstInstall,
    required bool needsLatestAppVersionOnFirstInstall,
    required bool canSkipUpdate,
    CheckForUpdatesResult? result,
    @Default(0) double progress,
    @Default(0) int downloadedBytes,
  }) = SplashStateLoaded;
}
