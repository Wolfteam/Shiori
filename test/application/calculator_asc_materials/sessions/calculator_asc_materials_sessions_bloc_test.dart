import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/errors.dart';
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
      showMaterialUsage: true,
    ),
    CalculatorSessionModel(
      key: 2,
      name: 'B',
      numberOfCharacters: 1,
      numberOfWeapons: 0,
      position: 1,
      showMaterialUsage: true,
    ),
    CalculatorSessionModel(
      key: 3,
      name: 'C',
      numberOfCharacters: 0,
      numberOfWeapons: 1,
      position: 2,
      showMaterialUsage: true,
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
    () => expect(
      getBloc().state,
      const CalculatorAscMaterialsSessionsState.loading(),
      reason: 'A freshly built sessions bloc must start in the loading state before init',
    ),
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
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsSessionsStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsSessionsStateLoaded():
            verify(calcMock.getAllSessions()).called(1);
            expect(
              state.sessions,
              sessions,
              reason: 'After init, loaded state must expose all stored sessions from the repository',
            );
        }
      },
    );
  });

  group('Create session', () {
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.createSession(name: '', showMaterialUsage: false)),
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid name',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.createSession(name: '', showMaterialUsage: false)),
      errors: () => [predicate<ArgumentError>((e) => e.name == 'name')],
    );

    const createdSession = CalculatorSessionModel(
      key: 1,
      name: 'NewOne',
      position: 0,
      numberOfCharacters: 0,
      numberOfWeapons: 0,
      showMaterialUsage: true,
    );
    final dataServiceMock = MockDataService();
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    when(calcMock.itemAdded).thenReturn(itemAddedOrDeleted);
    when(calcMock.itemDeleted).thenReturn(itemAddedOrDeleted);
    when(
      calcMock.createSession(createdSession.name, createdSession.position, createdSession.showMaterialUsage),
    ).thenAnswer((_) => Future.value(createdSession));
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'valid call',
      build: () => getBloc(dataService: dataServiceMock),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsSessionsEvent.createSession(
          name: createdSession.name,
          showMaterialUsage: createdSession.showMaterialUsage,
        ),
      ),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsSessionsStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsSessionsStateLoaded():
            expect(
              state.sessions.length,
              1,
              reason: 'After createSession, loaded state must hold exactly the one newly created session',
            );
            expect(
              state.sessions.first,
              createdSession,
              reason: 'After createSession, the stored session must equal the created one (key=${createdSession.key})',
            );
            verify(
              calcMock.createSession(createdSession.name, createdSession.position, createdSession.showMaterialUsage),
            ).called(1);
        }
      },
    );
  });

  group('Update session', () {
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) =>
          bloc.add(const CalculatorAscMaterialsSessionsEvent.updateSession(key: 1, name: '', showMaterialUsage: false)),
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid session key',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) =>
          bloc.add(const CalculatorAscMaterialsSessionsEvent.updateSession(key: -1, name: 'Name', showMaterialUsage: false)),
      errors: () => [predicate<ArgumentError>((e) => e.name == 'key')],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid session name',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) =>
          bloc.add(const CalculatorAscMaterialsSessionsEvent.updateSession(key: 1, name: '', showMaterialUsage: false)),
      errors: () => [predicate<ArgumentError>((e) => e.name == 'name')],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'session does not exist',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) =>
          bloc.add(const CalculatorAscMaterialsSessionsEvent.updateSession(key: 1, name: 'Updated', showMaterialUsage: false)),
      errors: () => [isA<NotFoundError>()],
    );

    final updatedSession = sessions[1].copyWith(name: 'Updated');
    final dataServiceMock = MockDataService();
    final calcMock = nice_mocks.MockCalculatorAscMaterialsDataService();
    when(calcMock.itemAdded).thenReturn(itemAddedOrDeleted);
    when(calcMock.itemDeleted).thenReturn(itemAddedOrDeleted);
    when(
      calcMock.updateSession(updatedSession.key, updatedSession.name, updatedSession.showMaterialUsage),
    ).thenAnswer((_) => Future.value(updatedSession));
    when(dataServiceMock.calculator).thenReturn(calcMock);
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'valid call',
      build: () => getBloc(dataService: dataServiceMock),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: sessions),
      act: (bloc) => bloc.add(
        CalculatorAscMaterialsSessionsEvent.updateSession(
          key: updatedSession.key,
          name: updatedSession.name,
          showMaterialUsage: updatedSession.showMaterialUsage,
        ),
      ),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsSessionsStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsSessionsStateLoaded():
            expect(
              state.sessions.length,
              sessions.length,
              reason: 'After updateSession, the session count must be unchanged (only one session is edited in place)',
            );
            expect(
              state.sessions.firstWhere((el) => el.key == updatedSession.key),
              updatedSession,
              reason: 'After updateSession, the edited session must reflect the new name (key=${updatedSession.key})',
            );
            verify(calcMock.updateSession(updatedSession.key, updatedSession.name, updatedSession.showMaterialUsage)).called(1);
        }
      },
    );
  });

  group('Delete session', () {
    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.deleteSession(key: 1)),
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'invalid session key',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.deleteSession(key: -1)),
      errors: () => [predicate<RangeError>((e) => e.name == 'key')],
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
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsSessionsStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsSessionsStateLoaded():
            expect(
              state.sessions.length,
              sessions.length - 1,
              reason: 'After deleteSession, exactly one session must be removed from the loaded list',
            );
            expect(
              state.sessions.map((e) => e.key).toList(),
              isNot(contains(sessions.first.key)),
              reason: 'After deleteSession, the deleted key must no longer appear (key=${sessions.first.key})',
            );
            verify(calcMock.deleteSession(sessions.first.key)).called(1);
        }
      },
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
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'empty items',
      build: () => getBloc(),
      seed: () => const CalculatorAscMaterialsSessionsState.loaded(sessions: []),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.itemsReordered([])),
      errors: () => [isA<UnsupportedError>()],
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
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      'item deleted but invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsSessionsEvent.itemDeleted(sessionKey: 1, isCharacter: true)),
      errors: () => [isA<InvalidStateError>()],
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

      expect(
        got,
        expected,
        reason: 'After item ${added ? 'added' : 'deleted'}, session count must go $current -> $expected (clamped at 0)',
      );
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
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case CalculatorAscMaterialsSessionsStateLoading():
              throw InvalidStateError();
            case CalculatorAscMaterialsSessionsStateLoaded():
              for (int i = 0; i < sessions.length; i++) {
                final session = sessions[i];
                final inState = state.sessions[i];
                if (inState.key == sessions.last.key) {
                  checkCount(sessions.last.numberOfCharacters, state.sessions.last.numberOfCharacters, added);
                } else {
                  expect(
                    session.numberOfCharacters,
                    inState.numberOfCharacters,
                    reason: 'Non-target session character count unchanged by character event (key=${session.key})',
                  );
                }
                expect(
                  session.numberOfWeapons,
                  inState.numberOfWeapons,
                  reason: 'Weapon count must be unchanged by a character add/delete event (key=${session.key})',
                );
              }
              checkCount(sessions.last.numberOfCharacters, state.sessions.last.numberOfCharacters, added);
          }
        },
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
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case CalculatorAscMaterialsSessionsStateLoading():
              throw InvalidStateError();
            case CalculatorAscMaterialsSessionsStateLoaded():
              for (int i = 0; i < sessions.length; i++) {
                final session = sessions[i];
                final inState = state.sessions[i];
                if (inState.key == sessions.last.key) {
                  checkCount(sessions.last.numberOfWeapons, state.sessions.last.numberOfWeapons, added);
                } else {
                  expect(
                    session.numberOfWeapons,
                    inState.numberOfWeapons,
                    reason: 'Non-target session weapon count unchanged by weapon event (key=${session.key})',
                  );
                }
                expect(
                  session.numberOfCharacters,
                  inState.numberOfCharacters,
                  reason: 'Character count must be unchanged by a weapon add/delete event (key=${session.key})',
                );
              }
          }
        },
      );
    }
  });
}
