part of 'material_bloc.dart';

@freezed
sealed class MaterialEvent with _$MaterialEvent {
  const factory MaterialEvent.loadFromKey({
    required String key,
    @Default(true) bool addToQueue,
  }) = MaterialEventLoad;
}
