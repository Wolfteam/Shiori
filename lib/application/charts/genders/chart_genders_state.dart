part of 'chart_genders_bloc.dart';

@freezed
sealed class ChartGendersState with _$ChartGendersState {
  const factory ChartGendersState.loading() = ChartGendersStateLoading;

  const factory ChartGendersState.loaded({
    required int maxCount,
    required List<ChartGenderModel> genders,
  }) = ChartGendersStateLoaded;
}
