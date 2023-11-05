part of 'calculator_asc_materials_sessions_bloc.dart';

@freezed
class CalculatorAscMaterialsSessionsEvent with _$CalculatorAscMaterialsSessionsEvent {
  const factory CalculatorAscMaterialsSessionsEvent.init() = _Init;

  const factory CalculatorAscMaterialsSessionsEvent.createSession({
    required String name,
  }) = _CreateSession;

  const factory CalculatorAscMaterialsSessionsEvent.updateSession({
    required int key,
    required String name,
  }) = _UpdateSession;

  const factory CalculatorAscMaterialsSessionsEvent.deleteSession({
    required int key,
  }) = _DeleteSession;

  const factory CalculatorAscMaterialsSessionsEvent.deleteAllSessions() = _DeleteAllSessions;

  const factory CalculatorAscMaterialsSessionsEvent.itemsReordered(List<CalculatorSessionModel> updated) = _ItemsReordered;

  const factory CalculatorAscMaterialsSessionsEvent.itemAdded({
    required int sessionKey,
    required bool isCharacter,
  }) = _ItemAdded;

  const factory CalculatorAscMaterialsSessionsEvent.itemDeleted({
    required int sessionKey,
    required bool isCharacter,
  }) = _ItemDeleted;
}
