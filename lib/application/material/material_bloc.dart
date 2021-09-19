import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
import 'package:shiori/application/common/pop_bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'material_bloc.freezed.dart';
part 'material_event.dart';
part 'material_state.dart';

class MaterialBloc extends PopBloc<MaterialEvent, MaterialState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;

  MaterialBloc(this._genshinService, this._telemetryService) : super(const MaterialState.loading());

  @override
  MaterialEvent getEventForPop(String? key) => MaterialEvent.loadFromName(key: key!, addToQueue: false);

  @override
  Stream<MaterialState> mapEventToState(MaterialEvent event) async* {
    final s = await event.map(
      loadFromName: (e) async {
        final material = _genshinService.getMaterial(e.key);
        if (e.addToQueue) {
          await _telemetryService.trackMaterialLoaded(e.key);
          currentItemsInStack.add(material.key);
        }
        return _buildInitialState(material);
      },
      loadFromImg: (e) async {
        final material = _genshinService.getMaterialByImage(e.image);
        if (e.addToQueue) {
          await _telemetryService.trackMaterialLoaded(material.image, loadedFromName: false);
          currentItemsInStack.add(material.key);
        }
        return _buildInitialState(material);
      },
    );

    yield s;
  }

  MaterialState _buildInitialState(MaterialFileModel material) {
    final translation = _genshinService.getMaterialTranslation(material.key);
    final charImgs = _genshinService.getCharacterImgsUsingMaterial(material.key);
    final weaponImgs = _genshinService.getWeaponImgsUsingMaterial(material.key);
    final relatedMaterials = _genshinService.getRelatedMaterialImgsToMaterial(material.key);
    final droppedBy = _genshinService.getRelatedMonsterImgsToMaterial(material.key);
    return MaterialState.loaded(
      name: translation.name,
      fullImage: material.fullImagePath,
      rarity: material.rarity,
      type: material.type,
      description: translation.description,
      charImages: charImgs,
      weaponImages: weaponImgs,
      days: material.days,
      obtainedFrom: material.obtainedFrom,
      relatedMaterials: relatedMaterials,
      droppedBy: droppedBy,
    );
  }
}
