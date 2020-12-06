import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../common/assets.dart';
import '../common/enums/app_language_type.dart';
import '../common/enums/material_type.dart';
import '../models/models.dart';

abstract class GenshinService {
  Future<void> init(AppLanguageType languageType);
  Future<void> initTranslations(AppLanguageType languageType);
  List<CharacterCardModel> getCharactersForCard();
  List<WepaonCardModel> getWeaponsForCard();
  List<ArtifactCardModel> getArtifactsForCard();
  CharacterFileModel getCharacter(String name);
  TranslationCharacterFile getCharacterTranslation(String name);
}

class GenshinServiceImpl implements GenshinService {
  AppFile _appFile;
  TranslationFile _translationFile;

  @override
  Future<void> init(AppLanguageType languageType) async {
    final jsonStr = await rootBundle.loadString(Assets.dbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _appFile = AppFile.fromJson(json);
    await initTranslations(languageType);
  }

  @override
  Future<void> initTranslations(AppLanguageType languageType) async {
    final transJsonStr = await rootBundle.loadString(Assets.getTranslationPath(languageType));
    final transJson = jsonDecode(transJsonStr) as Map<String, dynamic>;
    _translationFile = TranslationFile.fromJson(transJson);
  }

  @override
  List<CharacterCardModel> getCharactersForCard() {
    return _appFile.characters.map(
      (e) {
        final ascentionMaterial =
            e.ascentionMaterials.reduce((current, next) => current.level > next.level ? current : next);

        final talentMaterial = e.talentAscentionMaterials.isNotEmpty
            ? e.talentAscentionMaterials.reduce((current, next) => current.level > next.level ? current : next)
            : e.multiTalentAscentionMaterials
                .expand((e) => e.materials)
                .reduce((current, next) => current.level > next.level ? current : next);

        final materials = ascentionMaterial.materials + talentMaterial.materials;

        final mp = <String, ItemAscentionMaterialModel>{};
        for (final item in materials) {
          if (item.materialType != MaterialType.currency) {
            mp[item.image] = item;
          }
        }
        final quickMaterials = mp.values.toList();

        return CharacterCardModel(
          elementType: e.elementType,
          logoName: Assets.getCharacterPath(e.image),
          materials: quickMaterials.map((m) => m.fullImagePath).toList(),
          name: e.name,
          stars: e.rarity,
          weaponType: e.weaponType,
          isComingSoon: e.isComingSoon,
          isNew: e.isNew,
        );
      },
    ).toList();
  }

  @override
  CharacterFileModel getCharacter(String name) {
    return _appFile.characters.firstWhere((element) => element.name == name);
  }

  @override
  TranslationCharacterFile getCharacterTranslation(String name) {
    return _translationFile.characters.firstWhere((element) => element.key == name);
  }

  @override
  List<WepaonCardModel> getWeaponsForCard() {
    return [];
  }

  @override
  List<ArtifactCardModel> getArtifactsForCard() {
    return [];
  }
}
