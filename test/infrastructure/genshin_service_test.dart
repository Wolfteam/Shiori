import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import 'genshin_service_test.mocks.dart';

@GenerateMocks([SettingsService])
void main() {
  final languages = AppLanguageType.values.toList();
  TestWidgetsFlutterBinding.ensureInitialized();

  LocaleService _getLocaleService(AppLanguageType language) {
    final settings = MockSettingsService();
    when(settings.language).thenReturn(language);
    final service = LocaleServiceImpl(settings);

    //for some reason in the tests I need to initialize this thing
    final locale = service.getFormattedLocale(language);
    initializeDateFormatting(locale);
    return service;
  }

  GenshinService _getService() {
    final localeService = _getLocaleService(AppLanguageType.english);
    final service = GenshinServiceImpl(localeService);
    return service;
  }

  void _checkKey(String value) {
    expect(value, allOf([isNotEmpty, isNotNull]));
    final lower = value.toLowerCase();
    expect(lower, equals(value));
  }

  void _checkKeys(List<String> keys) {
    expect(keys.toSet().length, equals(keys.length));
  }

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _checkAsset(String path) {
    expect(path, allOf([isNotEmpty, isNotNull]));
    expect(_assetExists(path), completion(equals(true)));
  }

  void _checkItemCommon(ItemCommon item) {
    _checkKey(item.key);
    _checkAsset(item.image);
  }

  void _checkItemAscensionMaterialFileModel(GenshinService service, List<ItemAscensionMaterialFileModel> all) {
    expect(all, isNotEmpty);
    for (final material in all) {
      _checkKey(material.key);
      expect(() => service.getMaterial(material.key), returnsNormally);
      expect(material.quantity, greaterThanOrEqualTo(0));
    }
  }

  void _checkCharacterFileAscensionMaterialModel(GenshinService service, List<CharacterFileAscensionMaterialModel> all) {
    expect(all, isNotEmpty);
    for (final ascMaterial in all) {
      expect(ascMaterial.rank, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(6)]));
      expect(ascMaterial.level, allOf([greaterThanOrEqualTo(20), lessThanOrEqualTo(80)]));
      _checkItemAscensionMaterialFileModel(service, ascMaterial.materials);
    }
  }

  void _checkCharacterFileTalentAscensionMaterialModel(GenshinService service, List<CharacterFileTalentAscensionMaterialModel> all) {
    expect(all, isNotEmpty);
    for (final ascMaterial in all) {
      expect(ascMaterial.level, inInclusiveRange(2, 10));
      _checkItemAscensionMaterialFileModel(service, ascMaterial.materials);
    }
  }

  test('Initialize all languages', () {
    final service = _getService();

    for (final lang in languages) {
      expect(service.init(lang), completes);
    }
  });

  group('Card items', () {
    test('check for characters', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final characters = service.getCharactersForCard();
        _checkKeys(characters.map((e) => e.key).toList());
        final materialImgs = service.getAllMaterialsForCard().map((e) => e.image).toList();
        for (final char in characters) {
          _checkKey(char.key);
          expect(char.name, allOf([isNotEmpty, isNotNull]));
          _checkAsset(char.image);
          expect(char.stars, allOf([greaterThanOrEqualTo(4), lessThanOrEqualTo(5)]));
          if (char.isNew || char.isComingSoon) {
            expect(char.isNew, isNot(char.isComingSoon));
          }

          if (!char.isComingSoon) {
            expect(char.materials, isNotEmpty);
            final expected = materialImgs.where((el) => char.materials.contains(el)).length;
            expect(char.materials.length, equals(expected));
          }
        }
      }
    });

    test('check for weapons', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final weapons = service.getWeaponsForCard();
        _checkKeys(weapons.map((e) => e.key).toList());
        for (final weapon in weapons) {
          _checkKey(weapon.key);
          _checkAsset(weapon.image);
          expect(weapon.name, allOf([isNotEmpty, isNotNull]));
          expect(weapon.rarity, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(5)]));
          expect(weapon.baseAtk, greaterThan(0));
          expect(weapon.subStatValue, greaterThanOrEqualTo(0));
        }
      }
    });

    test('check for artifacts', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final artifacts = service.getArtifactsForCard();
        _checkKeys(artifacts.map((e) => e.key).toList());
        for (final artifact in artifacts) {
          _checkKey(artifact.key);
          _checkAsset(artifact.image);
          expect(artifact.name, allOf([isNotEmpty, isNotNull]));
          expect(artifact.rarity, allOf([greaterThanOrEqualTo(3), lessThanOrEqualTo(5)]));
          expect(artifact.bonus, isNotEmpty);
          for (final bonus in artifact.bonus) {
            expect(bonus.bonus, allOf([isNotEmpty, isNotNull]));
            expect(bonus.pieces, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(2)]));
          }
        }
      }
    });

    test('check for materials', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final materials = service.getAllMaterialsForCard();
        _checkKeys(materials.map((e) => e.key).toList());
        for (final material in materials) {
          _checkKey(material.key);
          _checkAsset(material.image);
          expect(material.name, allOf([isNotEmpty, isNotNull]));
          expect(material.rarity, allOf([greaterThanOrEqualTo(1), lessThanOrEqualTo(5)]));
          expect(material.level, greaterThanOrEqualTo(0));
        }
      }
    });

    test('check for monsters', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final monsters = service.getAllMonstersForCard();
        _checkKeys(monsters.map((e) => e.key).toList());
        for (final monster in monsters) {
          _checkKey(monster.key);
          _checkAsset(monster.image);
          expect(monster.name, allOf([isNotEmpty, isNotNull]));
        }
      }
    });
  });

  group('Details', () {
    test('check for characters', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final localeService = _getLocaleService(AppLanguageType.english);
      final characters = service.getCharactersForCard();
      for (final character in characters) {
        final travelerKeys = ['traveler-geo', 'traveler-electro', 'traveler-anemo', 'traveler-hydro', 'traveler-pyro', 'traveler-cryo'];
        final detail = service.getCharacter(character.key);
        final isTraveler = travelerKeys.contains(character.key);
        _checkKey(detail.key);
        expect(detail.rarity, character.stars);
        expect(detail.weaponType, character.weaponType);
        expect(detail.elementType, character.elementType);
        _checkAsset(detail.fullImagePath);
        _checkAsset(detail.fullCharacterImagePath);
        expect(detail.region, character.regionType);
        expect(detail.role, character.roleType);
        expect(detail.isComingSoon, character.isComingSoon);
        expect(detail.isNew, character.isNew);
        expect(detail.tier, isIn(['NA', 'd', 'c', 'b', 'a', 's', 'ss', 'sss']));
        if (isTraveler) {
          _checkAsset(detail.fullSecondImagePath!);
        } else {
          expect(detail.birthday, allOf([isNotNull, isNotEmpty]));

          //eg: 09/14
          expect(detail.birthday!.length, equals(5));

          expect(() => localeService.getCharBirthDate(detail.birthday), returnsNormally);
        }

        if (!detail.isComingSoon && !isTraveler) {
          expect(detail.ascensionMaterials, isNotEmpty);
          expect(detail.talentAscensionMaterials, isNotEmpty);
        } else if (!detail.isComingSoon && isTraveler) {
          expect(detail.multiTalentAscensionMaterials, allOf([isNotEmpty, isNotNull]));
        }

        if (!detail.isComingSoon) {
          expect(detail.builds, isNotEmpty);
          expect(detail.skills, isNotEmpty);
          expect(detail.skills.length, inInclusiveRange(3, 4));
          expect(detail.passives, isNotEmpty);
          expect(detail.passives.length, inInclusiveRange(2, 4));
          expect(detail.constellations, isNotEmpty);
          expect(detail.constellations.length, 6);
          expect(detail.stats, isNotEmpty);
        }

        _checkCharacterFileAscensionMaterialModel(service, detail.ascensionMaterials);
        if (!isTraveler) {
          _checkCharacterFileTalentAscensionMaterialModel(service, detail.talentAscensionMaterials);
        } else {
          for (final ascMaterial in detail.multiTalentAscensionMaterials!) {
            expect(ascMaterial.number, inInclusiveRange(1, 3));
            _checkCharacterFileTalentAscensionMaterialModel(service, ascMaterial.materials);
          }
        }

        for (final build in detail.builds) {
          expect(build.weaponKeys, isNotEmpty);
          expect(build.subStatsToFocus.length, greaterThanOrEqualTo(3));
          for (final key in build.weaponKeys) {
            expect(() => service.getWeapon(key), returnsNormally);
          }

          for (final artifact in build.artifacts) {
            final valid = artifact.oneKey != null || artifact.multiples.isNotEmpty;
            expect(valid, isTrue);
            expect(artifact.stats.length, equals(5));
            expect(artifact.stats[0], equals(StatType.hp));
            expect(artifact.stats[1], equals(StatType.atk));
            if (artifact.oneKey != null) {
              expect(() => service.getArtifact(artifact.oneKey!), returnsNormally);
            } else {
              for (final partial in artifact.multiples) {
                expect(() => service.getArtifact(partial.key), returnsNormally);
                expect(partial.quantity, inInclusiveRange(1, 2));
              }
            }
          }
        }

        for (final skill in detail.skills) {
          _checkKey(skill.key);
          _checkAsset(skill.fullImagePath);
        }

        for (final passive in detail.passives) {
          _checkKey(passive.key);
          _checkAsset(passive.fullImagePath);
          expect(passive.unlockedAt, isIn([-1, 1, 4]));
        }

        for (final constellation in detail.constellations) {
          _checkKey(constellation.key);
          _checkAsset(constellation.fullImagePath);
          expect(constellation.number, inInclusiveRange(1, 6));
        }

        for (final stat in detail.stats) {
          expect(stat.level, inInclusiveRange(1, 90));
          expect(stat.baseAtk, greaterThan(0));
          expect(stat.baseHp, greaterThan(0));
          expect(stat.baseDef, greaterThan(0));
          expect(stat.statValue, greaterThan(0));
        }
      }
    });

    test('check for weapons', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final weapons = service.getWeaponsForCard();
      for (final weapon in weapons) {
        final detail = service.getWeapon(weapon.key);
        _checkKey(detail.key);
        _checkAsset(detail.fullImagePath);
        expect(detail.type, equals(weapon.type));
        expect(detail.atk, equals(weapon.baseAtk));
        expect(detail.rarity, equals(weapon.rarity));
        expect(detail.secondaryStat, equals(weapon.subStatType));
        expect(detail.secondaryStatValue, equals(weapon.subStatValue));
        expect(detail.location, equals(weapon.locationType));
        expect(detail.ascensionMaterials, isNotEmpty);
        expect(detail.stats, isNotEmpty);
        if (detail.rarity > 2) {
          expect(detail.refinements, isNotEmpty);
        } else {
          expect(detail.refinements, isEmpty);
        }

        if (detail.location == ItemLocationType.crafting) {
          expect(detail.craftingMaterials, isNotEmpty);
        } else {
          expect(detail.craftingMaterials, isEmpty);
        }

        for (final ascMaterial in detail.ascensionMaterials) {
          expect(ascMaterial.level, inInclusiveRange(20, 80));
          _checkItemAscensionMaterialFileModel(service, ascMaterial.materials);
        }

        for (final refinement in detail.refinements) {
          expect(refinement.level, inInclusiveRange(1, 5));
          if (detail.rarity >= 4 && detail.key != 'windblume-ode') {
            expect(refinement.values, isNotEmpty);
          }
        }

        for (final stat in detail.stats) {
          if (detail.rarity >= 3) {
            expect(stat.level, inInclusiveRange(1, 90));
          } else {
            expect(stat.level, inInclusiveRange(1, 70));
          }

          expect(stat.baseAtk, greaterThan(0));
          if (detail.rarity > 2) {
            expect(stat.statValue, greaterThan(0));
          } else {
            expect(stat.statValue, greaterThanOrEqualTo(0));
          }
        }
      }
    });

    test('check for artifacts', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final artifacts = service.getArtifactsForCard();
      for (final artifact in artifacts) {
        final detail = service.getArtifact(artifact.key);
        _checkKey(detail.key);
        _checkAsset(detail.fullImagePath);
        expect(detail.minRarity, inInclusiveRange(2, 4));
        expect(detail.maxRarity, inInclusiveRange(3, 5));
      }
    });

    test('check the materials', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final materials = service.getAllMaterialsForCard();
      for (final material in materials) {
        final detail = service.getMaterial(material.key);
        _checkKey(detail.key);
        _checkAsset(detail.fullImagePath);
        expect(detail.rarity, equals(material.rarity));
        expect(detail.type, equals(material.type));

        switch (detail.type) {
          case MaterialType.common:
            expect(detail.hasSiblings, isTrue);
            expect(detail.rarity, inInclusiveRange(1, 4));
            expect(detail.level, inInclusiveRange(0, 3));
            break;
          case MaterialType.elementalStone:
            expect(detail.rarity, equals(4));
            expect(detail.level, equals(0));
            break;
          case MaterialType.jewels:
            expect(detail.hasSiblings, isTrue);
            expect(detail.rarity, inInclusiveRange(2, 5));
            expect(detail.level, inInclusiveRange(0, 3));
            break;
          case MaterialType.local:
            expect(detail.attributes, allOf([isNotNull, isNotEmpty]));
            break;
          case MaterialType.talents:
            if (detail.rarity >= 5) {
              continue;
            }

            expect(detail.days, isNotEmpty);
            for (final day in detail.days) {
              expect(day, isIn([1, 2, 3, 4, 5, 6, 7]));
            }

            expect(detail.hasSiblings, isTrue);
            expect(detail.rarity, inInclusiveRange(2, 4));
            expect(detail.level, inInclusiveRange(0, 2));
            break;
          case MaterialType.weapon:
            expect(detail.hasSiblings, isTrue);
            expect(detail.rarity, inInclusiveRange(1, 4));
            expect(detail.level, inInclusiveRange(0, 3));
            break;
          case MaterialType.weaponPrimary:
            expect(detail.days, isNotEmpty);
            for (final day in detail.days) {
              expect(day, isIn([1, 2, 3, 4, 5, 6, 7]));
            }
            expect(detail.hasSiblings, isTrue);
            expect(detail.rarity, inInclusiveRange(2, 5));
            expect(detail.level, inInclusiveRange(0, 3));
            break;
          case MaterialType.currency:
            break;
          case MaterialType.others:
            break;
          case MaterialType.ingredient:
            break;
          case MaterialType.expWeapon:
          case MaterialType.expCharacter:
            expect(detail.attributes, allOf([isNotNull, isNotEmpty]));
            expect(detail.experienceAttributes, isNotNull);
            expect(detail.isAnExperienceMaterial, isTrue);
            break;
        }

        final partOfRecipes = detail.recipes + detail.obtainedFrom;

        for (final part in partOfRecipes) {
          _checkKey(part.createsMaterialKey);
          expect(() => service.getMaterial(part.createsMaterialKey), returnsNormally);
          for (final needs in part.needs) {
            expect(needs.quantity, greaterThanOrEqualTo(1));
            expect(() => service.getMaterial(needs.key), returnsNormally);
          }
        }
      }
    });

    test('check the monsters', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final monsters = service.getAllMonstersForCard();
      for (final monster in monsters) {
        final detail = service.getMonster(monster.key);
        _checkKey(detail.key);
        _checkAsset(detail.fullImagePath);

        for (final drop in detail.drops) {
          switch (drop.type) {
            case MonsterDropType.material:
              expect(() => service.getMaterial(drop.key), returnsNormally);
              break;
            case MonsterDropType.artifact:
              expect(() => service.getArtifact(drop.key), returnsNormally);
              break;
          }
        }
      }
    });
  });

  group('Translations', () {
    test('check for characters', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);

        final characters = service.getCharactersForCard();

        for (final character in characters) {
          final detail = service.getCharacter(character.key);
          final translation = service.getCharacterTranslation(character.key);
          _checkKey(translation.key);
          expect(translation.name, allOf([isNotNull, isNotEmpty]));
          expect(translation.description, allOf([isNotNull, isNotEmpty]));

          expect(translation.skills, isNotEmpty);
          expect(translation.skills.length, equals(detail.skills.length));
          expect(translation.passives, isNotEmpty);
          expect(translation.passives.length, equals(detail.passives.length));
          expect(translation.constellations, isNotEmpty);
          expect(translation.constellations.length, equals(detail.constellations.length));

          _checkKeys(translation.skills.map((e) => e.key).toList());
          _checkKeys(translation.passives.map((e) => e.key).toList());
          _checkKeys(translation.constellations.map((e) => e.key).toList());

          for (final skill in translation.skills) {
            _checkKey(skill.key);
            expect(skill.key, isIn(detail.skills.map((e) => e.key).toList()));
            expect(skill.title, allOf([isNotNull, isNotEmpty]));
            for (final ability in skill.abilities) {
              final oneAtLeast = ability.name.isNotNullEmptyOrWhitespace ||
                  ability.description.isNotNullEmptyOrWhitespace ||
                  ability.secondDescription.isNotNullEmptyOrWhitespace;

              if (!oneAtLeast) {
                expect(ability.descriptions, isNotEmpty);
              }
            }
          }

          for (final passive in translation.passives) {
            _checkKey(passive.key);
            expect(passive.key, isIn(detail.passives.map((e) => e.key).toList()));
            expect(passive.title, allOf([isNotNull, isNotEmpty]));
          }

          for (final constellation in translation.constellations) {
            _checkKey(constellation.key);
            expect(constellation.key, isIn(detail.constellations.map((e) => e.key).toList()));
            expect(constellation.title, allOf([isNotNull, isNotEmpty]));
            expect(constellation.description, allOf([isNotNull, isNotEmpty]));
          }
        }
      }
    });

    test('check for weapons', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final weapons = service.getWeaponsForCard();
        for (final weapon in weapons) {
          final detail = service.getWeapon(weapon.key);
          final translation = service.getWeaponTranslation(weapon.key);
          _checkKey(translation.key);
          expect(translation.name, allOf([isNotNull, isNotEmpty]));
          expect(translation.description, allOf([isNotNull, isNotEmpty]));
          if (detail.rarity > 2) {
            expect(translation.refinement, allOf([isNotNull, isNotEmpty]));
          }
        }
      }
    });

    test('check for artifacts', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final artifacts = service.getArtifactsForCard();
        for (final artifact in artifacts) {
          final detail = service.getArtifact(artifact.key);
          final translation = service.getArtifactTranslation(detail.key);
          _checkKey(translation.key);
          expect(translation.name, allOf([isNotNull, isNotEmpty]));
          expect(translation.bonus.length, inInclusiveRange(1, 2));
        }
      }
    });

    test('check the materials', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final materials = service.getAllMaterialsForCard();
        for (final material in materials) {
          final detail = service.getMaterial(material.key);
          final translation = service.getMaterialTranslation(detail.key);
          _checkKey(translation.key);
          expect(translation.name, allOf([isNotNull, isNotEmpty]));
          expect(translation.description, allOf([isNotNull, isNotEmpty]));
        }
      }
    });

    test('check the monsters', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final monsters = service.getAllMonstersForCard();
        for (final monster in monsters) {
          final translation = service.getMonsterTranslation(monster.key);
          _checkKey(translation.key);
          expect(translation.name, allOf([isNotNull, isNotEmpty]));
        }
      }
    });
  });

  group('Birthdays', () {
    test("check Keqing's birthday", () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final date = DateTime(2021, 11, 20);
      final chars = service.getCharactersForBirthday(date);
      expect(chars, isNotEmpty);
      expect(chars.first.key, equals('keqing'));
    });

    test("check Bennet's birthday", () {
      for (final lang in languages.where((el) => el != AppLanguageType.french)) {
        final service = _getLocaleService(lang);
        final birthday = service.getCharBirthDate('02/29');
        expect(birthday.day, equals(29));
        expect(birthday.month, equals(2));
      }
    });
  });

  group('Elements', () {
    test('check debuffs', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final debuffs = service.getElementDebuffs();
        expect(debuffs.length, equals(4));
        for (final debuff in debuffs) {
          expect(debuff.name, allOf([isNotNull, isNotEmpty]));
          expect(debuff.effect, allOf([isNotNull, isNotEmpty]));
          _checkAsset(debuff.image);
        }
      }
    });

    test('check resonances', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final reactions = service.getElementReactions();
        expect(reactions.length, equals(9));
        for (final reaction in reactions) {
          expect(reaction.name, allOf([isNotNull, isNotEmpty]));
          expect(reaction.effect, allOf([isNotNull, isNotEmpty]));
          expect(reaction.principal, isNotEmpty);
          expect(reaction.secondary, isNotEmpty);

          final imgs = reaction.principal + reaction.secondary;
          for (final img in imgs) {
            _checkAsset(img);
          }
        }
      }
    });

    test('check resonances', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final resonances = service.getElementResonances();
        expect(resonances.length, equals(7));
        for (final resonance in resonances) {
          expect(resonance.name, allOf([isNotNull, isNotEmpty]));
          expect(resonance.effect, allOf([isNotNull, isNotEmpty]));

          final imgs = resonance.principal + resonance.secondary;
          for (final img in imgs) {
            _checkAsset(img);
          }
        }
      }
    });
  });

  group('TierList', () {
    test('check the default one', () async {
      final List<int> defaultColors = [
        0xfff44336,
        0xfff56c62,
        0xffff7d06,
        0xffff9800,
        0xffffc107,
        0xffffeb3b,
        0xff8bc34a,
      ];

      final service = _getService();
      await service.init(AppLanguageType.english);
      final tierList = service.getDefaultCharacterTierList(defaultColors);
      expect(tierList.length, equals(7));

      for (var i = 0; i < defaultColors.length; i++) {
        final tierRow = tierList[i];
        expect(tierRow.tierText, allOf([isNotNull, isNotEmpty]));
        expect(tierRow.items, isNotEmpty);
        expect(tierRow.tierColor, equals(defaultColors[i]));

        for (final item in tierRow.items) {
          _checkKey(item.key);
          _checkAsset(item.image);
        }
      }
    });
  });

  group("Today's materials", () {
    test('check for characters', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final days = [
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      ];

      for (final day in days) {
        final materials = service.getCharacterAscensionMaterials(day);
        expect(materials, isNotEmpty);
        for (final material in materials) {
          _checkKey(material.key);
          _checkAsset(material.image);
          expect(material.name, allOf([isNotNull, isNotEmpty]));
          expect(material.characters, isNotEmpty);
          expect(material.days, isNotEmpty);
          for (final item in material.characters) {
            _checkItemCommon(item);
          }
        }

        if (day == DateTime.sunday) {
          final allCharacters = service.getCharactersForCard();
          final notComingSoon = allCharacters.where((el) => !el.isComingSoon).length;
          final got = materials.expand((el) => el.characters).map((e) => e.key).toSet().length;
          expect(notComingSoon, equals(got));
        }
      }
    });
  });
}
