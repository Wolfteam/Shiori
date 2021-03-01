part of 'calculator_asc_materials_bloc.dart';

@freezed
abstract class CalculatorAscMaterialsEvent with _$CalculatorAscMaterialsEvent {
  const factory CalculatorAscMaterialsEvent.init() = _Init;

  const factory CalculatorAscMaterialsEvent.addCharacter({
    @required String key,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
    @required List<CharacterSkill> skills,
  }) = _AddCharacter;

  const factory CalculatorAscMaterialsEvent.updateCharacter({
    @required int index,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
    @required List<CharacterSkill> skills,
  }) = _UpdateCharacter;

  const factory CalculatorAscMaterialsEvent.addWeapon({
    @required String key,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
  }) = _AddWeapon;

  const factory CalculatorAscMaterialsEvent.updateWeapon({
    @required int index,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
  }) = _UpdateWeapon;

  const factory CalculatorAscMaterialsEvent.removeItem({
    @required int index,
  }) = _RemoveItem;
}
