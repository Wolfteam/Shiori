import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';

//TODO: USE REPLAY_BLOC ONCE WE MIGRATE TO NULL SAFETY
abstract class PopBloc<Event, State> extends Bloc<Event, State> {
  @protected
  final List<String> currentItemsInStack = [];

  PopBloc(State initialState) : super(initialState);

  Event getEventForPop(String? key);

  void pop() {
    final key = _popAndGetLastKey();
    if (key.isNotNullEmptyOrWhitespace) {
      final event = getEventForPop(key);
      add(event);
    }
  }

  String? _popAndGetLastKey() {
    if (currentItemsInStack.isEmpty) {
      return null;
    }

    currentItemsInStack.removeLast();
    if (currentItemsInStack.isEmpty) {
      return null;
    }

    return currentItemsInStack.last;
  }
}
