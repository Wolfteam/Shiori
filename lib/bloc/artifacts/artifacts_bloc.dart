import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/models.dart';
import '../../services/genshing_service.dart';

part 'artifacts_bloc.freezed.dart';
part 'artifacts_event.dart';
part 'artifacts_state.dart';

class ArtifactsBloc extends Bloc<ArtifactsEvent, ArtifactsState> {
  final GenshinService _genshinService;
  ArtifactsBloc(this._genshinService) : super(const ArtifactsState.loading());

  @override
  Stream<ArtifactsState> mapEventToState(
    ArtifactsEvent event,
  ) async* {
    final s = event.when(
      init: () {
        final artifacts = _genshinService.getArtifactsForCard();
        return ArtifactsState.loadedState(artifacts: artifacts);
      },
    );

    yield s;
  }
}
