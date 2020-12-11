import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/models.dart';
import '../../services/genshing_service.dart';

part 'elements_bloc.freezed.dart';
part 'elements_event.dart';
part 'elements_state.dart';

class ElementsBloc extends Bloc<ElementsEvent, ElementsState> {
  final GenshinService _genshinService;
  ElementsBloc(this._genshinService) : super(const ElementsState.loading());

  @override
  Stream<ElementsState> mapEventToState(
    ElementsEvent event,
  ) async* {
    final s = event.when(
      init: () {
        final debuffs = _genshinService.getElementDebuffs();
        final reactions = _genshinService.getElementReactions();
        final resonances = _genshinService.getElementResonances();

        return ElementsState.loaded(debuffs: debuffs, reactions: reactions, resonances: resonances);
      },
    );

    yield s;
  }
}
