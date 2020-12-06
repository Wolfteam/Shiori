import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/models.dart';
import '../../services/genshing_service.dart';

part 'characters_bloc.freezed.dart';
part 'characters_event.dart';
part 'characters_state.dart';

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  final GenshinService _genshinService;
  CharactersBloc(this._genshinService) : super(const CharactersState.loading());

  @override
  Stream<CharactersState> mapEventToState(
    CharactersEvent event,
  ) async* {
    final s = event.when(init: () => _init());
    yield s;
  }

  CharactersState _init() {
    final characters = _genshinService.getCharactersForCard();
    return CharactersState.loaded(characters: characters);
  }
}
