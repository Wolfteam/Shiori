import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_tab_bloc.freezed.dart';
part 'main_tab_event.dart';
part 'main_tab_state.dart';

class MainTabBloc extends Bloc<MainTabEvent, MainTabState> {
  MainTabBloc() : super(const MainTabState.initial(2)) {
    on<MainTabEvent>((event, emit) => _mapEventToState(event, emit), transformer: sequential());
  }

  Future<void> _mapEventToState(MainTabEvent event, Emitter<MainTabState> emit) async {
    switch (event) {
      case MainTabEventGoToTab():
        if (event.index < 0) {
          emit(state);
        } else {
          emit(state.copyWith(currentSelectedTab: event.index));
        }
    }
  }
}
