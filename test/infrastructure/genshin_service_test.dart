import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/utils/date_utils.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../common.dart';
import '../mocks.mocks.dart';

//TODO: ADD TEST FOR FAIL CASES (E.G WEAPON NOT FOUND, IMAGE NOT FOUND ETC)

void main() {
  final languages = AppLanguageType.values.toList();
  TestWidgetsFlutterBinding.ensureInitialized();

  LocaleService _getLocaleService(AppLanguageType language) {
    final settings = MockSettingsService();
    when(settings.language).thenReturn(language);
    final service = LocaleServiceImpl(settings);

    manuallyInitLocale(service, language);
    return service;
  }

  GenshinService _getService() {
    final localeService = _getLocaleService(AppLanguageType.english);
    final service = GenshinServiceImpl(localeService);
    return service;
  }

  test('Initialize all languages', () async {
    final service = _getService();

    for (final lang in languages) {
      await expectLater(service.init(lang), completes);
    }
  });

  group('Card items', () {
    test('check for characters', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final characters = service.characters.getCharactersForCard();
        checkKeys(characters.map((e) => e.key).toList());
        final materialImgs = service.materials.getAllMaterialsForCard().map((e) => e.image).toList();
        for (final char in characters) {
          checkKey(char.key);
          expect(char.name, allOf([isNotEmpty, isNotNull]));
          checkAsset(char.image);
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
        final weapons = service.weapons.getWeaponsForCard();
        checkKeys(weapons.map((e) => e.key).toList());
        for (final weapon in weapons) {
          checkKey(weapon.key);
          checkAsset(weapon.image);
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
        final artifacts = service.artifacts.getArtifactsForCard();
        checkKeys(artifacts.map((e) => e.key).toList());
        for (final artifact in artifacts) {
          checkKey(artifact.key);
          checkAsset(artifact.image);
          expect(artifact.name, allOf([isNotEmpty, isNotNull]));
          expect(artifact.rarity, allOf([greaterThanOrEqualTo(3), lessThanOrEqualTo(5)]));
          expect(artifact.bonus, isNotEmpty);
          for (final bonus in artifact.bonus) {
            expect(bonus.bonus, allOf([isNotEmpty, isNotNull]));
            if (artifact.bonus.length == 2) {
              expect(bonus.pieces, isIn([2, 4]));
            } else {
              expect(bonus.pieces == 1, isTrue);
            }
          }
        }
      }
    });

    test('check for materials', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final materials = service.materials.getAllMaterialsForCard();
        checkKeys(materials.map((e) => e.key).toList());
        for (final material in materials) {
          checkKey(material.key);
          checkAsset(material.image);
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
        final monsters = service.monsters.getAllMonstersForCard();
        checkKeys(monsters.map((e) => e.key).toList());
        for (final monster in monsters) {
          checkKey(monster.key);
          checkAsset(monster.image);
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
      final characters = service.characters.getCharactersForCard();
      for (final character in characters) {
        final travelerKeys = [
          'traveler-geo',
          'traveler-electro',
          'traveler-anemo',
          'traveler-hydro',
          'traveler-pyro',
          'traveler-cryo',
          'traveler-dendro',
        ];
        final detail = service.characters.getCharacter(character.key);
        final isTraveler = travelerKeys.contains(character.key);
        checkKey(detail.key);
        expect(detail.rarity, character.stars);
        expect(detail.weaponType, character.weaponType);
        expect(detail.elementType, character.elementType);
        checkAsset(detail.fullImagePath);
        checkAsset(detail.fullCharacterImagePath);
        expect(detail.region, character.regionType);
        expect(detail.role, character.roleType);
        expect(detail.isComingSoon, character.isComingSoon);
        expect(detail.isNew, character.isNew);
        if (detail.isComingSoon) {
          expect(detail.tier, 'na');
        } else {
          expect(detail.tier, isIn(['d', 'c', 'b', 'a', 's', 'ss', 'sss']));
        }

        if (isTraveler) {
          checkAsset(detail.fullSecondImagePath!);
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
          expect(detail.builds.any((el) => el.isRecommended), isTrue);
          for (final build in detail.builds) {
            expect(build.skillPriorities.length, inInclusiveRange(1, 3));
            expect(build.skillPriorities, isNotEmpty);
            for (final priority in build.skillPriorities) {
              expect(priority, isIn([CharacterSkillType.normalAttack, CharacterSkillType.elementalBurst, CharacterSkillType.elementalSkill]));
            }
          }

          expect(detail.skills, isNotEmpty);
          expect(detail.skills.length, inInclusiveRange(3, 4));
          expect(detail.passives, isNotEmpty);
          expect(detail.passives.length, inInclusiveRange(2, 4));
          expect(detail.constellations, isNotEmpty);
          expect(detail.constellations.length, 6);
          expect(detail.stats, isNotEmpty);
        }

        checkCharacterFileAscensionMaterialModel(service, detail.ascensionMaterials);
        if (!isTraveler) {
          checkCharacterFileTalentAscensionMaterialModel(service, detail.talentAscensionMaterials);
        } else {
          for (final ascMaterial in detail.multiTalentAscensionMaterials!) {
            expect(ascMaterial.number, inInclusiveRange(1, 3));
            checkCharacterFileTalentAscensionMaterialModel(service, ascMaterial.materials);
          }
        }

        for (final build in detail.builds) {
          expect(build.weaponKeys, isNotEmpty);
          expect(build.subStatsToFocus.length, greaterThanOrEqualTo(3));
          for (final key in build.weaponKeys) {
            final weapon = service.weapons.getWeapon(key);
            expect(weapon.type == detail.weaponType, isTrue);
          }

          for (final artifact in build.artifacts) {
            final valid = artifact.oneKey != null || artifact.multiples.isNotEmpty;
            expect(valid, isTrue);
            expect(artifact.stats.length, equals(5));
            expect(artifact.stats[0], equals(StatType.hp));
            expect(artifact.stats[1], equals(StatType.atk));
            if (artifact.oneKey != null) {
              expect(() => service.artifacts.getArtifact(artifact.oneKey!), returnsNormally);
            } else {
              for (final partial in artifact.multiples) {
                expect(() => service.artifacts.getArtifact(partial.key), returnsNormally);
                expect(partial.quantity, inInclusiveRange(1, 2));
              }
            }
          }
        }

        for (final skill in detail.skills) {
          checkKey(skill.key);
          if (!detail.isComingSoon) {
            checkAsset(skill.fullImagePath);
            expect(skill.stats, isNotEmpty);
            for (final stat in skill.stats) {
              switch (skill.type) {
                case CharacterSkillType.normalAttack:
                case CharacterSkillType.elementalSkill:
                case CharacterSkillType.elementalBurst:
                  expect(stat.values.length, 15);
                  break;
                case CharacterSkillType.others:
                  break;
                default:
                  throw Exception('Skill is not mapped');
              }
            }
            final statKeys = skill.stats.map((e) => e.key).toList();
            expect(statKeys.toSet().length, equals(statKeys.length));
            //check that all the values in the stats have the same length
            final statCount = skill.stats.map((e) => e.values.length).toSet().length;
            expect(statCount, equals(1));
          }

          for (final stat in skill.stats) {
            expect(stat.values, isNotEmpty);
          }
        }

        for (final passive in detail.passives) {
          checkKey(passive.key);
          if (!detail.isComingSoon) {
            checkAsset(passive.fullImagePath);
          }

          expect(passive.unlockedAt, isIn([-1, 1, 4]));
        }

        for (final constellation in detail.constellations) {
          checkKey(constellation.key);
          if (!detail.isComingSoon) {
            checkAsset(constellation.fullImagePath);
          }
          expect(constellation.number, inInclusiveRange(1, 6));
        }

        expect(detail.stats.where((e) => e.isAnAscension).length == 6, isTrue);
        var repetitionCount = 0;
        for (var i = 0; i < detail.stats.length; i++) {
          final stat = detail.stats[i];
          expect(stat.level, inInclusiveRange(1, 90));
          expect(stat.baseAtk, greaterThan(0));
          expect(stat.baseHp, greaterThan(0));
          expect(stat.baseDef, greaterThan(0));
          expect(stat.statValue, greaterThanOrEqualTo(0));
          if (i > 0 && i < detail.stats.length - 1) {
            final nextStat = detail.stats[i + 1];
            if (nextStat.statValue == stat.statValue) {
              repetitionCount++;
            } else {
              repetitionCount = 0;
            }
            expect(repetitionCount, lessThanOrEqualTo(4));
          }
        }
      }
    });

    test('check for weapons', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final weapons = service.weapons.getWeaponsForCard();
      for (final weapon in weapons) {
        final detail = service.weapons.getWeapon(weapon.key);
        checkKey(detail.key);
        checkAsset(detail.fullImagePath);
        expect(detail.type, equals(weapon.type));
        expect(detail.atk, equals(weapon.baseAtk));
        expect(detail.rarity, equals(weapon.rarity));
        expect(detail.secondaryStat, equals(weapon.subStatType));
        expect(detail.secondaryStatValue, equals(weapon.subStatValue));
        expect(detail.location, equals(weapon.locationType));
        expect(detail.ascensionMaterials, isNotEmpty);
        expect(detail.stats, isNotEmpty);

        if (detail.location == ItemLocationType.crafting) {
          expect(detail.craftingMaterials, isNotEmpty);
        } else {
          expect(detail.craftingMaterials, isEmpty);
        }

        for (final ascMaterial in detail.ascensionMaterials) {
          expect(ascMaterial.level, inInclusiveRange(20, 80));
          checkItemAscensionMaterialFileModel(service, ascMaterial.materials);
        }

        final ascensionNumber = detail.stats.where((el) => el.isAnAscension).length;
        switch (detail.rarity) {
          case 1:
          case 2:
            expect(ascensionNumber == 4, isTrue);
            break;
          default:
            expect(ascensionNumber == 6, isTrue);
            break;
        }

        var repetitionCount = 0;
        for (var i = 0; i < detail.stats.length; i++) {
          final stat = detail.stats[i];
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
          if (i > 0 && i < detail.stats.length - 1 && weapon.rarity > 2) {
            final nextStat = detail.stats[i + 1];
            if (nextStat.statValue == stat.statValue) {
              repetitionCount++;
            } else {
              repetitionCount = 0;
            }

            if (stat.level <= 40 && !stat.isAnAscension) {
              expect(repetitionCount, lessThanOrEqualTo(4));
            } else {
              expect(repetitionCount, lessThanOrEqualTo(2));
            }
          }
        }
      }
    });

    test('check for artifacts', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final artifacts = service.artifacts.getArtifactsForCard();
      for (final artifact in artifacts) {
        final detail = service.artifacts.getArtifact(artifact.key);
        checkKey(detail.key);
        checkAsset(detail.fullImagePath);
        expect(detail.minRarity, inInclusiveRange(1, 4));
        expect(detail.maxRarity, inInclusiveRange(3, 5));
      }
    });

    test('check the materials', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final materials = service.materials.getAllMaterialsForCard();
      for (final material in materials) {
        final detail = service.materials.getMaterial(material.key);
        checkKey(detail.key);
        checkAsset(detail.fullImagePath);
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
          checkKey(part.createsMaterialKey);
          expect(() => service.materials.getMaterial(part.createsMaterialKey), returnsNormally);
          for (final needs in part.needs) {
            expect(needs.quantity, greaterThanOrEqualTo(1));
            expect(() => service.materials.getMaterial(needs.key), returnsNormally);
          }
        }

        final characters = service.characters.getCharacterForItemsUsingMaterial(material.key);
        expect(characters.map((e) => e.key).toSet().length == characters.length, isTrue);

        final weapons = service.weapons.getWeaponForItemsUsingMaterial(material.key);
        expect(weapons.map((e) => e.key).toSet().length == weapons.length, isTrue);

        final droppedBy = service.monsters.getRelatedMonsterToMaterialForItems(detail.key);
        expect(droppedBy.map((e) => e.key).toSet().length == droppedBy.length, isTrue);
      }
    });

    test('check the monsters', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final monsters = service.monsters.getAllMonstersForCard();
      for (final monster in monsters) {
        final detail = service.monsters.getMonster(monster.key);
        checkKey(detail.key);
        checkAsset(detail.fullImagePath);

        for (final drop in detail.drops) {
          switch (drop.type) {
            case MonsterDropType.material:
              expect(() => service.materials.getMaterial(drop.key), returnsNormally);
              break;
            case MonsterDropType.artifact:
              expect(() => service.artifacts.getArtifact(drop.key), returnsNormally);
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

        final characters = service.characters.getCharactersForCard();

        for (final character in characters) {
          final detail = service.characters.getCharacter(character.key);
          final translation = service.translations.getCharacterTranslation(character.key);
          checkKey(translation.key);
          checkTranslation(translation.name, canBeNull: false);
          if (!detail.isComingSoon) {
            checkTranslation(translation.description, canBeNull: false);
          }

          expect(translation.skills, isNotEmpty);
          expect(translation.skills.length, equals(detail.skills.length));
          expect(translation.passives, isNotEmpty);
          expect(translation.passives.length, equals(detail.passives.length));
          expect(translation.constellations, isNotEmpty);
          expect(translation.constellations.length, equals(detail.constellations.length));

          checkKeys(translation.skills.map((e) => e.key).toList());
          checkKeys(translation.passives.map((e) => e.key).toList());
          checkKeys(translation.constellations.map((e) => e.key).toList());

          for (var i = 0; i < translation.skills.length; i++) {
            final skill = translation.skills[i];
            checkKey(skill.key);
            expect(skill.key, isIn(detail.skills.map((e) => e.key).toList()));
            checkTranslation(skill.title, canBeNull: false);
            if (detail.isComingSoon) {
              continue;
            }
            expect(skill.stats, isNotEmpty);
            for (final ability in skill.abilities) {
              final oneAtLeast = ability.name.isNotNullEmptyOrWhitespace ||
                  ability.description.isNotNullEmptyOrWhitespace ||
                  ability.secondDescription.isNotNullEmptyOrWhitespace;

              if (!oneAtLeast) {
                expect(ability.descriptions, isNotEmpty);
                for (final desc in ability.descriptions) {
                  checkTranslation(desc, canBeNull: false);
                }
              }
            }

            final stats = service.characters.getCharacterSkillStats(detail.skills[i].stats, skill.stats);
            expect(stats, isNotEmpty);
            switch (detail.skills[i].type) {
              case CharacterSkillType.normalAttack:
              case CharacterSkillType.elementalSkill:
              case CharacterSkillType.elementalBurst:
                expect(stats.length, 15);
                break;
              case CharacterSkillType.others:
                break;
              default:
                throw Exception('Skill is not mapped');
            }
            final hasPendingParam = stats.expand((el) => el.descriptions).any((el) => el.contains('param'));
            expect(hasPendingParam, equals(false));
          }

          for (final passive in translation.passives) {
            checkKey(passive.key);
            expect(passive.key, isIn(detail.passives.map((e) => e.key).toList()));
            if (detail.isComingSoon) {
              continue;
            }
            checkTranslation(passive.title, canBeNull: false);
            checkTranslation(passive.description, canBeNull: passive.descriptions.isNotEmpty);
            for (final desc in passive.descriptions) {
              checkTranslation(desc, canBeNull: false);
            }
          }

          for (final constellation in translation.constellations) {
            checkKey(constellation.key);
            expect(constellation.key, isIn(detail.constellations.map((e) => e.key).toList()));
            if (detail.isComingSoon) {
              continue;
            }
            checkTranslation(constellation.title, canBeNull: false);
            checkTranslation(constellation.description, canBeNull: false);
            checkTranslation(constellation.secondDescription);
            for (final desc in constellation.descriptions) {
              checkTranslation(desc, canBeNull: false);
            }
          }
        }
      }
    });

    test('check for weapons', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final weapons = service.weapons.getWeaponsForCard();
        for (final weapon in weapons) {
          final detail = service.weapons.getWeapon(weapon.key);
          final translation = service.translations.getWeaponTranslation(weapon.key);
          checkKey(translation.key);
          checkTranslation(translation.name, canBeNull: false);
          checkTranslation(translation.description, canBeNull: false);
          if (detail.rarity > 2) {
            //all weapons with a rarity > 2 have 5 refinements except the following
            //the ps4 sword, the aloy weapon
            final ignore = ['sword-of-descension', 'predator', 'kagotsurube-isshin'];
            if (!ignore.contains(detail.key)) {
              expect(translation.refinements.length, 5);
            } else {
              expect(translation.refinements, isNotEmpty);
            }
          } else {
            expect(translation.refinements, isEmpty);
          }

          for (final refinement in translation.refinements) {
            checkTranslation(refinement, canBeNull: false, checkForColor: false);
          }
        }
      }
    });

    test('check for artifacts', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final artifacts = service.artifacts.getArtifactsForCard();
        for (final artifact in artifacts) {
          final detail = service.artifacts.getArtifact(artifact.key);
          final translation = service.translations.getArtifactTranslation(detail.key);
          checkKey(translation.key);
          checkTranslation(translation.name, canBeNull: false);
          expect(translation.bonus.length, inInclusiveRange(1, 2));
          for (final bonus in translation.bonus) {
            checkTranslation(bonus, canBeNull: false);
          }
        }
      }
    });

    test('check the materials', () async {
      final service = _getService();
      final toCheck = [AppLanguageType.english, AppLanguageType.spanish, AppLanguageType.simplifiedChinese];
      for (final lang in toCheck) {
        await service.init(lang);
        final materials = service.materials.getAllMaterialsForCard();
        for (final material in materials) {
          final detail = service.materials.getMaterial(material.key);
          final translation = service.translations.getMaterialTranslation(detail.key);
          checkKey(translation.key);
          checkTranslation(translation.name, canBeNull: false);
          checkTranslation(translation.description, canBeNull: false);
        }
      }
    });

    test('check the monsters', () async {
      final service = _getService();
      for (final lang in languages) {
        await service.init(lang);
        final monsters = service.monsters.getAllMonstersForCard();
        for (final monster in monsters) {
          final translation = service.translations.getMonsterTranslation(monster.key);
          checkKey(translation.key);
          checkTranslation(translation.name, canBeNull: false);
        }
      }
    });
  });

  group('Birthdays', () {
    void _checkBirthday(CharacterBirthdayModel birthday) {
      checkItemKeyNameAndImage(birthday.key, birthday.name, birthday.image);
      expect(birthday.birthday.isAfter(DateTime.now()), isTrue);
      expect(birthday.birthdayString.isNotNullEmptyOrWhitespace, isTrue);
      expect(birthday.daysUntilBirthday > 0, isTrue);
    }

    test("check Bennet's birthday, not using current year", () {
      for (final lang in languages.where((el) => el != AppLanguageType.french)) {
        final service = _getLocaleService(lang);
        final birthday = service.getCharBirthDate('02/29');
        expect(birthday.day, equals(29));
        expect(birthday.month, equals(DateTime.february));
      }
    });

    test("check Bennet's birthday, using current year", () {
      for (final lang in languages.where((el) => el != AppLanguageType.french)) {
        final service = _getLocaleService(lang);
        final birthday = service.getCharBirthDate('02/29', useCurrentYear: true);
        final lastDayOfFebruary = DateUtils.getLastDayOfMonth(DateTime.february);
        expect(birthday.day, equals(lastDayOfFebruary));
        expect(birthday.month, equals(DateTime.february));
      }
    });

    test('upcoming characters are not shown', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final localeService = _getLocaleService(AppLanguageType.english);
      final upcoming = service.characters.getUpcomingCharactersKeys();
      for (final key in upcoming) {
        final char = service.characters.getCharacter(key);
        final date = localeService.getCharBirthDate(char.birthday);
        final chars = service.characters.getCharacterBirthdays(month: date.month, day: date.day);
        expect(chars.any((el) => el.key == key), false);
      }
    });

    test('check character birthdays, only by month', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final months = List.generate(DateTime.monthsPerYear, (index) => index + 1);
      for (final month in months) {
        final birthdays = service.characters.getCharacterBirthdays(month: month);
        expect(birthdays.isNotEmpty, isTrue);
        for (final birthday in birthdays) {
          _checkBirthday(birthday);
        }
      }
    });

    test('check character birthdays, only by day', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final birthdays = service.characters.getCharacterBirthdays(day: 20);
      expect(birthdays.isNotEmpty, isTrue);
      for (final birthday in birthdays) {
        _checkBirthday(birthday);
      }
    });

    test('check character birthdays, by month and day', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final birthdays = service.characters.getCharacterBirthdays(month: DateTime.november, day: 20);
      expect(birthdays.length, 1);
      expect(birthdays.first.key, equals('keqing'));
      _checkBirthday(birthdays.first);
    });

    test('check character birthdays, invalid month and day', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      expect(() => service.characters.getCharacterBirthdays(), throwsA(isA<Exception>()));
      expect(() => service.characters.getCharacterBirthdays(month: -1), throwsA(isA<Exception>()));
      expect(() => service.characters.getCharacterBirthdays(day: -1), throwsA(isA<Exception>()));
      expect(() => service.characters.getCharacterBirthdays(month: DateTime.february, day: 31), throwsA(isA<Exception>()));
    });
  });

  group('Elements', () {
    test('check debuffs', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final debuffs = service.elements.getElementDebuffs();
        expect(debuffs.length, equals(4));
        for (final debuff in debuffs) {
          expect(debuff.name, allOf([isNotNull, isNotEmpty]));
          expect(debuff.effect, allOf([isNotNull, isNotEmpty]));
          checkAsset(debuff.image);
        }
      }
    });

    test('check resonances', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final reactions = service.elements.getElementReactions();
        expect(reactions.length, equals(11));
        for (final reaction in reactions) {
          expect(reaction.name, allOf([isNotNull, isNotEmpty]));
          expect(reaction.effect, allOf([isNotNull, isNotEmpty]));
          expect(reaction.principal, isNotEmpty);
          expect(reaction.secondary, isNotEmpty);

          final imgs = reaction.principal + reaction.secondary;
          for (final img in imgs) {
            checkAsset(img);
          }
        }
      }
    });

    test('check resonances', () async {
      final service = _getService();

      for (final lang in languages) {
        await service.init(lang);
        final resonances = service.elements.getElementResonances();
        expect(resonances.length, equals(7));
        for (final resonance in resonances) {
          expect(resonance.name, allOf([isNotNull, isNotEmpty]));
          expect(resonance.effect, allOf([isNotNull, isNotEmpty]));

          final imgs = resonance.principal + resonance.secondary;
          for (final img in imgs) {
            checkAsset(img);
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
      final defaultTierList = service.characters.getDefaultCharacterTierList(defaultColors);
      expect(defaultTierList.length, equals(7));

      final charCountInTierList = defaultTierList.expand((el) => el.items).length;
      final charCount = service.characters.getCharactersForCard().where((el) => !el.isComingSoon).length;
      expect(charCountInTierList == charCount, isTrue);

      for (var i = 0; i < defaultColors.length; i++) {
        final tierRow = defaultTierList[i];
        expect(tierRow.tierText, allOf([isNotNull, isNotEmpty]));
        expect(tierRow.items, isNotEmpty);
        expect(tierRow.tierColor, equals(defaultColors[i]));

        for (final item in tierRow.items) {
          checkKey(item.key);
          checkAsset(item.image);
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
        final materials = service.characters.getCharacterAscensionMaterials(day);
        expect(materials, isNotEmpty);
        for (final material in materials) {
          checkKey(material.key);
          checkAsset(material.image);
          expect(material.name, allOf([isNotNull, isNotEmpty]));
          expect(material.characters, isNotEmpty);
          expect(material.days, isNotEmpty);
          for (final item in material.characters) {
            checkItemCommon(item);
          }
        }

        if (day == DateTime.sunday) {
          final allCharacters = service.characters.getCharactersForCard();
          final notComingSoon = allCharacters.where((el) => !el.isComingSoon).length;
          final got = materials.expand((el) => el.characters).map((e) => e.key).toSet().length;
          expect(notComingSoon, equals(got));
        }
      }
    });
  });

  group('Banner History', () {
    test('check banner history', () async {
      const types = BannerHistoryItemType.values;
      final service = _getService();
      await service.init(AppLanguageType.english);

      for (final type in types) {
        final banners = service.bannerHistory.getBannerHistory(type);
        expect(banners.length, banners.where((el) => el.type == type).length);
        for (final banner in banners) {
          checkItemKeyAndImage(banner.key, banner.image);
          checkTranslation(banner.name, canBeNull: false);
          expect(banner.versions.isNotEmpty, isTrue);
          expect(banner.rarity >= 4, isTrue);
          expect(banner.versions.any((el) => el.released), isTrue);
          for (final version in banner.versions) {
            if (version.released) {
              expect(version.number, isNull);
              expect(version.version >= 1, isTrue);
            } else if (version.number == 0) {
              expect(version.released, isFalse);
            } else {
              expect(version.released, isFalse);
              expect(version.number, isNotNull);
              expect(version.number! >= 1, isTrue);
            }
          }
        }
      }
    });

    test('check versions', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);

      final versions = service.bannerHistory.getBannerHistoryVersions(SortDirectionType.asc);
      expect(versions.length, versions.toSet().length);
    });

    test('check periods', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);

      final versions = service.bannerHistory.getBannerHistoryVersions(SortDirectionType.asc);
      final validItemTypes = [ItemType.character, ItemType.weapon];
      for (final version in versions) {
        final banners = service.bannerHistory.getBanners(version);
        expect(banners.isNotEmpty, isTrue);
        for (final banner in banners) {
          expect(banner.version, version);
          expect(banner.until.isAfter(banner.from), isTrue);
          expect(banner.items.isNotEmpty, isTrue);

          final keys = banner.items.map((e) => e.key).toList();
          expect(keys.toSet().length == keys.length, isTrue);

          for (final item in banner.items) {
            checkItemKeyAndImage(item.key, item.image);
            expect(item.rarity >= 4, isTrue);
            expect(validItemTypes.contains(item.type), isTrue);
          }
        }
      }
    });

    test('check version, version does not have any banner', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final banners = service.bannerHistory.getBanners(1.7);
      expect(banners.isEmpty, isTrue);
    });

    test('check version, invalid version', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      expect(() => service.bannerHistory.getBanners(0.1), throwsA(isA<Exception>()));
    });

    test('check item release history', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);

      final history = service.bannerHistory.getItemReleaseHistory('keqing');
      expect(history.isNotEmpty, isTrue);

      for (final item in history) {
        expect(item.dates.isNotEmpty, isTrue);
        expect(item.version >= 1, isTrue);
      }
    });

    test('check item release history, item does not exist', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      expect(() => service.bannerHistory.getItemReleaseHistory('the-item'), throwsA(isA<Exception>()));
    });
  });

  group('Charts', () {
    test('check top charts', () async {
      final types = ChartType.values.where((el) => el != ChartType.characterBirthdays).toList();
      final service = _getService();
      await service.init(AppLanguageType.english);
      for (final type in types) {
        final tops = service.getTopCharts(type);
        expect(tops.isNotEmpty, isTrue);
        final totalPercentage = tops.map((e) => e.percentage).sum.round();
        expect(totalPercentage, 100);
        for (final item in tops) {
          expect(item.type == type, isTrue);
          checkKey(item.key);
          checkTranslation(item.name, canBeNull: false, checkForColor: false);
          expect(item.value > 0, isTrue);
          expect(item.percentage > 0 && item.percentage < 100, isTrue);

          final expectedStars = type.name.contains('Five') ? 5 : 4;
          switch (type) {
            case ChartType.topFiveStarCharacterMostReruns:
            case ChartType.topFourStarCharacterMostReruns:
            case ChartType.topFiveStarCharacterLeastReruns:
            case ChartType.topFourStarCharacterLeastReruns:
              final char = service.characters.getCharacter(item.key);
              expect(char.rarity == expectedStars, isTrue);
              break;
            case ChartType.topFiveStarWeaponMostReruns:
            case ChartType.topFourStarWeaponMostReruns:
            case ChartType.topFiveStarWeaponLeastReruns:
            case ChartType.topFourStarWeaponLeastReruns:
              final weapon = service.weapons.getWeapon(item.key);
              expect(weapon.rarity == expectedStars, isTrue);
              break;
            default:
              throw Exception('Type = $type is not valid');
          }

          final releaseCount = service.bannerHistory.getItemReleaseHistory(item.key).length;
          expect(item.value == releaseCount, isTrue);
        }
      }
    });

    test('check top charts, invalid type', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      expect(() => service.getTopCharts(ChartType.characterBirthdays), throwsA(isA<Exception>()));
    });

    test('check birthdays', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final birthdays = service.characters.getCharacterBirthdaysForCharts();
      expect(birthdays.isNotEmpty, isTrue);
      expect(birthdays.length, 12);

      final keys = birthdays.expand((el) => el.items).map((e) => e.key).toList();
      expect(keys.length, keys.toSet().length);

      final charCount = service.characters.getCharactersForCard().where((el) => !el.key.startsWith('traveler') && !el.isComingSoon).length;
      expect(keys.length, charCount);

      final allMonths = List.generate(DateTime.monthsPerYear, (index) => index + 1);
      for (final monthBirthdays in birthdays) {
        expect(monthBirthdays.month, isIn(allMonths));
        for (final birthday in monthBirthdays.items) {
          checkItemCommonWithName(birthday);
        }
      }
    });

    test('check elements', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final versions = service.bannerHistory.getBannerHistoryVersions(SortDirectionType.asc);
      final expectedLength = ElementType.values.length - 1;

      final elements = service.bannerHistory.getElementsForCharts(versions.first, versions.last);
      expect(elements.length, expectedLength);
      expect(elements.map((el) => el.type).toSet().length, expectedLength);

      for (final element in elements) {
        expect(element.points.isNotEmpty, isTrue);

        for (final point in element.points) {
          expect(point.y >= 0, isTrue);
        }
      }
    });

    test('check elements, invalid from version', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      expect(() => service.bannerHistory.getElementsForCharts(-1, 2.1), throwsA(isA<Exception>()));
    });

    test('check elements, invalid until version', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      expect(() => service.bannerHistory.getElementsForCharts(1, -1), throwsA(isA<Exception>()));
    });

    test('check item ascension stats', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      const validTypes = [ItemType.character, ItemType.weapon];
      final validForCharacters = getCharacterPossibleAscensionStats();
      final validForWeapons = getWeaponPossibleAscensionStats();
      for (final type in validTypes) {
        final stats = service.getItemAscensionStatsForCharts(type);
        expect(stats.isNotEmpty, isTrue);

        final statTypes = stats.map((e) => e.type);
        expect(statTypes.toSet().length, statTypes.length);

        for (final stat in stats) {
          expect(stat.itemType, type);
          expect(stat.quantity > 0, isTrue);
          if (type == ItemType.character) {
            expect(stat.type, isIn(validForCharacters));
          } else {
            expect(stat.type, isIn(validForWeapons));
          }
        }
      }
    });

    test('check item ascension stats, item type is not valid', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final types = ItemType.values.where((el) => el != ItemType.character && el != ItemType.weapon).toList();
      for (final type in types) {
        expect(() => service.getItemAscensionStatsForCharts(type), throwsA(isA<Exception>()));
      }
    });

    test('check character regions', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final regions = service.characters.getCharacterRegionsForCharts();
      expect(regions.isNotEmpty, isTrue);
      expect(regions.map((e) => e.regionType).toSet().length, RegionType.values.length - 1);

      final characters =
          service.characters.getCharactersForCard().where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld).toList();
      for (final region in regions) {
        expect(region.regionType != RegionType.anotherWorld, isTrue);
        expect(region.quantity, characters.where((el) => el.regionType == region.regionType).length);
      }
    });

    void _validateChartGenderModel(ChartGenderModel gender) {
      expect(gender.femaleCount >= 0, isTrue);
      expect(gender.maleCount >= 0, isTrue);
      expect(gender.regionType != RegionType.anotherWorld, isTrue);
      if (gender.femaleCount > 0 || gender.maleCount > 0) {
        expect(gender.maxCount, max(gender.femaleCount, gender.maleCount));
      } else {
        expect(gender.maxCount, 0);
      }
    }

    test('check character genders', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final genders = service.characters.getCharacterGendersForCharts();
      expect(genders.isNotEmpty, isTrue);
      expect(genders.map((e) => e.regionType).toSet().length, RegionType.values.length - 1);

      final characters =
          service.characters.getCharactersForCard().where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld).toList();
      for (final gender in genders) {
        _validateChartGenderModel(gender);

        final expectedCount = characters.where((el) => el.regionType == gender.regionType).length;
        expect(gender.maleCount + gender.femaleCount, expectedCount);
      }
    });

    test('check character gender by region', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final regions = RegionType.values.where((el) => el != RegionType.anotherWorld).toList();
      final characters =
          service.characters.getCharactersForCard().where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld).toList();
      for (final region in regions) {
        final gender = service.characters.getCharacterGendersByRegionForCharts(region);
        _validateChartGenderModel(gender);

        final expectedCount = characters.where((el) => el.regionType == region).length;
        expect(gender.maleCount + gender.femaleCount, expectedCount);
      }
    });

    test('check character gender by region, invalid region', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      expect(() => service.characters.getCharacterGendersByRegionForCharts(RegionType.anotherWorld), throwsA(isA<Exception>()));
    });
  });

  group('Common', () {
    test('check character for items by region', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final regions = RegionType.values.where((el) => el != RegionType.anotherWorld).toList();
      final characters =
          service.characters.getCharactersForCard().where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld).toList();
      for (final region in regions) {
        final items = service.characters.getCharactersForItemsByRegion(region);
        final expectedCount = characters.where((el) => el.regionType == region).length;
        expect(items.length, expectedCount);

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });

    test('check character for items by region, invalid region', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      expect(() => service.characters.getCharactersForItemsByRegion(RegionType.anotherWorld), throwsA(isA<Exception>()));
    });

    test('check characters for items by region and gender', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final regions = RegionType.values.where((el) => el != RegionType.anotherWorld).toList();
      final characters =
          service.characters.getCharactersForCard().where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld).toList();
      for (final region in regions) {
        final females = service.characters.getCharactersForItemsByRegionAndGender(region, true);
        final males = service.characters.getCharactersForItemsByRegionAndGender(region, false);
        final items = males + females;
        final expectedCount = characters.where((el) => el.regionType == region).length;
        expect(items.length, expectedCount);

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });

    test('check characters for items by region and gender, invalid region', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      expect(() => service.characters.getCharactersForItemsByRegionAndGender(RegionType.anotherWorld, true), throwsA(isA<Exception>()));
      expect(() => service.characters.getCharactersForItemsByRegionAndGender(RegionType.anotherWorld, false), throwsA(isA<Exception>()));
    });

    test('check items ascension stats', () async {
      final service = _getService();
      await service.init(AppLanguageType.english);
      final validForCharacters = getCharacterPossibleAscensionStats();
      final validForWeapons = getWeaponPossibleAscensionStats();
      final characters = service.characters.getCharactersForCard().where((el) => !el.isComingSoon).toList();
      final weapons = service.weapons.getWeaponsForCard().where((el) => !el.isComingSoon).toList();

      for (final stat in validForCharacters) {
        final items = service.getItemsAscensionStats(stat, ItemType.character);
        expect(items.isNotEmpty, isTrue);
        expect(items.length, characters.where((el) => el.subStatType == stat).length);

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }

      for (final stat in validForWeapons) {
        final items = service.getItemsAscensionStats(stat, ItemType.weapon);
        expect(items.isNotEmpty, isTrue);
        expect(items.length, weapons.where((el) => el.subStatType == stat).length);

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });
  });
}
