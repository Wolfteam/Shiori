part of 'material_bloc.dart';

@freezed
abstract class MaterialEvent implements _$MaterialEvent {
  const factory MaterialEvent.loadFromName({
    @required String key,
    @Default(true) bool addToQueue,
  }) = _LoadMaterialFromName;

  const factory MaterialEvent.loadFromImg({
    @required String image,
    @Default(true) bool addToQueue,
  }) = _LoadMaterialFromImg;
}
