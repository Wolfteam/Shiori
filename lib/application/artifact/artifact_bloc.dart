import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'artifact_bloc.freezed.dart';
part 'artifact_event.dart';
part 'artifact_state.dart';

class ArtifactBloc extends Bloc<ArtifactEvent, ArtifactState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final ResourceService _resourceService;

  ArtifactBloc(this._genshinService, this._telemetryService, this._resourceService) : super(const ArtifactState.loading()) {
    on<ArtifactEvent>((event, emit) => _mapEventToState(event, emit));
  }

  Future<void> _mapEventToState(ArtifactEvent event, Emitter<ArtifactState> emit) async {
    emit(const ArtifactState.loading());

    final s = await event.map(
      loadFromKey: (e) async {
        final artifact = _genshinService.artifacts.getArtifact(e.key);
        final artifactImgPath = _resourceService.getArtifactImagePath(artifact.image);
        final translation = _genshinService.translations.getArtifactTranslation(e.key);
        final usedBy = _genshinService.characters.getCharacterForItemsUsingArtifact(e.key);
        final droppedBy = _genshinService.monsters.getRelatedMonsterToArtifactForItems(e.key);
        final images = _genshinService.artifacts.getArtifactRelatedParts(artifactImgPath, artifact.image, translation.bonus.length);
        final bonus = _genshinService.artifacts.getArtifactBonus(translation);

        await _telemetryService.trackArtifactLoaded(e.key);

        return ArtifactState.loaded(
          name: translation.name,
          image: artifactImgPath,
          minRarity: artifact.minRarity,
          maxRarity: artifact.maxRarity,
          bonus: bonus,
          images: images,
          usedBy: usedBy,
          droppedBy: droppedBy,
        );
      },
    );

    emit(s);
  }
}
