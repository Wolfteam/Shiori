import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/application/common/pop_bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'artifact_bloc.freezed.dart';
part 'artifact_event.dart';
part 'artifact_state.dart';

class ArtifactBloc extends PopBloc<ArtifactEvent, ArtifactState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  ArtifactBloc(this._genshinService, this._telemetryService) : super(const ArtifactState.loading());

  @override
  ArtifactEvent getEventForPop(String? key) => ArtifactEvent.loadFromKey(key: key!, addToQueue: false);

  @override
  Stream<ArtifactState> mapEventToState(ArtifactEvent event) async* {
    yield const ArtifactState.loading();

    final s = await event.map(
      loadFromKey: (e) async {
        final artifact = _genshinService.getArtifact(e.key);
        final translation = _genshinService.getArtifactTranslation(e.key);
        final charImgs = _genshinService.getCharacterForItemsUsingArtifact(e.key);
        final droppedBy = _genshinService.getRelatedMonsterToArtifactForItems(e.key);

        var image = artifact.image.split('.png').first;
        image = image.substring(0, image.length - 1);

        if (e.addToQueue) {
          await _telemetryService.trackArtifactLoaded(e.key);
          currentItemsInStack.add(artifact.key);
        }

        final bonus = _genshinService.getArtifactBonus(translation);

        return ArtifactState.loaded(
          name: translation.name,
          image: artifact.fullImagePath,
          minRarity: artifact.minRarity,
          maxRarity: artifact.maxRarity,
          bonus: bonus,
          images: translation.bonus.length == 1
              ? [artifact.fullImagePath]
              : artifactOrder
                  .map(
                    (e) => Assets.getArtifactPath('$image$e.png'),
                  )
                  .toList(),
          charImages: charImgs,
          droppedBy: droppedBy,
        );
      },
    );

    yield s;
  }
}
