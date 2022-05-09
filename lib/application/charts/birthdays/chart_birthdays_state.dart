part of 'chart_birthdays_bloc.dart';

@freezed
class ChartBirthdaysState with _$ChartBirthdaysState {
  const factory ChartBirthdaysState.loading() = _LoadingState;

  const factory ChartBirthdaysState.initial({
    required List<ChartBirthdayMonthModel> birthdays,
  }) = _LoadedState;
}
