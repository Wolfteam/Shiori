import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';

part 'elements_bloc.freezed.dart';
part 'elements_event.dart';
part 'elements_state.dart';

class ElementsBloc extends Bloc<ElementsEvent, ElementsState> {
  final GenshinService _genshinService;

  ElementsBloc(this._genshinService) : super(const ElementsState.loading()) {
    on<ElementsEvent>((event, emit) => _mapEventToState(event, emit));
  }

  Future<void> _mapEventToState(ElementsEvent event, Emitter<ElementsState> emit) async {
    final s = event.when(
      init: () {
        final debuffs = _genshinService.elements.getElementDebuffs();
        final reactions = _genshinService.elements.getElementReactions();
        final resonances = _genshinService.elements.getElementResonances();

        return ElementsState.loaded(debuffs: debuffs, reactions: reactions, resonances: resonances);
      },
    );

    emit(s);
  }
}
