import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'artifact_bloc.freezed.dart';
part 'artifact_event.dart';
part 'artifact_state.dart';

class ArtifactBloc extends Bloc<ArtifactEvent, ArtifactState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  ArtifactBloc(this._genshinService, this._telemetryService) : super(const ArtifactState.loading());

  @override
  Stream<ArtifactState> mapEventToState(ArtifactEvent event) async* {
    yield const ArtifactState.loading();

    final s = await event.map(
      loadFromKey: (e) async {
        final artifact = _genshinService.artifacts.getArtifact(e.key);
        final translation = _genshinService.translations.getArtifactTranslation(e.key);
        final charImgs = _genshinService.characters.getCharacterForItemsUsingArtifact(e.key);
        final droppedBy = _genshinService.monsters.getRelatedMonsterToArtifactForItems(e.key);
        final images = _genshinService.artifacts.getArtifactRelatedParts(artifact.fullImagePath, artifact.image, translation.bonus.length);
        final bonus = _genshinService.artifacts.getArtifactBonus(translation);

        await _telemetryService.trackArtifactLoaded(e.key);

        return ArtifactState.loaded(
          name: translation.name,
          image: artifact.fullImagePath,
          minRarity: artifact.minRarity,
          maxRarity: artifact.maxRarity,
          bonus: bonus,
          images: images,
          charImages: charImgs,
          droppedBy: droppedBy,
        );
      },
    );

    yield s;
  }
}
