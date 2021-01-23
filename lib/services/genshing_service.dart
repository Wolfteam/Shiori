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
  CharacterFileModel getCharacter(String key);
  CharacterFileModel getCharacterByImg(String img);

  List<WeaponCardModel> getWeaponsForCard();
  WeaponCardModel getWeaponForCardByImg(String image);
  WeaponFileModel getWeapon(String key);
  WeaponFileModel getWeaponByImg(String img);
  List<String> getCharactersImgUsingWeapon(String key);

  List<ArtifactCardModel> getArtifactsForCard();
  ArtifactCardModel getArtifactForCardByImg(String image);
  ArtifactFileModel getArtifact(String key);
  List<String> getCharactersImgUsingArtifact(String key);

  TranslationArtifactFile getArtifactTranslation(String key);
  TranslationCharacterFile getCharacterTranslation(String key);
  TranslationWeaponFile getWeaponTranslation(String key);

  List<TodayCharAscentionMaterialsModel> getCharacterAscensionMaterials(int day);
  List<TodayWeaponAscentionMaterialModel> getWeaponAscensionMaterials(int day);

  List<ElementCardModel> getElementDebuffs();
  List<ElementReactionCardModel> getElementReactions();
  List<ElementReactionCardModel> getElementResonances();

  MaterialFileModel getMaterialByImage(String image);
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
        final translation = getCharacterTranslation(e.key);
        return CharacterCardModel(
          key: e.key,
          elementType: e.elementType,
          logoName: Assets.getCharacterPath(e.image),
          materials: quickMaterials.map((m) => m.fullImagePath).toList(),
          name: translation.name,
          stars: e.rarity,
          weaponType: e.weaponType,
          isComingSoon: e.isComingSoon,
          isNew: e.isNew,
        );
      },
    ).toList();
  }

  @override
  CharacterFileModel getCharacter(String key) {
    return _charactersFile.characters.firstWhere((element) => element.key == key);
  }

  @override
  CharacterFileModel getCharacterByImg(String img) {
    return _charactersFile.characters.firstWhere((element) => Assets.getCharacterPath(element.image) == img);
  }

  @override
  List<WeaponCardModel> getWeaponsForCard() {
    return _weaponsFile.weapons.map(
      (e) {
        final translation = getWeaponTranslation(e.key);
        return WeaponCardModel(
          key: e.key,
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
    final translation = getWeaponTranslation(weapon.key);
    return WeaponCardModel(
      key: weapon.key,
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
  WeaponFileModel getWeapon(String key) {
    return _weaponsFile.weapons.firstWhere((element) => element.key == key);
  }

  @override
  WeaponFileModel getWeaponByImg(String img) {
    return _weaponsFile.weapons.firstWhere((element) => Assets.getWeaponPath(element.image, element.type) == img);
  }

  @override
  List<String> getCharactersImgUsingWeapon(String key) {
    final weapon = getWeapon(key);
    final imgs = <String>[];
    for (final char in _charactersFile.characters) {
      for (final build in char.builds) {
        final isBeingUsed = build.weaponImages.contains(weapon.image);
        final img = Assets.getCharacterPath(char.image);
        if (isBeingUsed && !imgs.contains(img)) {
          imgs.add(img);
        }
      }
    }

    return imgs;
  }

  @override
  List<ArtifactCardModel> getArtifactsForCard() {
    return _artifactsFile.artifacts.map(
      (e) {
        final translation = _translationFile.artifacts.firstWhere((t) => t.key == e.key);
        return ArtifactCardModel(
          key: e.key,
          name: translation.name,
          image: e.fullImagePath,
          rarity: e.rarityMax,
          bonus: translation.bonus.map((t) {
            final pieces = e.bonus.firstWhere((b) => b.key == t.key).pieces;
            return ArtifactCardBonusModel(pieces: pieces, bonus: t.bonus);
          }).toList(),
        );
      },
    ).toList();
  }

  @override
  ArtifactCardModel getArtifactForCardByImg(String image) {
    final artifact = _artifactsFile.artifacts.firstWhere((a) => a.image == image);
    final translation = _translationFile.artifacts.firstWhere((t) => t.key == artifact.key);
    return ArtifactCardModel(
      key: artifact.key,
      name: translation.name,
      image: artifact.fullImagePath,
      rarity: artifact.rarityMax,
      bonus: translation.bonus.map((t) {
        final pieces = artifact.bonus.firstWhere((b) => b.key == t.key).pieces;
        return ArtifactCardBonusModel(pieces: pieces, bonus: t.bonus);
      }).toList(),
    );
  }

  @override
  ArtifactFileModel getArtifact(String key) {
    return _artifactsFile.artifacts.firstWhere((a) => a.key == key);
  }

  @override
  List<String> getCharactersImgUsingArtifact(String key) {
    final artifact = getArtifact(key);
    final imgs = <String>[];
    for (final char in _charactersFile.characters) {
      for (final build in char.builds) {
        final isBeingUsed =
            build.artifacts.any((a) => a.one == artifact.image || a.multiples.any((m) => m.image == artifact.image));

        final img = Assets.getCharacterPath(char.image);
        if (isBeingUsed && !imgs.contains(img)) {
          imgs.add(img);
        }
      }
    }

    return imgs;
  }

  @override
  TranslationCharacterFile getCharacterTranslation(String key) {
    return _translationFile.characters.firstWhere((element) => element.key == key);
  }

  @override
  TranslationWeaponFile getWeaponTranslation(String key) {
    return _translationFile.weapons.firstWhere((element) => element.key == key);
  }

  @override
  TranslationArtifactFile getArtifactTranslation(String key) {
    return _translationFile.artifacts.firstWhere((t) => t.key == key);
  }

  @override
  List<TodayCharAscentionMaterialsModel> getCharacterAscensionMaterials(int day) {
    final iterable = day == DateTime.sunday
        ? _materialsFile.talents.where((t) => t.days.isNotEmpty && t.level == 0)
        : _materialsFile.talents.where((t) => t.days.contains(day) && t.level == 0);

    return iterable.map((e) {
      final translation = _translationFile.materials.firstWhere((t) => t.key == e.key);
      final characters = <String>[];

      for (final char in _charactersFile.characters) {
        if (char.isComingSoon) continue;
        final normalAscMaterial =
            char.ascentionMaterials.expand((m) => m.materials).where((m) => m.image == e.image).isNotEmpty ||
                char.talentAscentionMaterials.expand((m) => m.materials).where((m) => m.image == e.image).isNotEmpty;

        //The travelers have different ascension materials, that's why we do the following
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
  List<TodayWeaponAscentionMaterialModel> getWeaponAscensionMaterials(int day) {
    final iterable = day == DateTime.sunday
        ? _materialsFile.weaponPrimary.where((t) => t.level == 0)
        : _materialsFile.weaponPrimary.where((t) => t.days.contains(day) && t.level == 0);

    return iterable.map((e) {
      final translation = _translationFile.materials.firstWhere((t) => t.key == e.key);

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
        final translation = _translationFile.debuffs.firstWhere((t) => t.key == e.key);
        final reaction = ElementCardModel(name: translation.name, effect: translation.effect, image: e.fullImagePath);
        return reaction;
      },
    ).toList();
  }

  @override
  List<ElementReactionCardModel> getElementReactions() {
    return _elementsFile.reactions.map(
      (e) {
        final translation = _translationFile.reactions.firstWhere((t) => t.key == e.key);
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
        final translation = _translationFile.resonance.firstWhere((t) => t.key == e.key);
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

  @override
  MaterialFileModel getMaterialByImage(String image) {
    return _materialsFile.materials.firstWhere((m) => m.fullImagePath == image);
  }
}
