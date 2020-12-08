import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../common/assets.dart';
import '../common/enums/app_language_type.dart';
import '../common/enums/material_type.dart';
import '../models/models.dart';

abstract class GenshinService {
  Future<void> init(AppLanguageType languageType);
  Future<void> initCharacters();
  Future<void> initWeapons();
  Future<void> initTranslations(AppLanguageType languageType);

  List<CharacterCardModel> getCharactersForCard();
  CharacterFileModel getCharacter(String name);

  List<WeaponCardModel> getWeaponsForCard();
  WeaponFileModel getWeapon(String name);

  List<ArtifactCardModel> getArtifactsForCard();

  TranslationCharacterFile getCharacterTranslation(String name);
  TranslationWeaponFile getWeaponTranslation(String name);
}

class GenshinServiceImpl implements GenshinService {
  CharactersFile _charactersFile;
  WeaponsFile _weaponsFile;
  TranslationFile _translationFile;

  @override
  Future<void> init(AppLanguageType languageType) async {
    await initCharacters();
    await initWeapons();
    await initTranslations(languageType);
  }

  @override
  Future<void> initCharacters() async {
    final jsonStr = await rootBundle.loadString(Assets.charactersDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _charactersFile = CharactersFile.fromJson(json);
  }

  @override
  Future<void> initWeapons() async {
    final jsonStr = await rootBundle.loadString(Assets.weaponsDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _weaponsFile = WeaponsFile.fromJson(json);
  }

  @override
  Future<void> initTranslations(AppLanguageType languageType) async {
    final transJsonStr = await rootBundle.loadString(Assets.getTranslationPath(languageType));
    final transJson = jsonDecode(transJsonStr) as Map<String, dynamic>;
    _translationFile = TranslationFile.fromJson(transJson);
  }

  @override
  List<CharacterCardModel> getCharactersForCard() {
    return _charactersFile.characters.map(
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
    return _charactersFile.characters.firstWhere((element) => element.name == name);
  }

  @override
  TranslationCharacterFile getCharacterTranslation(String name) {
    return _translationFile.characters.firstWhere((element) => element.key == name);
  }

  @override
  List<WeaponCardModel> getWeaponsForCard() {
    return _weaponsFile.weapons
        .map(
          (e) => WeaponCardModel(baseAtk: e.atk, image: e.fullImagePath, name: e.name, rarity: e.rarity, type: e.type),
        )
        .toList();
  }

  @override
  WeaponFileModel getWeapon(String name) {
    return _weaponsFile.weapons.firstWhere((element) => element.name == name);
  }

  @override
  TranslationWeaponFile getWeaponTranslation(String name) {
    return _translationFile.weapons.firstWhere((element) => element.key == name);
  }

  @override
  List<ArtifactCardModel> getArtifactsForCard() {
    return [];
  }
}
