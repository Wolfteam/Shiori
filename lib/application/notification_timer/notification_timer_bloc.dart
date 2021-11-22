import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_timer_bloc.freezed.dart';
part 'notification_timer_event.dart';
part 'notification_timer_state.dart';

class NotificationTimerBloc extends Bloc<NotificationTimerEvent, NotificationTimerState> {
  Timer? _timer;

  NotificationTimerBloc() : super(NotificationTimerState.loaded(completesAt: DateTime.now(), remaining: Duration.zero));

  @override
  Stream<NotificationTimerState> mapEventToState(NotificationTimerEvent event) async* {
    final s = event.map(
      init: (e) {
        startTime();
        return NotificationTimerState.loaded(completesAt: e.completesAt, remaining: e.completesAt.difference(DateTime.now()));
      },
      refresh: (e) {
        if (state.remaining.inSeconds > 0) {
          return state.copyWith.call(remaining: state.completesAt.difference(DateTime.now()));
        }
        return state;
      },
    );

    yield s;
  }

  @override
  Future<void> close() {
    cancelTimer();
    return super.close();
  }

  void startTime() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => add(NotificationTimerEvent.refresh(ticks: timer.tick)));
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
