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
  MaterialEvent getEventForPop(String? key) => MaterialEvent.loadFromKey(key: key!, addToQueue: false);

  @override
  Stream<MaterialState> mapEventToState(MaterialEvent event) async* {
    final s = await event.map(
      loadFromKey: (e) async {
        final material = _genshinService.getMaterial(e.key);
        if (e.addToQueue) {
          await _telemetryService.trackMaterialLoaded(e.key);
          currentItemsInStack.add(material.key);
        }
        return _buildInitialState(material);
      },
    );

    yield s;
  }

  MaterialState _buildInitialState(MaterialFileModel material) {
    final translation = _genshinService.getMaterialTranslation(material.key);
    final characters = _genshinService.getCharacterForItemsUsingMaterial(material.key);
    final weapons = _genshinService.getWeaponForItemsUsingMaterial(material.key);
    final droppedBy = _genshinService.getRelatedMonsterToMaterialForItems(material.key);
    final obtainedFrom = material.obtainedFrom.where((el) => el.createsMaterialKey == material.key).map((el) {
      final needs = el.needs.map((e) {
        final img = _genshinService.getMaterialImg(e.key);
        return ItemCommonWithQuantity(e.key, img, e.quantity);
      }).toList();
      return ItemObtainedFrom(el.createsMaterialKey, needs);
    }).toList();

    //TODO: SHOW THE QUANTITY IN THE RELATED MATERIALS
    final relatedMaterials = material.recipes.map((el) {
      final material = _genshinService.getMaterial(el.createsMaterialKey);
      return ItemCommon(material.key, material.fullImagePath);
    }).toList();
    return MaterialState.loaded(
      name: translation.name,
      fullImage: material.fullImagePath,
      rarity: material.rarity,
      type: material.type,
      description: translation.description,
      characters: characters,
      weapons: weapons,
      days: material.days,
      obtainedFrom: obtainedFrom,
      relatedMaterials: relatedMaterials,
      droppedBy: droppedBy,
    );
  }
}
