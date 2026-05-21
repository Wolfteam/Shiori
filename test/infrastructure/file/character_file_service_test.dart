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
    expect(gender.femaleCount >= 0, isTrue, reason: 'Should be true (property=femaleCount >= 0, isTrue)');
    expect(gender.maleCount >= 0, isTrue, reason: 'Should be true (property=maleCount >= 0, isTrue)');
    expect(gender.regionType != RegionType.anotherWorld, isTrue, reason: 'Should be true (property=anotherWorld)');
    if (gender.femaleCount > 0 || gender.maleCount > 0) {
      expect(
        gender.maxCount,
        max(gender.femaleCount, gender.maleCount),
        reason: 'Should match expected value (property=maxCount)',
      );
    } else {
      expect(gender.maxCount, 0, reason: 'Should match expected value (property=maxCount, expected=0)');
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
          expect(char.name, allOf([isNotEmpty, isNotNull]), reason: 'Should not be empty (property=name, key=${char.key})');
          checkAsset(char.image);
          checkAsset(char.iconImage);
          expect(
            char.stars,
            allOf([greaterThanOrEqualTo(4), lessThanOrEqualTo(5)]),
            reason: 'Should be greater than expected (property=stars, key=${char.key})',
          );
          if (char.isNew || char.isComingSoon) {
            expect(char.isNew, isNot(char.isComingSoon), reason: 'Should match expected value (property=isNew, key=${char.key})');
          }

          if (!char.isComingSoon) {
            expect(char.materials, isNotEmpty, reason: 'Should not be empty (property=materials, key=${char.key})');
            final expected = materialImgs.where((el) => char.materials.contains(el)).length;
            expect(
              char.materials.length,
              equals(expected),
              reason: 'Should equal expected value (property=materials, key=${char.key})',
            );
          }
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getCharacterFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final characters = service.getCharactersForCard();
      expect(characters.isEmpty, isTrue, reason: 'Should be true');
    });
  });

  test('Get character', () {
    final localeService = getLocaleService(AppLanguageType.english);
    final characters = service.getCharactersForCard();
    for (final character in characters) {
      final detail = service.getCharacter(character.key);
      final isTraveler = isTheTraveler(character.key);
      checkKey(detail.key);
      expect(detail.rarity, character.stars, reason: 'Should match expected value (property=rarity, key=${character.key})');
      expect(
        detail.weaponType,
        character.weaponType,
        reason: 'Should match expected value (property=weaponType, key=${character.key})',
      );
      expect(
        detail.elementType,
        character.elementType,
        reason: 'Should match expected value (property=elementType, key=${character.key})',
      );
      checkAsset(service.resources.getCharacterImagePath(detail.image));
      checkAsset(service.resources.getCharacterIconImagePath(detail.iconImage));
      checkAsset(service.resources.getCharacterFullImagePath(detail.fullImage));
      expect(detail.region, character.regionType, reason: 'Should match expected value (property=region, key=${character.key})');
      expect(detail.role, character.roleType, reason: 'Should match expected value (property=role, key=${character.key})');
      expect(
        detail.isComingSoon,
        character.isComingSoon,
        reason: 'Should match expected value (property=isComingSoon, key=${character.key})',
      );
      expect(detail.isNew, character.isNew, reason: 'Should match expected value (property=isNew, key=${character.key})');
      if (!detail.isComingSoon) {
        expect(
          detail.tier,
          isIn(['d', 'c', 'b', 'a', 's', 'ss', 'sss']),
          reason: 'Should match expected value (property=tier, key=${character.key})',
        );
      }

      if (isTraveler) {
        checkAsset(service.resources.getCharacterFullImagePath(detail.secondFullImage!));
      } else {
        expect(
          detail.birthday,
          allOf([isNotNull, isNotEmpty]),
          reason: 'Should not be empty (property=birthday, key=${character.key})',
        );

        //eg: 09/14
        expect(
          detail.birthday!.length,
          equals(5),
          reason: 'Should equal expected value (property=birthday!, key=${character.key})',
        );

        expect(
          () => localeService.getCharBirthDate(detail.birthday),
          returnsNormally,
          reason: 'Should execute without throwing (key=${character.key})',
        );
      }

      if (!detail.isComingSoon && !isTraveler) {
        expect(
          detail.ascensionMaterials,
          isNotEmpty,
          reason: 'Should not be empty (property=ascensionMaterials, key=${character.key})',
        );
        expect(
          detail.talentAscensionMaterials,
          isNotEmpty,
          reason: 'Should not be empty (property=talentAscensionMaterials, key=${character.key})',
        );
      } else if (!detail.isComingSoon && isTraveler) {
        expect(
          detail.multiTalentAscensionMaterials,
          allOf([isNotEmpty, isNotNull]),
          reason: 'Should not be empty (property=multiTalentAscensionMaterials, key=${character.key})',
        );
      }

      if (!detail.isComingSoon) {
        expect(detail.builds, isNotEmpty, reason: 'Should not be empty (property=builds, key=${character.key})');
        expect(
          detail.builds.any((el) => el.isRecommended),
          isTrue,
          reason: 'Should be true (property=isRecommended, key=${character.key}), isTrue)',
        );
        for (final build in detail.builds) {
          expect(
            build.skillPriorities.length,
            inInclusiveRange(1, 3),
            reason: 'Should be within expected range (property=skillPriorities, key=${character.key})',
          );
          expect(
            build.skillPriorities,
            isNotEmpty,
            reason: 'Should not be empty (property=skillPriorities, key=${character.key})',
          );
          for (final priority in build.skillPriorities) {
            expect(
              priority,
              isIn([CharacterSkillType.normalAttack, CharacterSkillType.elementalBurst, CharacterSkillType.elementalSkill]),
              reason: 'Should match expected value (key=${character.key})',
            );
          }
        }

        expect(detail.skills, isNotEmpty, reason: 'Should not be empty (property=skills, key=${character.key})');
        expect(
          detail.skills.length,
          inInclusiveRange(3, 4),
          reason: 'Should be within expected range (property=skills, key=${character.key})',
        );
        expect(detail.passives, isNotEmpty, reason: 'Should not be empty (property=passives, key=${character.key})');
        expect(
          detail.passives.length,
          inInclusiveRange(2, 4),
          reason: 'Should be within expected range (property=passives, key=${character.key})',
        );
        expect(detail.constellations, isNotEmpty, reason: 'Should not be empty (property=constellations, key=${character.key})');
        expect(
          detail.constellations.length,
          6,
          reason: 'Should match expected value (property=constellations, expected=6, key=${character.key})',
        );
        expect(detail.stats, isNotEmpty, reason: 'Should not be empty (property=stats, key=${character.key})');
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
          expect(
            ascMaterial.number,
            inInclusiveRange(1, 3),
            reason: 'Should be within expected range (property=number, key=${character.key})',
          );
          checkCharacterFileTalentAscensionMaterialModel(
            service.materials,
            ascMaterial.materials,
            checkMaterialTypeAndLength: !detail.isComingSoon,
          );
        }
      }

      for (final build in detail.builds) {
        expect(build.weaponKeys, isNotEmpty, reason: 'Should not be empty (property=weaponKeys, key=${character.key})');
        expect(
          build.subStatsToFocus.length,
          greaterThanOrEqualTo(2),
          reason: 'Should be greater than expected (property=subStatsToFocus, key=${character.key})',
        );
        for (final key in build.weaponKeys) {
          final weapon = service.weapons.getWeapon(key);
          expect(
            weapon.type == detail.weaponType,
            isTrue,
            reason: 'Should be true (property=weaponType, characterKey=${character.key}, weaponKey=$key)',
          );
        }

        for (final artifact in build.artifacts) {
          final valid = artifact.oneKey != null || artifact.multiples.isNotEmpty;
          expect(valid, isTrue, reason: 'Should be true (key=${character.key})');
          expect(
            artifact.stats.length,
            equals(ArtifactType.values.length),
            reason: 'Should equal expected value (property=stats, key=${character.key})',
          );
          for (int i = 0; i < artifact.stats.length; i++) {
            final StatType stat = artifact.stats[i];
            final List<StatType> possibleStats = getArtifactPossibleMainStats(ArtifactType.values[i]);
            expect(stat, isIn(possibleStats), reason: 'Should match expected value (key=${character.key})');
          }
          if (artifact.oneKey != null) {
            expect(
              () => service.artifacts.getArtifact(artifact.oneKey!),
              returnsNormally,
              reason: 'Should execute without throwing (characterKey=${character.key}, artifactKey=${artifact.oneKey})',
            );
          } else {
            for (final partial in artifact.multiples) {
              expect(
                () => service.artifacts.getArtifact(partial.key),
                returnsNormally,
                reason: 'Should execute without throwing (characterKey=${character.key}, artifactKey=${partial.key})',
              );
              expect(
                partial.quantity,
                inInclusiveRange(1, 2),
                reason: 'Should be within expected range (property=quantity, key=${character.key})',
              );
            }
          }
        }
      }

      for (final skill in detail.skills) {
        checkKey(skill.key);
        if (!detail.isComingSoon) {
          checkAsset(service.resources.getSkillImagePath(skill.image));
          expect(skill.stats, isNotEmpty, reason: 'Should not be empty (property=stats, key=${character.key})');
          for (final stat in skill.stats) {
            switch (skill.type) {
              case CharacterSkillType.normalAttack:
              case CharacterSkillType.elementalSkill:
              case CharacterSkillType.elementalBurst:
                expect(
                  stat.values.length,
                  15,
                  reason: 'Should match expected value (property=values, expected=15, key=${character.key})',
                );
              case CharacterSkillType.others:
                break;
            }
          }
          final statKeys = skill.stats.map((e) => e.key).toList();
          expect(
            statKeys.toSet().length,
            equals(statKeys.length),
            reason: 'Should equal expected value (property=toSet(), key=${character.key})',
          );
          //check that all the values in the stats have the same length
          final statCount = skill.stats.map((e) => e.values.length).toSet().length;
          expect(statCount, equals(1), reason: 'Should equal expected value (key=${character.key})');
        }

        for (final stat in skill.stats) {
          expect(stat.values, isNotEmpty, reason: 'Should not be empty (key=${character.key})');
        }
      }

      for (final passive in detail.passives) {
        checkKey(passive.key);
        if (!detail.isComingSoon) {
          checkAsset(service.resources.getSkillImagePath(passive.image));
        }

        expect(
          passive.unlockedAt,
          isIn([-2, -1, 1, 4]),
          reason: 'Should match expected value (property=unlockedAt, key=${character.key})',
        );
      }

      for (final constellation in detail.constellations) {
        checkKey(constellation.key);
        if (!detail.isComingSoon) {
          checkAsset(service.resources.getSkillImagePath(constellation.image));
        }
        expect(
          constellation.number,
          inInclusiveRange(1, 6),
          reason: 'Should be within expected range (property=number, key=${character.key})',
        );
      }

      final statAscCount = detail.stats.where((e) => e.isAnAscension).length;
      if (!detail.isComingSoon) {
        expect(statAscCount == 7, isTrue, reason: 'Should be true (key=${character.key})');
      } else {
        expect(statAscCount <= 7, isTrue, reason: 'Should be true (key=${character.key})');
      }
      var repetitionCount = 0;
      for (var i = 0; i < detail.stats.length; i++) {
        final stat = detail.stats[i];
        expect(
          stat.level,
          inInclusiveRange(1, 100),
          reason: 'Should be within expected range (property=level, key=${character.key})',
        );
        expect(stat.baseAtk, greaterThan(0), reason: 'Should be greater than expected (property=baseAtk, key=${character.key})');
        expect(stat.baseHp, greaterThan(0), reason: 'Should be greater than expected (property=baseHp, key=${character.key})');
        expect(stat.baseDef, greaterThan(0), reason: 'Should be greater than expected (property=baseDef, key=${character.key})');
        expect(
          stat.statValue,
          greaterThanOrEqualTo(0),
          reason: 'Should be greater than expected (property=statValue, key=${character.key})',
        );
        if (i > 0 && i < detail.stats.length - 1) {
          final nextStat = detail.stats[i + 1];
          if (nextStat.statValue == stat.statValue) {
            repetitionCount++;
          } else {
            repetitionCount = 0;
          }
          expect(repetitionCount, lessThanOrEqualTo(4), reason: 'Should be less than expected (key=${character.key})');
        }
      }
    }
  });

  group('Birthdays', () {
    void checkBirthday(CharacterBirthdayModel birthday) {
      checkItemKeyNameAndImage(birthday.key, birthday.name, birthday.image);

      final DateTime now = DateTime.now().getStartingDate();
      expect(birthday.birthday.isAfterInclusive(now), isTrue, reason: 'Should be true (property=isAfterInclusive(now))');
      expect(
        birthday.birthdayString.isNotNullEmptyOrWhitespace,
        isTrue,
        reason: 'Should be true (property=isNotNullEmptyOrWhitespace)',
      );
      if (birthday.birthday != now) {
        expect(birthday.daysUntilBirthday > 0, isTrue, reason: 'Should be true (property=daysUntilBirthday > 0, isTrue)');
      } else {
        expect(birthday.daysUntilBirthday, isZero, reason: 'Should match expected value (property=daysUntilBirthday)');
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
        expect(
          chars.any((el) => el.key == key),
          false,
          reason: 'Should match expected value (property=key == key, key=$key), false)',
        );
      }
    });

    test('by month', () {
      final months = List.generate(DateTime.monthsPerYear, (index) => index + 1);
      for (final month in months) {
        final birthdays = service.getCharacterBirthdays(month: month);
        expect(birthdays.isNotEmpty, isTrue, reason: 'Should be true');
        for (final birthday in birthdays) {
          checkBirthday(birthday);
        }
      }
    });

    test('by day', () {
      final birthdays = service.getCharacterBirthdays(day: 20);
      expect(birthdays.isNotEmpty, isTrue, reason: 'Should be true');
      for (final birthday in birthdays) {
        checkBirthday(birthday);
      }
    });

    test('by month and day', () {
      final birthdays = service.getCharacterBirthdays(month: DateTime.november, day: 20);
      expect(birthdays.length, 2, reason: 'Should match expected value (expected=2)');
      final charKeys = ['keqing', 'prune'];
      expect(birthdays.map((b) => b.key).toList(), containsAll(charKeys), reason: 'Should equal expected value (property=key)');
      for (final birthday in birthdays) {
        checkBirthday(birthday);
      }
    });

    test('invalid month and day', () {
      expect(
        () => service.getCharacterBirthdays(),
        throwsA(predicate<ArgumentError>((e) => e.toString().toLowerCase().contains('must provide'))),
        reason: 'Should contain expected value',
      );
      expect(
        () => service.getCharacterBirthdays(month: -1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'month')),
        reason: 'Should throw expected exception',
      );
      expect(
        () => service.getCharacterBirthdays(day: -1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'day')),
        reason: 'Should throw expected exception',
      );
      expect(
        () => service.getCharacterBirthdays(month: DateTime.february, day: 31),
        throwsA(predicate<ArgumentError>((e) => e.name == 'day')),
        reason: 'Should throw expected exception',
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
      expect(defaultTierList.length, equals(7), reason: 'Should equal expected value');

      final charCountInTierList = defaultTierList.expand((el) => el.items).length;
      final charCount = service.getCharactersForCard().where((el) => !el.isComingSoon).length;
      expect(charCountInTierList == charCount, isTrue, reason: 'Should be true');

      for (var i = 0; i < defaultColors.length; i++) {
        final tierRow = defaultTierList[i];
        expect(tierRow.tierText, allOf([isNotNull, isNotEmpty]), reason: 'Should not be empty (property=tierText)');
        expect(tierRow.items, isNotEmpty, reason: 'Should not be empty (property=items)');
        expect(tierRow.tierColor, equals(defaultColors[i]), reason: 'Should equal expected value (property=tierColor)');

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
      expect(materials, isNotEmpty, reason: 'Should not be empty');
      for (final material in materials) {
        checkKey(material.key);
        checkAsset(material.image);
        expect(material.name, allOf([isNotNull, isNotEmpty]), reason: 'Should not be empty (property=name)');
        final List<String> ignore = [
          'teachings-of-vagrancy',
          'teachings-of-elysium',
          'teachings-of-moonlight',
        ];
        if (ignore.contains(material.key)) {
          continue;
        }
        expect(material.characters, isNotEmpty, reason: 'Should not be empty (property=characters)');
        expect(material.days, isNotEmpty, reason: 'Should not be empty (property=days)');
        for (final item in material.characters) {
          checkItemCommonWithName(item);
        }
        final travelerExists = material.characters.where((el) => isTheTraveler(el.key)).isNotEmpty;
        expect(travelerExists, isTrue, reason: 'Should be true');
      }

      if (day == DateTime.sunday) {
        final allCharacters = service.getCharactersForCard();
        final notComingSoon = allCharacters.where((el) => !el.isComingSoon).length;
        final got = materials.expand((el) => el.characters).map((e) => e.key).toSet().length;
        expect(notComingSoon, equals(got), reason: 'Should equal expected value');
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
        expect(items.length, expectedCount, reason: 'Should match expected value');

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });

    test('invalid region', () {
      expect(
        () => service.getCharactersForItemsByRegion(RegionType.anotherWorld),
        throwsA(isA<OperationNotSupportedError>()),
        reason: 'Should be of expected type',
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
        expect(items.length, expectedCount, reason: 'Should match expected value');

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });

    test('invalid region', () {
      expect(
        () => service.getCharactersForItemsByRegionAndGender(RegionType.anotherWorld, true),
        throwsA(isA<OperationNotSupportedError>()),
        reason: 'Should be of expected type',
      );
      expect(
        () => service.getCharactersForItemsByRegionAndGender(RegionType.anotherWorld, false),
        throwsA(isA<OperationNotSupportedError>()),
        reason: 'Should be of expected type',
      );
    });
  });

  test('Get character regions', () {
    final regions = service.getCharacterRegionsForCharts();
    expect(regions.isNotEmpty, isTrue, reason: 'Should be true');
    expect(
      regions.map((e) => e.regionType).toSet().length,
      RegionType.values.length - 1,
      reason: 'Should match expected value (property=length - 1)',
    );

    final characters = service
        .getCharactersForCard()
        .where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld)
        .toList();
    for (final region in regions) {
      expect(region.regionType != RegionType.anotherWorld, isTrue, reason: 'Should be true (property=anotherWorld)');
      expect(
        region.quantity,
        characters.where((el) => el.regionType == region.regionType).length,
        reason: 'Should match expected value (property=quantity)',
      );
    }
  });

  test('Get character genders', () {
    final genders = service.getCharacterGendersForCharts();
    expect(genders.isNotEmpty, isTrue, reason: 'Should be true');
    expect(
      genders.map((e) => e.regionType).toSet().length,
      RegionType.values.length - 1,
      reason: 'Should match expected value (property=length - 1)',
    );

    final characters = service
        .getCharactersForCard()
        .where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld)
        .toList();
    for (final gender in genders) {
      validateChartGenderModel(gender);

      final expectedCount = characters.where((el) => el.regionType == gender.regionType).length;
      expect(gender.maleCount + gender.femaleCount, expectedCount, reason: 'Should match expected value (property=femaleCount)');
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
        expect(
          gender.maleCount + gender.femaleCount,
          expectedCount,
          reason: 'Should match expected value (property=femaleCount)',
        );
      }
    });

    test('invalid region', () {
      expect(
        () => service.getCharacterGendersByRegionForCharts(RegionType.anotherWorld),
        throwsA(isA<OperationNotSupportedError>()),
        reason: 'Should be of expected type',
      );
    });
  });

  test('Get character birthdays for charts', () {
    final birthdays = service.getCharacterBirthdaysForCharts();
    expect(birthdays.isNotEmpty, isTrue, reason: 'Should be true');
    expect(birthdays.length, 12, reason: 'Should match expected value (expected=12)');

    final keys = birthdays.expand((el) => el.items).map((e) => e.key).toList();
    expect(keys.length, keys.toSet().length, reason: 'Should match expected value');

    final charCount = service.getCharactersForCard().where((el) => !isTheTraveler(el.key) && !el.isComingSoon).length;
    expect(keys.length, charCount, reason: 'Should match expected value');

    final allMonths = List.generate(DateTime.monthsPerYear, (index) => index + 1);
    for (final monthBirthdays in birthdays) {
      expect(monthBirthdays.month, isIn(allMonths), reason: 'Should match expected value (property=month)');
      for (final birthday in monthBirthdays.items) {
        checkItemCommonWithName(birthday);
      }
    }
  });
}
