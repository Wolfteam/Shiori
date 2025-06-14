part of 'custom_builds_bloc.dart';

@freezed
sealed class CustomBuildsState with _$CustomBuildsState {
  const factory CustomBuildsState.loaded({
    @Default(<CustomBuildModel>[]) List<CustomBuildModel> builds,
  }) = CustomBuildsStateLoaded;
}
