part of 'today_materials_bloc.dart';

@freezed
sealed class TodayMaterialsEvent with _$TodayMaterialsEvent {
  const factory TodayMaterialsEvent.init() = TodayMaterialsEventInit;
}
