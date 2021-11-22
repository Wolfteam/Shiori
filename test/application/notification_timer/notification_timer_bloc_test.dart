import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';

void main() {
  final now = DateTime.now();
  group('Initial state', () {
    test(
      'completes now',
      () {
        final completesAt = NotificationTimerBloc().state.completesAt;
        final smallDifference = now.difference(completesAt).inSeconds < 1;
        expect(smallDifference, true);
      },
    );

    test(
      'duration is zero',
      () => expect(NotificationTimerBloc().state.remaining, Duration.zero),
    );
  });

  blocTest<NotificationTimerBloc, NotificationTimerState>(
    'Init',
    build: () => NotificationTimerBloc(),
    act: (bloc) => bloc.add(NotificationTimerEvent.init(completesAt: now.add(const Duration(seconds: 30)))),
    wait: const Duration(seconds: 3),
    verify: (bloc) {
      final completesAt = now.add(const Duration(seconds: 30));
      expect(bloc.state.completesAt, completesAt);

      //It is 26 cause we waited 3 seconds
      final diff = bloc.state.remaining.inSeconds - 26;
      expect(diff, lessThanOrEqualTo(1));
    },
  );

  blocTest<NotificationTimerBloc, NotificationTimerState>(
    'Remaining is zero',
    build: () => NotificationTimerBloc(),
    seed: () => NotificationTimerState.loaded(completesAt: now, remaining: Duration.zero),
    act: (bloc) => bloc.add(const NotificationTimerEvent.refresh(ticks: 1)),
    verify: (bloc) {
      expect(bloc.state, NotificationTimerState.loaded(completesAt: now, remaining: Duration.zero));
    },
  );
}
