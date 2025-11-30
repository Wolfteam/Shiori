import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_timer_bloc.freezed.dart';
part 'notification_timer_event.dart';
part 'notification_timer_state.dart';

class NotificationTimerBloc extends Bloc<NotificationTimerEvent, NotificationTimerState> {
  Timer? _timer;

  NotificationTimerBloc() : super(NotificationTimerState.loaded(completesAt: DateTime.now(), remaining: Duration.zero)) {
    on<NotificationTimerEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(NotificationTimerEvent event, Emitter<NotificationTimerState> emit) async {
    switch (event) {
      case NotificationTimerEventInit():
        _startTime();
        emit(
          NotificationTimerState.loaded(
            completesAt: event.completesAt,
            remaining: event.completesAt.difference(DateTime.now()),
          ),
        );
      case NotificationTimerEventRefresh():
        if (state.remaining.inSeconds > 0) {
          emit(state.copyWith.call(remaining: state.completesAt.difference(DateTime.now())));
        } else {
          _cancelTimer();
          emit(state);
        }
    }
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }

  void _startTime() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => add(NotificationTimerEvent.refresh(ticks: timer.tick)));
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
