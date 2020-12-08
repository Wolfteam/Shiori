import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/models.dart';
import '../../services/genshing_service.dart';

part 'weapons_bloc.freezed.dart';
part 'weapons_event.dart';
part 'weapons_state.dart';

class WeaponsBloc extends Bloc<WeaponsEvent, WeaponsState> {
  final GenshinService _genshinService;
  WeaponsBloc(this._genshinService) : super(const WeaponsState.loading());

  @override
  Stream<WeaponsState> mapEventToState(
    WeaponsEvent event,
  ) async* {
    final s = event.when(
      init: () {
        final weapons = _genshinService.getWeaponsForCard();
        return WeaponsState.loaded(weapons: weapons);
      },
    );

    yield s;
  }
}
