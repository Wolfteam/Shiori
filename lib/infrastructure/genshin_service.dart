import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/domain/services/genshin_service.dart';
import 'package:genshindb/domain/services/locale_service.dart';

class GenshinServiceImpl implements GenshinService {
  final LocaleService _localeService;

  CharactersFile _charactersFile;
  WeaponsFile _weaponsFile;
  TranslationFile _translationFile;
  ArtifactsFile _artifactsFile;
  MaterialsFile _materialsFile;
  ElementsFile _elementsFile;
  GameCodesFile _gameCodesFile;
  MonstersFile _monstersFile;

  GenshinServiceImpl(this._localeService);

  @override
  Future<void> init(AppLanguageType languageType) async {
    await Future.wait([
      initCharacters(),
      initWeapons(),
      initArtifacts(),
      initMaterials(),
      initElements(),
      initGameCodes(),
      initMonsters(),
      initTranslations(languageType),
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
  Future<void> initGameCodes() async {
    final jsonStr = await rootBundle.loadString(Assets.gameCodesDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _gameCodesFile = GameCodesFile.fromJson(json);
  }

  @override
  Future<void> initMonsters() async {
    final jsonStr = await rootBundle.loadString(Assets.monstersDbPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    _monstersFile = MonstersFile.fromJson(json);
  }

  @override
  Future<void> initTranslations(AppLanguageType languageType) async {
    final transJsonStr = await rootBundle.loadString(Assets.getTranslationPath(languageType));
    final transJson = jsonDecode(transJsonStr) as Map<String, dynamic>;
    _translationFile = TranslationFile.fromJson(transJson);
  }

  @override
  List<CharacterCardModel> getCharactersForCard() {
    return _charactersFile.characters.map((e) => _toCharacterForCard(e)).toList();
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
  List<CharacterFileModel> getCharactersForBirthday(DateTime date) {
    return _charactersFile.characters.where((char) {
      if (char.birthday.isNullEmptyOrWhitespace) {
        return false;
      }

      final charBirthday = _localeService.getCharBirthDate(char.birthday);
      return charBirthday.day == date.day && charBirthday.month == date.month;
    }).toList();
  }

  @override
  List<TierListRowModel> getDefaultCharacterTierList(List<int> colors) {
    assert(colors.length == 5);

    final sTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 's')
        .map((char) => Assets.getCharacterPath(char.image))
        .toList();
    final aTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 'a')
        .map((char) => Assets.getCharacterPath(char.image))
        .toList();
    final bTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 'b')
        .map((char) => Assets.getCharacterPath(char.image))
        .toList();
    final cTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 'c')
        .map((char) => Assets.getCharacterPath(char.image))
        .toList();
    final dTier = _charactersFile.characters
        .where((char) => !char.isComingSoon && char.tier == 'd')
        .map((char) => Assets.getCharacterPath(char.image))
        .toList();

    return <TierListRowModel>[
      TierListRowModel.row(tierText: 'S', tierColor: colors.first, charImgs: sTier),
      TierListRowModel.row(tierText: 'A', tierColor: colors[1], charImgs: aTier),
      TierListRowModel.row(tierText: 'B', tierColor: colors[2], charImgs: bTier),
      TierListRowModel.row(tierText: 'C', tierColor: colors[3], charImgs: cTier),
      TierListRowModel.row(tierText: 'D', tierColor: colors.last, charImgs: dTier),
    ];
  }

  @override
  List<WeaponCardModel> getWeaponsForCard() {
    return _weaponsFile.weapons.map((e) => _toWeaponForCard(e)).toList();
  }

  @override
  WeaponCardModel getWeaponForCardByImg(String image) {
    final weapon = _weaponsFile.weapons.firstWhere((e) => e.image == image);
    return _toWeaponForCard(weapon);
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
  List<String> getCharacterImgsUsingWeapon(String key) {
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
    return _artifactsFile.artifacts.map((e) => _toArtifactForCard(e)).toList();
  }

  @override
  ArtifactCardModel getArtifactForCardByImg(String image) {
    final artifact = _artifactsFile.artifacts.firstWhere((a) => a.image == image);
    return _toArtifactForCard(artifact);
  }

  @override
  ArtifactFileModel getArtifact(String key) {
    return _artifactsFile.artifacts.firstWhere((a) => a.key == key);
  }

  @override
  List<String> getCharacterImgsUsingArtifact(String key) {
    final artifact = getArtifact(key);
    final imgs = <String>[];
    for (final char in _charactersFile.characters) {
      for (final build in char.builds) {
        final isBeingUsed = build.artifacts.any((a) => a.one == artifact.image || a.multiples.any((m) => m.image == artifact.image));

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
  TranslationMaterialFile getMaterialTranslation(String key) {
    return _translationFile.materials.firstWhere((t) => t.key == key);
  }

  @override
  List<TodayCharAscensionMaterialsModel> getCharacterAscensionMaterials(int day) {
    final iterable = day == DateTime.sunday
        ? _materialsFile.talents.where((t) => t.days.isNotEmpty && t.level == 0)
        : _materialsFile.talents.where((t) => t.days.contains(day) && t.level == 0);

    return iterable.map((e) {
      final translation = _translationFile.materials.firstWhere((t) => t.key == e.key);
      final characters = <String>[];

      for (final char in _charactersFile.characters) {
        if (char.isComingSoon) continue;
        final normalAscMaterial = char.ascensionMaterials.expand((m) => m.materials).where((m) => m.image == e.image).isNotEmpty ||
            char.talentAscensionMaterials.expand((m) => m.materials).where((m) => m.image == e.image).isNotEmpty;

        //The travelers have different ascension materials, that's why we do the following
        var specialAscMaterial = false;
        if (char.multiTalentAscensionMaterials != null) {
          final keyword = e.image.split('_').last;
          final materials = char.multiTalentAscensionMaterials
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
          ? TodayCharAscensionMaterialsModel.fromBoss(
              name: translation.name,
              image: Assets.getMaterialPath(e.image, e.type),
              bossName: translation.bossName,
              characters: characters,
            )
          : TodayCharAscensionMaterialsModel.fromDays(
              name: translation.name,
              image: Assets.getMaterialPath(e.image, e.type),
              characters: characters,
              days: e.days,
            );
    }).toList();
  }

  @override
  List<TodayWeaponAscensionMaterialModel> getWeaponAscensionMaterials(int day) {
    final iterable = day == DateTime.sunday
        ? _materialsFile.weaponPrimary.where((t) => t.level == 0)
        : _materialsFile.weaponPrimary.where((t) => t.days.contains(day) && t.level == 0);

    return iterable.map((e) {
      final translation = _translationFile.materials.firstWhere((t) => t.key == e.key);

      final weapons = <String>[];
      for (final weapon in _weaponsFile.weapons) {
        final materialIsBeingUsed = weapon.ascensionMaterials.expand((m) => m.materials).where((m) => m.image == e.image).isNotEmpty;
        if (materialIsBeingUsed) {
          weapons.add(weapon.fullImagePath);
        }
      }
      return TodayWeaponAscensionMaterialModel(
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
  List<MaterialCardModel> getAllMaterialsForCard() {
    return _materialsFile.materials.map((e) => _toMaterialForCard(e)).toList();
  }

  @override
  MaterialFileModel getMaterial(String key) {
    return _materialsFile.materials.firstWhere((m) => m.key == key);
  }

  @override
  MaterialFileModel getMaterialByImage(String image) {
    return _materialsFile.materials.firstWhere((m) => m.fullImagePath == image);
  }

  @override
  List<MaterialFileModel> getMaterials(MaterialType type) {
    return _materialsFile.materials.where((m) => m.type == type).toList();
  }

  @override
  int getServerDay(AppServerResetTimeType type) {
    final now = DateTime.now();
    final nowUtc = now.toUtc();
    DateTime server;
    // According to this page, the server reset happens at 4 am
    // https://game8.co/games/Genshin-Impact/archives/301599
    const resetHour = 4;
    switch (type) {
      case AppServerResetTimeType.northAmerica:
        server = nowUtc.subtract(const Duration(hours: 5));
        break;
      case AppServerResetTimeType.europe:
        server = nowUtc.add(const Duration(hours: 1));
        break;
      case AppServerResetTimeType.asia:
        server = nowUtc.add(const Duration(hours: 8));
        break;
      default:
        throw Exception('Invalid server reset type');
    }

    if (server.hour >= resetHour) {
      return server.weekday;
    }

    if (server.weekday == DateTime.monday) {
      return DateTime.sunday;
    }

    return server.weekday - 1;
  }

  @override
  List<GameCodeFileModel> getAllGameCodes() => _gameCodesFile.gameCodes;

  @override
  List<String> getCharacterImgsUsingMaterial(String key) {
    final material = getMaterial(key);
    final imgs = <String>[];

    for (final char in _charactersFile.characters.where((c) => !c.isComingSoon)) {
      final multiTalentAscensionMaterials =
          (char.multiTalentAscensionMaterials?.expand((e) => e.materials)?.expand((e) => e.materials) ?? <ItemAscensionMaterialModel>[]).toList();

      final ascensionMaterial = char.ascensionMaterials.expand((e) => e.materials).toList();
      final talentMaterial = char.talentAscensionMaterials.expand((e) => e.materials).toList();

      final materials = multiTalentAscensionMaterials + ascensionMaterial + talentMaterial;
      final allMaterials = _getMaterialsToUse(materials);

      if (allMaterials.any((m) => m.fullImagePath == material.fullImagePath)) {
        imgs.add(Assets.getCharacterPath(char.image));
      }
    }

    return imgs;
  }

  @override
  List<String> getWeaponImgsUsingMaterial(String key) {
    final material = getMaterial(key);
    final imgs = <String>[];

    for (final weapon in _weaponsFile.weapons) {
      final materials = (weapon.craftingMaterials ?? <ItemAscensionMaterialModel>[]) + weapon.ascensionMaterials.expand((e) => e.materials).toList();
      final allMaterials = _getMaterialsToUse(materials);
      if (allMaterials.any((m) => m.fullImagePath == material.fullImagePath)) {
        imgs.add(weapon.fullImagePath);
      }
    }

    return imgs;
  }

  @override
  List<String> getRelatedMaterialImgsToMaterial(String key) {
    final material = getMaterial(key);
    return _materialsFile.materials
        .where((m) {
          final isUsed = m.obtainedFrom.expand((e) => e.items).where((e) => e.fullImagePath == material.fullImagePath).isNotEmpty;
          return m.key != key && isUsed;
        })
        .map((m) => m.fullImagePath)
        .toSet()
        .toList();
  }

  @override
  MaterialCardModel getMaterialForCard(String key) {
    final material = _materialsFile.materials.firstWhere((m) => m.key == key);
    return _toMaterialForCard(material);
  }

  @override
  CharacterCardModel getCharacterForCard(String key) {
    final character = _charactersFile.characters.firstWhere((el) => el.key == key);
    return _toCharacterForCard(character);
  }

  @override
  WeaponCardModel getWeaponForCard(String key) {
    final weapon = _weaponsFile.weapons.firstWhere((el) => el.key == key);
    return _toWeaponForCard(weapon);
  }

  @override
  List<String> getUpcomingCharactersKeys() => _charactersFile.characters.where((el) => el.isComingSoon).map((e) => e.key).toList();

  @override
  List<String> getUpcomingWeaponsKeys() => _weaponsFile.weapons.where((el) => el.isComingSoon).map((e) => e.key).toList();

  @override
  List<String> getUpcomingKeys() => getUpcomingCharactersKeys() + getUpcomingWeaponsKeys();

  @override
  MonsterFileModel getMonster(String key) {
    return _monstersFile.monsters.firstWhere((el) => el.key == key);
  }

  @override
  MonsterFileModel getMonsterByImg(String image) {
    return _monstersFile.monsters.firstWhere((el) => el.fullImagePath == image);
  }

  @override
  List<MonsterCardModel> getAllMonstersForCard() {
    return _monstersFile.monsters.map((e) => _toMonsterForCard(e)).toList();
  }

  @override
  MonsterCardModel getMonsterForCardByImg(String image) {
    final monster = _monstersFile.monsters.firstWhere((el) => el.fullImagePath == image);
    return _toMonsterForCard(monster);
  }

  List<ItemAscensionMaterialModel> _getMaterialsToUse(
    List<ItemAscensionMaterialModel> materials, {
    List<MaterialType> ignore = const [MaterialType.currency],
  }) {
    final mp = <String, ItemAscensionMaterialModel>{};
    for (final item in materials) {
      if (!ignore.contains(item.materialType)) {
        mp[item.image] = item;
      }
    }

    return mp.values.toList();
  }

  CharacterCardModel _toCharacterForCard(CharacterFileModel character) {
    final translation = getCharacterTranslation(character.key);

    //The reduce is to take the material with the biggest level of each type
    final multiTalentAscensionMaterials = character.multiTalentAscensionMaterials ?? <CharacterFileMultiTalentAscensionMaterialModel>[];

    final ascensionMaterial = character.ascensionMaterials.isNotEmpty
        ? character.ascensionMaterials.reduce((current, next) => current.level > next.level ? current : next)
        : null;

    final talentMaterial = character.talentAscensionMaterials.isNotEmpty
        ? character.talentAscensionMaterials.reduce((current, next) => current.level > next.level ? current : next)
        : multiTalentAscensionMaterials.isNotEmpty
            ? multiTalentAscensionMaterials.expand((e) => e.materials).reduce((current, next) => current.level > next.level ? current : next)
            : null;

    final materials =
        (ascensionMaterial?.materials ?? <ItemAscensionMaterialModel>[]) + (talentMaterial?.materials ?? <ItemAscensionMaterialModel>[]);

    final quickMaterials = _getMaterialsToUse(materials);

    return CharacterCardModel(
      key: character.key,
      elementType: character.elementType,
      logoName: Assets.getCharacterPath(character.image),
      materials: quickMaterials.map((m) => m.fullImagePath).toList(),
      name: translation.name,
      stars: character.rarity,
      weaponType: character.weaponType,
      isComingSoon: character.isComingSoon,
      isNew: character.isNew,
      roleType: character.role,
    );
  }

  WeaponCardModel _toWeaponForCard(WeaponFileModel weapon) {
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
      isComingSoon: weapon.isComingSoon,
      locationType: weapon.location,
    );
  }

  ArtifactCardModel _toArtifactForCard(ArtifactFileModel artifact) {
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

  MaterialCardModel _toMaterialForCard(MaterialFileModel material) {
    final translation = getMaterialTranslation(material.key);
    return MaterialCardModel.item(
      key: material.key,
      image: material.fullImagePath,
      rarity: material.rarity,
      type: material.type,
      name: translation.name,
      level: material.level,
      hasSiblings: material.hasSiblings,
    );
  }

  MonsterCardModel _toMonsterForCard(MonsterFileModel monster) {
    final translation = _translationFile.monsters.firstWhere((el) => el.key == monster.key);
    return MonsterCardModel(
      key: monster.key,
      image: monster.fullImagePath,
      name: translation.name,
      type: monster.type,
      isComingSoon: monster.isComingSoon,
    );
  }
}
