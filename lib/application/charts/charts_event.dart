part of 'charts_bloc.dart';

@freezed
class ChartsEvent with _$ChartsEvent {
  const factory ChartsEvent.init() = _Init;

  const factory ChartsEvent.elementSelected({
    required ElementType type,
  }) = _ElementSelected;
}
