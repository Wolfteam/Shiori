part of 'calculator_asc_materials_bloc.dart';

@freezed
abstract class CalculatorAscMaterialsEvent with _$CalculatorAscMaterialsEvent {
  const factory CalculatorAscMaterialsEvent.init({
    @required List<ItemAscensionMaterials> items,
  }) = _Init;

  const factory CalculatorAscMaterialsEvent.addCharacter({
    @required int sessionKey,
    @required String key,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
    @required List<CharacterSkill> skills,
  }) = _AddCharacter;

  const factory CalculatorAscMaterialsEvent.updateCharacter({
    @required int sessionKey,
    @required int index,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
    @required List<CharacterSkill> skills,
    @required bool isActive,
  }) = _UpdateCharacter;

  const factory CalculatorAscMaterialsEvent.addWeapon({
    @required int sessionKey,
    @required String key,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
  }) = _AddWeapon;

  const factory CalculatorAscMaterialsEvent.updateWeapon({
    @required int sessionKey,
    @required int index,
    @required int currentLevel,
    @required int desiredLevel,
    @required int currentAscensionLevel,
    @required int desiredAscensionLevel,
    @required bool isActive,
  }) = _UpdateWeapon;

  const factory CalculatorAscMaterialsEvent.removeItem({
    @required int sessionKey,
    @required int index,
  }) = _RemoveItem;
}
