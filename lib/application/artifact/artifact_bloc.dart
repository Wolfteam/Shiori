import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshindb/domain/app_constants.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/telemetry_service.dart';

part 'artifact_bloc.freezed.dart';
part 'artifact_event.dart';
part 'artifact_state.dart';

class ArtifactBloc extends Bloc<ArtifactEvent, ArtifactState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  ArtifactBloc(this._genshinService, this._telemetryService) : super(const ArtifactState.loading());

  @override
  Stream<ArtifactState> mapEventToState(
    ArtifactEvent event,
  ) async* {
    yield const ArtifactState.loading();

    final s = await event.map(
      loadArtifact: (e) async {
        await _telemetryService.trackArtifactLoaded(e.key);
        final artifact = _genshinService.getArtifact(e.key);
        final translation = _genshinService.getArtifactTranslation(e.key);
        final charImgs = _genshinService.getCharactersImgUsingArtifact(e.key);

        var image = artifact.image.split('.png').first;
        image = image.substring(0, image.length - 1);

        return ArtifactState.loaded(
          name: translation.name,
          image: artifact.fullImagePath,
          rarityMin: artifact.rarityMin,
          rarityMax: artifact.rarityMax,
          bonus: translation.bonus.map((t) {
            final pieces = artifact.bonus.firstWhere((b) => b.key == t.key).pieces;
            return ArtifactCardBonusModel(pieces: pieces, bonus: t.bonus);
          }).toList(),
          images:
              translation.bonus.length == 1 ? [artifact.fullImagePath] : artifactOrder.map((e) => Assets.getArtifactPath('$image$e.png')).toList(),
          charImages: charImgs,
        );
      },
    );

    yield s;
  }
}
