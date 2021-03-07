part of 'calculator_asc_materials_item_bloc.dart';

@freezed
abstract class CalculatorAscMaterialsItemState with _$CalculatorAscMaterialsItemState {
  const factory CalculatorAscMaterialsItemState.loading() = _LoadingState;

  const factory CalculatorAscMaterialsItemState.loaded({
    @required String name,
    @required String imageFullPath,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
    @Default([]) List<CharacterSkill> skills,
  }) = _LoadedState;
}
