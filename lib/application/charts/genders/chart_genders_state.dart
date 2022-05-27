part of 'chart_genders_bloc.dart';

@freezed
class ChartGendersState with _$ChartGendersState {
  const factory ChartGendersState.loading() = _LoadingState;

  const factory ChartGendersState.loaded({
    required int maxCount,
    required List<ChartGenderModel> genders,
  }) = _LoadedState;
}
