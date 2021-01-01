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
  Future<void> initArtifacts();
  Future<void> initMaterials();
  Future<void> initElements();
  Future<void> initTranslations(AppLanguageType languageType);

  List<CharacterCardModel> getCharactersForCard();
  CharacterFileModel getCharacter(String name);
  CharacterFileModel getCharacterByImg(String img);

  List<WeaponCardModel> getWeaponsForCard();
  WeaponCardModel getWeaponForCardByImg(String image);
  WeaponFileModel getWeapon(String name);
  WeaponFileModel getWeaponByImg(String img);

  List<ArtifactCardModel> getArtifactsForCard();
  ArtifactCardModel getArtifactForCardByImg(String image);
  ArtifactFileModel getArtifact(String name);
  TranslationArtifactFile getArtifactTranslation(String name);

  TranslationCharacterFile getCharacterTranslation(String name);
  TranslationWeaponFile getWeaponTranslation(String name);

  List<TodayCharAscentionMaterialsModel> getCharacterAscentionMaterials(int day);
  List<TodayWeaponAscentionMaterialModel> getWeaponAscentionMaterials(int day);

  List<ElementCardModel> getElementDebuffs();
  List<ElementReactionCardModel> getElementReactions();
  List<ElementReactionCardModel> getElementResonances();
}

class GenshinServiceImpl implements GenshinService {
  CharactersFile _charactersFile;
  WeaponsFile _weaponsFile;
  TranslationFile _translationFile;
  ArtifactsFile _artifactsFile;
  MaterialsFile _materialsFile;
  ElementsFile _elementsFile;

  @override
  Future<void> init(AppLanguageType languageType) async {
    await Future.wait([
      initCharacters(),
      initWeapons(),
      initArtifacts(),
      initMaterials(),
      initElements(),
      initTranslations(languageType)
    ]);
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
  Future<void> initArtifacts() async {
    final jsonStr = await rootBundle.loadString(Assets.artifactsDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _artifactsFile = ArtifactsFile.fromJson(json);
  }

  @override
  Future<void> initMaterials() async {
    final jsonStr = await rootBundle.loadString(Assets.materialsDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _materialsFile = MaterialsFile.fromJson(json);
  }

  @override
  Future<void> initElements() async {
    final jsonStr = await rootBundle.loadString(Assets.elementsDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _elementsFile = ElementsFile.fromJson(json);
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
        final multiTalentAscentionMaterials =
            e.multiTalentAscentionMaterials ?? <CharacterFileMultiTalentAscentionMaterialModel>[];

        final ascentionMaterial = e.ascentionMaterials.isNotEmpty
            ? e.ascentionMaterials.reduce((current, next) => current.level > next.level ? current : next)
            : null;

        final talentMaterial = e.talentAscentionMaterials.isNotEmpty
            ? e.talentAscentionMaterials.reduce((current, next) => current.level > next.level ? current : next)
            : multiTalentAscentionMaterials.isNotEmpty
                ? multiTalentAscentionMaterials
                    .expand((e) => e.materials)
                    .reduce((current, next) => current.level > next.level ? current : next)
                : null;

        final materials = (ascentionMaterial?.materials ?? <ItemAscentionMaterialModel>[]) +
            (talentMaterial?.materials ?? <ItemAscentionMaterialModel>[]);

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
  CharacterFileModel getCharacterByImg(String img) {
    return _charactersFile.characters.firstWhere((element) => Assets.getCharacterPath(element.image) == img);
  }

  @override
  TranslationCharacterFile getCharacterTranslation(String name) {
    return _translationFile.characters.firstWhere((element) => element.key == name);
  }

  @override
  List<WeaponCardModel> getWeaponsForCard() {
    return _weaponsFile.weapons.map(
      (e) {
        final translation = getWeaponTranslation(e.name);
        return WeaponCardModel(
          baseAtk: e.atk,
          image: e.fullImagePath,
          name: translation.name,
          rarity: e.rarity,
          type: e.type,
          subStatType: e.secondaryStat,
          subStatValue: e.secondaryStatValue,
        );
      },
    ).toList();
  }

  @override
  WeaponCardModel getWeaponForCardByImg(String image) {
    final weapon = _weaponsFile.weapons.firstWhere((e) => e.image == image);
    final translation = getWeaponTranslation(weapon.name);
    return WeaponCardModel(
      baseAtk: weapon.atk,
      image: weapon.fullImagePath,
      name: translation.name,
      rarity: weapon.rarity,
      type: weapon.type,
      subStatType: weapon.secondaryStat,
      subStatValue: weapon.secondaryStatValue,
    );
  }

  @override
  WeaponFileModel getWeapon(String name) {
    return _weaponsFile.weapons.firstWhere((element) => element.name == name);
  }

  @override
  WeaponFileModel getWeaponByImg(String img) {
    return _weaponsFile.weapons.firstWhere((element) => Assets.getWeaponPath(element.image, element.type) == img);
  }

  @override
  TranslationWeaponFile getWeaponTranslation(String name) {
    return _translationFile.weapons.firstWhere((element) => element.key == name);
  }

  @override
  List<ArtifactCardModel> getArtifactsForCard() {
    return _artifactsFile.artifacts.map(
      (e) {
        final translation = _translationFile.artifacts.firstWhere((t) => t.key == e.name);
        return ArtifactCardModel(
          key: e.name,
          name: translation.name,
          image: e.fullImagePath,
          rarity: e.rarityMax,
          bonus: translation.bonus,
        );
      },
    ).toList();
  }

  @override
  ArtifactCardModel getArtifactForCardByImg(String image) {
    final artifact = _artifactsFile.artifacts.firstWhere((a) => a.image == image);
    final translation = _translationFile.artifacts.firstWhere((t) => t.key == artifact.name);
    return ArtifactCardModel(
      key: artifact.name,
      name: translation.name,
      image: artifact.fullImagePath,
      rarity: artifact.rarityMax,
      bonus: translation.bonus,
    );
  }

  @override
  ArtifactFileModel getArtifact(String name) {
    return _artifactsFile.artifacts.firstWhere((a) => a.name == name);
  }

  @override
  TranslationArtifactFile getArtifactTranslation(String name) {
    return _translationFile.artifacts.firstWhere((t) => t.key == name);
  }

  @override
  List<TodayCharAscentionMaterialsModel> getCharacterAscentionMaterials(int day) {
    final iterable = day == DateTime.sunday
        ? _materialsFile.talents.where((t) => t.days.isNotEmpty)
        : _materialsFile.talents.where((t) => t.days.contains(day));

    return iterable.map((e) {
      final translation = _translationFile.materials.firstWhere((t) => t.key == e.name);
      final characters = <String>[];

      for (final char in _charactersFile.characters) {
        if (char.isComingSoon) continue;
        final normalAscMaterial =
            char.ascentionMaterials.expand((m) => m.materials).where((m) => m.image == e.image).isNotEmpty ||
                char.talentAscentionMaterials.expand((m) => m.materials).where((m) => m.image == e.image).isNotEmpty;

        //The travelers have different ascention materials, that's why we do the following
        var specialAscMaterial = false;
        if (char.multiTalentAscentionMaterials != null) {
          final keyword = e.image.split('_').last;
          final materials = char.multiTalentAscentionMaterials
              .expand((m) => m.materials)
              .expand((m) => m.materials)
              .where((m) => m.materialType == MaterialType.talents)
              .map((e) => e.image.split('_').last)
              .toSet()
              .toList();

          specialAscMaterial = materials.any((m) => m == keyword);
        }

        final materialIsBeingUsed = normalAscMaterial || specialAscMaterial;
        final charImg = Assets.getCharacterPath(char.image);
        if (materialIsBeingUsed && !characters.contains(charImg)) {
          characters.add(charImg);
        }
      }

      return e.isFromBoss
          ? TodayCharAscentionMaterialsModel.fromBoss(
              name: translation.name,
              image: Assets.getMaterialPath(e.image, e.type),
              bossName: translation.bossName,
              characters: characters,
            )
          : TodayCharAscentionMaterialsModel.fromDays(
              name: translation.name,
              image: Assets.getMaterialPath(e.image, e.type),
              characters: characters,
              days: e.days,
            );
    }).toList();
  }

  @override
  List<TodayWeaponAscentionMaterialModel> getWeaponAscentionMaterials(int day) {
    final iterable = day == DateTime.sunday
        ? _materialsFile.weaponPrimary
        : _materialsFile.weaponPrimary.where((t) => t.days.contains(day));

    return iterable.map((e) {
      final translation = _translationFile.materials.firstWhere((t) => t.key == e.name);

      final weapons = <String>[];
      for (final weapon in _weaponsFile.weapons) {
        final materialIsBeingUsed =
            weapon.ascentionMaterials.expand((m) => m.materials).where((m) => m.image == e.image).isNotEmpty;
        if (materialIsBeingUsed) {
          weapons.add(weapon.fullImagePath);
        }
      }
      return TodayWeaponAscentionMaterialModel(
        days: e.days,
        name: translation.name,
        image: Assets.getMaterialPath(e.image, e.type),
        weapons: weapons,
      );
    }).toList();
  }

  @override
  List<ElementCardModel> getElementDebuffs() {
    return _elementsFile.debuffs.map(
      (e) {
        final translation = _translationFile.debuffs.firstWhere((t) => t.key == e.name);
        final reaction = ElementCardModel(name: translation.name, effect: translation.effect, image: e.fullImagePath);
        return reaction;
      },
    ).toList();
  }

  @override
  List<ElementReactionCardModel> getElementReactions() {
    return _elementsFile.reactions.map(
      (e) {
        final translation = _translationFile.reactions.firstWhere((t) => t.key == e.name);
        final reaction = ElementReactionCardModel.withImages(
          name: translation.name,
          effect: translation.effect,
          principal: e.principalImages,
          secondary: e.secondaryImages,
        );
        return reaction;
      },
    ).toList();
  }

  @override
  List<ElementReactionCardModel> getElementResonances() {
    return _elementsFile.resonance.map(
      (e) {
        final translation = _translationFile.resonance.firstWhere((t) => t.key == e.name);
        final reaction = e.hasImages
            ? ElementReactionCardModel.withImages(
                name: translation.name,
                effect: translation.effect,
                principal: e.principalImages,
                secondary: e.secondaryImages,
              )
            : ElementReactionCardModel.withoutImages(
                name: translation.name,
                effect: translation.effect,
                description: translation.description,
              );
        return reaction;
      },
    ).toList();
  }
}
