import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/extensions/datetime_extensions.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  late final CharacterFileService service;

  setUpAll(() {
    return Future(() async {
      service = await getCharacterFileService(AppLanguageType.english);
    });
  });

  void validateChartGenderModel(ChartGenderModel gender) {
    expect(gender.femaleCount >= 0, isTrue);
    expect(gender.maleCount >= 0, isTrue);
    expect(gender.regionType != RegionType.anotherWorld, isTrue);
    if (gender.femaleCount > 0 || gender.maleCount > 0) {
      expect(gender.maxCount, max(gender.femaleCount, gender.maleCount));
    } else {
      expect(gender.maxCount, 0);
    }
  }

  group('Get characters for card', () {
    for (final lang in AppLanguageType.values) {
      test('language = ${lang.name}', () async {
        final service = await getCharacterFileService(lang);
        final characters = service.getCharactersForCard();
        checkKeys(characters.map((e) => e.key).toList());

        final materialImgs = service.materials.getAllMaterialsForCard().map((e) => e.image).toList();
        for (final char in characters) {
          checkKey(char.key);
          expect(char.name, allOf([isNotEmpty, isNotNull]));
          checkAsset(char.image);
          checkAsset(char.iconImage);
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
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getCharacterFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final characters = service.getCharactersForCard();
      expect(characters.isEmpty, isTrue);
    });
  });

  test('Get character', () {
    final localeService = getLocaleService(AppLanguageType.english);
    final characters = service.getCharactersForCard();
    for (final character in characters) {
      final detail = service.getCharacter(character.key);
      final isTraveler = isTheTraveler(character.key);
      checkKey(detail.key);
      expect(detail.rarity, character.stars);
      expect(detail.weaponType, character.weaponType);
      expect(detail.elementType, character.elementType);
      checkAsset(service.resources.getCharacterImagePath(detail.image));
      checkAsset(service.resources.getCharacterIconImagePath(detail.iconImage));
      checkAsset(service.resources.getCharacterFullImagePath(detail.fullImage));
      expect(detail.region, character.regionType);
      expect(detail.role, character.roleType);
      expect(detail.isComingSoon, character.isComingSoon);
      expect(detail.isNew, character.isNew);
      if (!detail.isComingSoon) {
        expect(detail.tier, isIn(['d', 'c', 'b', 'a', 's', 'ss', 'sss']));
      }

      if (isTraveler) {
        checkAsset(service.resources.getCharacterFullImagePath(detail.secondFullImage!));
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
            expect(
              priority,
              isIn([CharacterSkillType.normalAttack, CharacterSkillType.elementalBurst, CharacterSkillType.elementalSkill]),
            );
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

      checkCharacterFileAscensionMaterialModel(
        service.materials,
        detail.ascensionMaterials,
        checkMaterialType: !detail.isComingSoon,
      );
      if (!isTraveler) {
        checkCharacterFileTalentAscensionMaterialModel(
          service.materials,
          detail.talentAscensionMaterials,
          checkMaterialTypeAndLength: !detail.isComingSoon,
        );
      } else {
        for (final ascMaterial in detail.multiTalentAscensionMaterials!) {
          expect(ascMaterial.number, inInclusiveRange(1, 3));
          checkCharacterFileTalentAscensionMaterialModel(
            service.materials,
            ascMaterial.materials,
            checkMaterialTypeAndLength: !detail.isComingSoon,
          );
        }
      }

      for (final build in detail.builds) {
        expect(build.weaponKeys, isNotEmpty);
        expect(build.subStatsToFocus.length, greaterThanOrEqualTo(2));
        for (final key in build.weaponKeys) {
          final weapon = service.weapons.getWeapon(key);
          expect(weapon.type == detail.weaponType, isTrue);
        }

        for (final artifact in build.artifacts) {
          final valid = artifact.oneKey != null || artifact.multiples.isNotEmpty;
          expect(valid, isTrue);
          expect(artifact.stats.length, equals(ArtifactType.values.length));
          for (int i = 0; i < artifact.stats.length; i++) {
            final StatType stat = artifact.stats[i];
            final List<StatType> possibleStats = getArtifactPossibleMainStats(ArtifactType.values[i]);
            expect(stat, isIn(possibleStats));
          }
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
          checkAsset(service.resources.getSkillImagePath(skill.image));
          expect(skill.stats, isNotEmpty);
          for (final stat in skill.stats) {
            switch (skill.type) {
              case CharacterSkillType.normalAttack:
              case CharacterSkillType.elementalSkill:
              case CharacterSkillType.elementalBurst:
                expect(stat.values.length, 15);
              case CharacterSkillType.others:
                break;
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
          checkAsset(service.resources.getSkillImagePath(passive.image));
        }

        expect(passive.unlockedAt, isIn([-1, 1, 4]));
      }

      for (final constellation in detail.constellations) {
        checkKey(constellation.key);
        if (!detail.isComingSoon) {
          checkAsset(service.resources.getSkillImagePath(constellation.image));
        }
        expect(constellation.number, inInclusiveRange(1, 6));
      }

      final statAscCount = detail.stats.where((e) => e.isAnAscension).length;
      if (!detail.isComingSoon) {
        expect(statAscCount == 6, isTrue);
      } else {
        expect(statAscCount <= 6, isTrue);
      }
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

  group('Birthdays', () {
    void checkBirthday(CharacterBirthdayModel birthday) {
      checkItemKeyNameAndImage(birthday.key, birthday.name, birthday.image);

      final DateTime now = DateTime.now().getStartingDate();
      expect(birthday.birthday.isAfterInclusive(now), isTrue);
      expect(birthday.birthdayString.isNotNullEmptyOrWhitespace, isTrue);
      if (birthday.birthday != now) {
        expect(birthday.daysUntilBirthday > 0, isTrue);
      } else {
        expect(birthday.daysUntilBirthday, isZero);
      }
    }

    test('upcoming characters are not shown', () {
      final localeService = getLocaleService(AppLanguageType.english);
      final upcoming = service.getUpcomingCharactersKeys();
      for (final key in upcoming) {
        if (isTheTraveler(key)) {
          continue;
        }
        final char = service.getCharacter(key);
        final date = localeService.getCharBirthDate(char.birthday);
        final chars = service.getCharacterBirthdays(month: date.month, day: date.day);
        expect(chars.any((el) => el.key == key), false);
      }
    });

    test('by month', () {
      final months = List.generate(DateTime.monthsPerYear, (index) => index + 1);
      for (final month in months) {
        final birthdays = service.getCharacterBirthdays(month: month);
        expect(birthdays.isNotEmpty, isTrue);
        for (final birthday in birthdays) {
          checkBirthday(birthday);
        }
      }
    });

    test('by day', () {
      final birthdays = service.getCharacterBirthdays(day: 20);
      expect(birthdays.isNotEmpty, isTrue);
      for (final birthday in birthdays) {
        checkBirthday(birthday);
      }
    });

    test('by month and day', () {
      final birthdays = service.getCharacterBirthdays(month: DateTime.november, day: 20);
      expect(birthdays.length, 1);
      expect(birthdays.first.key, equals('keqing'));
      checkBirthday(birthdays.first);
    });

    test('invalid month and day', () {
      expect(
        () => service.getCharacterBirthdays(),
        throwsA(predicate<ArgumentError>((e) => e.toString().toLowerCase().contains('must provide'))),
      );
      expect(
        () => service.getCharacterBirthdays(month: -1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'month')),
      );
      expect(
        () => service.getCharacterBirthdays(day: -1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'day')),
      );
      expect(
        () => service.getCharacterBirthdays(month: DateTime.february, day: 31),
        throwsA(predicate<ArgumentError>((e) => e.name == 'day')),
      );
    });
  });

  group('TierList', () {
    test('check the default one', () {
      final List<int> defaultColors = [
        0xfff44336,
        0xfff56c62,
        0xffff7d06,
        0xffff9800,
        0xffffc107,
        0xffffeb3b,
        0xff8bc34a,
      ];

      final defaultTierList = service.getDefaultCharacterTierList(defaultColors);
      expect(defaultTierList.length, equals(7));

      final charCountInTierList = defaultTierList.expand((el) => el.items).length;
      final charCount = service.getCharactersForCard().where((el) => !el.isComingSoon).length;
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

  test('Get character ascension materials for a day', () {
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
        checkKey(material.key);
        checkAsset(material.image);
        expect(material.name, allOf([isNotNull, isNotEmpty]));
        final List<String> ignore = [
          'teachings-of-vagrancy',
          'teachings-of-elysium',
          'teachings-of-moonlight',
        ];
        if (ignore.contains(material.key)) {
          continue;
        }
        expect(material.characters, isNotEmpty);
        expect(material.days, isNotEmpty);
        for (final item in material.characters) {
          checkItemCommonWithName(item);
        }
        final travelerExists = material.characters.where((el) => isTheTraveler(el.key)).isNotEmpty;
        expect(travelerExists, isTrue);
      }

      if (day == DateTime.sunday) {
        final allCharacters = service.getCharactersForCard();
        final notComingSoon = allCharacters.where((el) => !el.isComingSoon).length;
        final got = materials.expand((el) => el.characters).map((e) => e.key).toSet().length;
        expect(notComingSoon, equals(got));
      }
    }
  });

  group('Get character for items by region', () {
    test('valid regions', () {
      final regions = RegionType.values.where((el) => el != RegionType.anotherWorld).toList();
      final characters = service
          .getCharactersForCard()
          .where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld)
          .toList();
      for (final region in regions) {
        final items = service.getCharactersForItemsByRegion(region);
        final expectedCount = characters.where((el) => el.regionType == region).length;
        expect(items.length, expectedCount);

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });

    test('invalid region', () {
      expect(
        () => service.getCharactersForItemsByRegion(RegionType.anotherWorld),
        throwsA(isA<OperationNotSupportedError>()),
      );
    });
  });

  group('Get characters for items by region and gender', () {
    test('valid regions', () {
      final regions = RegionType.values.where((el) => el != RegionType.anotherWorld).toList();
      final characters = service
          .getCharactersForCard()
          .where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld)
          .toList();
      for (final region in regions) {
        final females = service.getCharactersForItemsByRegionAndGender(region, true);
        final males = service.getCharactersForItemsByRegionAndGender(region, false);
        final items = males + females;
        final expectedCount = characters.where((el) => el.regionType == region).length;
        expect(items.length, expectedCount);

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });

    test('invalid region', () {
      expect(
        () => service.getCharactersForItemsByRegionAndGender(RegionType.anotherWorld, true),
        throwsA(isA<OperationNotSupportedError>()),
      );
      expect(
        () => service.getCharactersForItemsByRegionAndGender(RegionType.anotherWorld, false),
        throwsA(isA<OperationNotSupportedError>()),
      );
    });
  });

  test('Get character regions', () {
    final regions = service.getCharacterRegionsForCharts();
    expect(regions.isNotEmpty, isTrue);
    expect(regions.map((e) => e.regionType).toSet().length, RegionType.values.length - 1);

    final characters = service
        .getCharactersForCard()
        .where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld)
        .toList();
    for (final region in regions) {
      expect(region.regionType != RegionType.anotherWorld, isTrue);
      expect(region.quantity, characters.where((el) => el.regionType == region.regionType).length);
    }
  });

  test('Get character genders', () {
    final genders = service.getCharacterGendersForCharts();
    expect(genders.isNotEmpty, isTrue);
    expect(genders.map((e) => e.regionType).toSet().length, RegionType.values.length - 1);

    final characters = service
        .getCharactersForCard()
        .where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld)
        .toList();
    for (final gender in genders) {
      validateChartGenderModel(gender);

      final expectedCount = characters.where((el) => el.regionType == gender.regionType).length;
      expect(gender.maleCount + gender.femaleCount, expectedCount);
    }
  });

  group('Get character gender by region', () {
    test('valid regions', () {
      final regions = RegionType.values.where((el) => el != RegionType.anotherWorld).toList();
      final characters = service
          .getCharactersForCard()
          .where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld)
          .toList();
      for (final region in regions) {
        final gender = service.getCharacterGendersByRegionForCharts(region);
        validateChartGenderModel(gender);

        final expectedCount = characters.where((el) => el.regionType == region).length;
        expect(gender.maleCount + gender.femaleCount, expectedCount);
      }
    });

    test('invalid region', () {
      expect(
        () => service.getCharacterGendersByRegionForCharts(RegionType.anotherWorld),
        throwsA(isA<OperationNotSupportedError>()),
      );
    });
  });

  test('Get character birthdays for charts', () {
    final birthdays = service.getCharacterBirthdaysForCharts();
    expect(birthdays.isNotEmpty, isTrue);
    expect(birthdays.length, 12);

    final keys = birthdays.expand((el) => el.items).map((e) => e.key).toList();
    expect(keys.length, keys.toSet().length);

    final charCount = service.getCharactersForCard().where((el) => !isTheTraveler(el.key) && !el.isComingSoon).length;
    expect(keys.length, charCount);

    final allMonths = List.generate(DateTime.monthsPerYear, (index) => index + 1);
    for (final monthBirthdays in birthdays) {
      expect(monthBirthdays.month, isIn(allMonths));
      for (final birthday in monthBirthdays.items) {
        checkItemCommonWithName(birthday);
      }
    }
  });
}
