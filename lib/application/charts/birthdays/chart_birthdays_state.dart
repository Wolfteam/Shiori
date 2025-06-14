part of 'chart_birthdays_bloc.dart';

@freezed
sealed class ChartBirthdaysState with _$ChartBirthdaysState {
  const factory ChartBirthdaysState.loading() = ChartBirthdaysStateLoading;

  const factory ChartBirthdaysState.loaded({
    required List<ChartBirthdayMonthModel> birthdays,
  }) = ChartBirthdaysStateLoaded;
}
