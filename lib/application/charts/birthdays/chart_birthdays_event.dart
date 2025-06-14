part of 'chart_birthdays_bloc.dart';

@freezed
sealed class ChartBirthdaysEvent with _$ChartBirthdaysEvent {
  const factory ChartBirthdaysEvent.init() = ChartBirthdaysEventInit;
}
