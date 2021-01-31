part of 'materials_bloc.dart';

@freezed
abstract class MaterialsEvent with _$MaterialsEvent {
  const factory MaterialsEvent.init() = _Init;
}
