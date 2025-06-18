part of 'calculator_asc_materials_sessions_bloc.dart';

@freezed
sealed class CalculatorAscMaterialsSessionsEvent with _$CalculatorAscMaterialsSessionsEvent {
  const factory CalculatorAscMaterialsSessionsEvent.init() = CalculatorAscMaterialsSessionsEventInit;

  const factory CalculatorAscMaterialsSessionsEvent.createSession({
    required String name,
    required bool showMaterialUsage,
  }) = CalculatorAscMaterialsSessionsEventCreateSession;

  const factory CalculatorAscMaterialsSessionsEvent.updateSession({
    required int key,
    required String name,
    required bool showMaterialUsage,
  }) = CalculatorAscMaterialsSessionsEventUpdateSession;

  const factory CalculatorAscMaterialsSessionsEvent.deleteSession({
    required int key,
  }) = CalculatorAscMaterialsSessionsEventDeleteSession;

  const factory CalculatorAscMaterialsSessionsEvent.deleteAllSessions() = CalculatorAscMaterialsSessionsEventDeleteAllSessions;

  const factory CalculatorAscMaterialsSessionsEvent.itemsReordered(List<CalculatorSessionModel> updated) =
      CalculatorAscMaterialsSessionsEventItemsReordered;

  const factory CalculatorAscMaterialsSessionsEvent.itemAdded({
    required int sessionKey,
    required bool isCharacter,
  }) = CalculatorAscMaterialsSessionsEventItemAdded;

  const factory CalculatorAscMaterialsSessionsEvent.itemDeleted({
    required int sessionKey,
    required bool isCharacter,
  }) = CalculatorAscMaterialsSessionsEventItemDeleted;
}
