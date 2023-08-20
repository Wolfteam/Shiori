import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_tab_bloc.freezed.dart';
part 'main_tab_event.dart';
part 'main_tab_state.dart';

class MainTabBloc extends Bloc<MainTabEvent, MainTabState> {
  MainTabBloc() : super(const MainTabState.initial(2)) {
    on<MainTabEvent>((event, emit) => _mapEventToState(event, emit));
  }

  Future<void> _mapEventToState(MainTabEvent event, Emitter<MainTabState> emit) async {
    final s = await event.when(
      goToTab: (index) async {
        if (index < 0) {
          return state;
        }
        return state.copyWith(currentSelectedTab: index);
      },
    );

    emit(s);
  }
}
