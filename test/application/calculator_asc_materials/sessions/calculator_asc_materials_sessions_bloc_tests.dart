import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

import '../../../mocks.mocks.dart';
import '../../../nice_mocks.mocks.dart' as nice_mocks;

class _MockItemAddedOrDeletedStream extends Fake implements StreamController<CalculatorAscMaterialSessionItemEvent> {
  @override
  Stream<CalculatorAscMaterialSessionItemEvent> get stream => Stream<CalculatorAscMaterialSessionItemEvent>.fromIterable([]);
}

void main() {
  const sessions = <CalculatorSessionModel>[
    CalculatorSessionModel(
      key: 1,
      name: 'A',
      numberOfCharacters: 1,
      numberOfWeapons: 2,
      position: 0,
    ),
    CalculatorSessionModel(
      key: 2,
      name: 'B',
      numberOfCharacters: 1,
      numberOfWeapons: 0,
      position: 1,
    ),
    CalculatorSessionModel(
      key: 3,
      name: 'C',
      numberOfCharacters: 0,
      numberOfWeapons: 1,
      position: 2,
    ),
  ];
  final TelemetryService telemetryService = MockTelemetryService();
  final StreamController<CalculatorAscMaterialSessionItemEvent> itemAddedOrDeleted = _MockItemAddedOrDeletedStream();

  CalculatorAscMaterialsSessionsBloc getBloc({DataService? dataService}) {
    final dataServiceMock = MockDataService();
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    when(calcMock.itemAdded).thenReturn(itemAddedOrDeleted);
    when(calcMock.itemDeleted).thenReturn(itemAddedOrDeleted);
    when(dataServiceMock.calculator).thenReturn(calcMock);
    return CalculatorAscMaterialsSessionsBloc(dataService ?? dataServiceMock, telemetryService);
  }

  test(
    'Initial state',
    () => expect(getBloc().state, const CalculatorAscMaterialsSessionsState.loading()),
  );

  group('Init', () {
    final dataServiceMock = MockDataService();
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    when(calcMock.itemAdded).thenReturn(itemAddedOrDeleted);
    when(calcMock.itemDeleted).thenReturn(itemAddedOrDeleted);
    when(calcMock.getAllSessions()).thenReturn(sessions);
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'data exists',
      build: () => getBloc(dataService: dataServiceMock),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.init()),
      verify: (bloc) => bloc.state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          verify(calcMock.getAllSessions()).called(1);
          expect(state.sessions, sessions);
        },
      ),
    );
  });

  group('Create session', () {
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.createSession(name: '')),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid name',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.createSession(name: '')),
      errors: () => [isA<Exception>()],
    );

    const createdSession = CalculatorSessionModel(key: 1, name: 'NewOne', position: 0, numberOfCharacters: 0, numberOfWeapons: 0);
    final dataServiceMock = MockDataService();
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    when(calcMock.itemAdded).thenReturn(itemAddedOrDeleted);
    when(calcMock.itemDeleted).thenReturn(itemAddedOrDeleted);
    when(calcMock.createSession(createdSession.name, createdSession.position)).thenAnswer((_) => Future.value(createdSession));
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'valid call',
      build: () => getBloc(dataService: dataServiceMock),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(CalculatorAscMaterialsSessionsEvent.createSession(name: createdSession.name)),
      verify: (bloc) => bloc.state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          expect(state.sessions.length, 1);
          expect(state.sessions.first, createdSession);
          verify(calcMock.createSession(createdSession.name, createdSession.position)).called(1);
        },
      ),
    );
  });

  group('Update session', () {
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.updateSession(key: 1, name: '')),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid session key',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.updateSession(key: -1, name: 'Name')),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid session name',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.updateSession(key: 1, name: '')),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'session does not exist',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.updateSession(key: 1, name: 'Updated')),
      errors: () => [isA<Exception>()],
    );

    final updatedSession = sessions[1].copyWith(name: 'Updated');
    final dataServiceMock = MockDataService();
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    when(calcMock.itemAdded).thenReturn(itemAddedOrDeleted);
    when(calcMock.itemDeleted).thenReturn(itemAddedOrDeleted);
    when(calcMock.updateSession(updatedSession.key, updatedSession.name)).thenAnswer((_) => Future.value(updatedSession));
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'valid call',
      build: () => getBloc(dataService: dataServiceMock),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: sessions),
      act: (bloc) => bloc.add(CalculatorAscMaterialsSessionsEvent.updateSession(key: updatedSession.key, name: updatedSession.name)),
      verify: (bloc) => bloc.state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          expect(state.sessions.length, sessions.length);
          expect(state.sessions.firstWhere((el) => el.key == updatedSession.key), updatedSession);
          verify(calcMock.updateSession(updatedSession.key, updatedSession.name)).called(1);
        },
      ),
    );
  });

  group('Delete session', () {
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.deleteSession(key: 1)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid session key',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.deleteSession(key: -1)),
      errors: () => [isA<Exception>()],
    );

    final dataServiceMock = MockDataService();
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    when(calcMock.itemAdded).thenReturn(itemAddedOrDeleted);
    when(calcMock.itemDeleted).thenReturn(itemAddedOrDeleted);
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'valid call',
      build: () => getBloc(dataService: dataServiceMock),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: sessions),
      act: (bloc) => bloc.add(CalculatorAscMaterialsSessionsEvent.deleteSession(key: sessions.first.key)),
      verify: (bloc) => bloc.state.map(
        loading: (_) => throw Exception('Invalid state'),
        loaded: (state) {
          expect(state.sessions.length, sessions.length - 1);
          expect(state.sessions.map((e) => e.key).toList(), isNot(contains(sessions.first.key)));
          verify(calcMock.deleteSession(sessions.first.key)).called(1);
        },
      ),
    );
  });

  group('Delete all sessions', () {
    final dataServiceMock = MockDataService();
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    when(calcMock.itemAdded).thenReturn(itemAddedOrDeleted);
    when(calcMock.itemDeleted).thenReturn(itemAddedOrDeleted);
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'valid call',
      build: () => getBloc(dataService: dataServiceMock),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: sessions),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.deleteAllSessions()),
      expect: () => const [CalculatorAscMaterialsSessionsState.loaded(sessions: [])],
      verify: (_) {
        verify(calcMock.deleteAllSessions()).called(1);
      },
    );
  });

  group('Items reordered', () {
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.itemsReordered([])),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'empty items',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.itemsReordered([])),
      errors: () => [isA<Exception>()],
    );

    final updated = [sessions.last, sessions[1], sessions.first];
    final dataServiceMock = MockDataService();
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    when(calcMock.itemAdded).thenReturn(itemAddedOrDeleted);
    when(calcMock.itemDeleted).thenReturn(itemAddedOrDeleted);
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'valid call',
      build: () => getBloc(dataService: dataServiceMock),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: sessions),
      act: (bloc) => bloc.add(CalculatorAscMaterialsSessionsEvent.itemsReordered(updated)),
      verify: (_) {
        verify(calcMock.reorderSessions(updated)).called(1);
        verify(calcMock.getAllSessions()).called(1);
      },
    );
  });

  group('Item count changed', () {
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'item added but invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.itemAdded(sessionKey: 1, isCharacter: true)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'item deleted but invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.itemDeleted(sessionKey: 1, isCharacter: true)),
      errors: () => [isA<Exception>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'item added but session does not exist',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.itemAdded(sessionKey: 1, isCharacter: true)),
      expect: () => [],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'item deleted but session does not exist',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.itemDeleted(sessionKey: 1, isCharacter: true)),
      expect: () => [],
    );

    void checkCount(int current, int got, bool added) {
      int expected = current;
      if (added) {
        expected++;
      } else {
        expected--;
      }

      if (expected < 0) {
        expected = 0;
      }

      expect(got, expected);
    }

    for (int i = 0; i < 2; i++) {
      final added = i == 0;
      final event = added
          ? CalculatorAscMaterialsSessionsEvent.itemAdded(sessionKey: sessions.last.key, isCharacter: true)
          : CalculatorAscMaterialsSessionsEvent.itemDeleted(sessionKey: sessions.last.key, isCharacter: true);
      blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
        'character ${added ? 'added' : 'deleted'}',
        build: () => getBloc(),
        seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: sessions),
        act: (bloc) => bloc.add(event),
        verify: (bloc) => bloc.state.map(
          loading: (_) => throw Exception('Invalid state'),
          loaded: (state) {
            for (int i = 0; i < sessions.length; i++) {
              final session = sessions[i];
              final inState = state.sessions[i];
              if (inState.key == sessions.last.key) {
                checkCount(sessions.last.numberOfCharacters, state.sessions.last.numberOfCharacters, added);
              } else {
                expect(session.numberOfCharacters, inState.numberOfCharacters);
              }
              expect(session.numberOfWeapons, inState.numberOfWeapons);
            }
            checkCount(sessions.last.numberOfCharacters, state.sessions.last.numberOfCharacters, added);
          },
        ),
      );
    }

    for (int i = 0; i < 2; i++) {
      final added = i == 1;
      final event = added
          ? CalculatorAscMaterialsSessionsEvent.itemAdded(sessionKey: sessions.last.key, isCharacter: false)
          : CalculatorAscMaterialsSessionsEvent.itemDeleted(sessionKey: sessions.last.key, isCharacter: false);
      blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
        'weapon ${added ? 'added' : 'deleted'}',
        build: () => getBloc(),
        seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: sessions),
        act: (bloc) => bloc.add(event),
        verify: (bloc) => bloc.state.map(
          loading: (_) => throw Exception('Invalid state'),
          loaded: (state) {
            for (int i = 0; i < sessions.length; i++) {
              final session = sessions[i];
              final inState = state.sessions[i];
              if (inState.key == sessions.last.key) {
                checkCount(sessions.last.numberOfWeapons, state.sessions.last.numberOfWeapons, added);
              } else {
                expect(session.numberOfWeapons, inState.numberOfWeapons);
              }
              expect(session.numberOfCharacters, inState.numberOfCharacters);
            }
          },
        ),
      );
    }
  });
}
