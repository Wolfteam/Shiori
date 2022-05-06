part of 'charts_bloc.dart';

@freezed
class ChartsState with _$ChartsState {
  const factory ChartsState.loading() = _LoadingState;

  const factory ChartsState.initial({
    required List<ChartTopItemModel> tops,
    required List<ChartBirthdayMonthModel> birthdays,
    required List<ChartElementItemModel> elements,
    required List<ChartElementItemModel> filteredElements,
    @Default(<ElementType>[]) List<ElementType> selectedElementTypes,
  }) = _InitialState;
}
