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
    expect(
      gender.femaleCount,
      greaterThanOrEqualTo(0),
      reason: 'Gender chart female count must be non-negative, got ${gender.femaleCount} '
          '(region=${gender.regionType.name})',
    );
    expect(
      gender.maleCount,
      greaterThanOrEqualTo(0),
      reason: 'Gender chart male count must be non-negative, got ${gender.maleCount} '
          '(region=${gender.regionType.name})',
    );
    expect(
      gender.regionType,
      isNot(RegionType.anotherWorld),
      reason: 'Gender chart must not include the anotherWorld region (region=${gender.regionType.name})',
    );
    if (gender.femaleCount > 0 || gender.maleCount > 0) {
      expect(
        gender.maxCount,
        max(gender.femaleCount, gender.maleCount),
        reason: 'Gender chart maxCount must equal max(female=${gender.femaleCount}, male=${gender.maleCount}), '
            'got ${gender.maxCount} (region=${gender.regionType.name})',
      );
    } else {
      expect(
        gender.maxCount,
        0,
        reason: 'Gender chart maxCount must be 0 when there are no characters, got ${gender.maxCount} '
            '(region=${gender.regionType.name})',
      );
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
          checkKey(char.key, ownerKey: char.key);
          expect(
            char.name,
            allOf([isNotEmpty, isNotNull]),
            reason: 'Character name is empty or malformed (key=${char.key}, lang=${lang.name})',
          );
          checkAsset(char.image, ownerKey: char.key);
          checkAsset(char.iconImage, ownerKey: char.key);
          expect(
            char.stars,
            allOf([greaterThanOrEqualTo(4), lessThanOrEqualTo(5)]),
            reason: 'Character rarity must be 4–5 stars, got ${char.stars} (key=${char.key})',
          );
          if (char.isNew || char.isComingSoon) {
            expect(
              char.isNew,
              isNot(char.isComingSoon),
              reason: 'Character cannot be both isNew and isComingSoon at once (key=${char.key})',
            );
          }

          if (!char.isComingSoon) {
            expect(
              char.materials,
              isNotEmpty,
              reason: 'Released character has no ascension materials (key=${char.key})',
            );
            final expected = materialImgs.where((el) => char.materials.contains(el)).length;
            expect(
              char.materials.length,
              equals(expected),
              reason: 'Character materials must all resolve to known material images, '
                  'got ${char.materials.length} but only $expected matched (key=${char.key})',
            );
          }
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getCharacterFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final characters = service.getCharactersForCard();
      expect(
        characters.isEmpty,
        isTrue,
        reason: 'With no resources downloaded, characters for card must be empty, got ${characters.length}',
      );
    });
  });

  test('Get character', () {
    final localeService = getLocaleService(AppLanguageType.english);
    final characters = service.getCharactersForCard();
    for (final character in characters) {
      final detail = service.getCharacter(character.key);
      final isTraveler = isTheTraveler(character.key);
      checkKey(detail.key, ownerKey: detail.key);
      expect(
        detail.rarity,
        character.stars,
        reason: 'Character rarity mismatch between card and detail: ${detail.rarity} vs ${character.stars} '
            '(key=${character.key})',
      );
      expect(
        detail.weaponType,
        character.weaponType,
        reason: 'Character weapon type mismatch between card and detail: ${detail.weaponType} vs '
            '${character.weaponType} (key=${character.key})',
      );
      expect(
        detail.elementType,
        character.elementType,
        reason: 'Character element type mismatch between card and detail: ${detail.elementType} vs '
            '${character.elementType} (key=${character.key})',
      );
      checkAsset(service.resources.getCharacterImagePath(detail.image), ownerKey: detail.key);
      checkAsset(service.resources.getCharacterIconImagePath(detail.iconImage), ownerKey: detail.key);
      checkAsset(service.resources.getCharacterFullImagePath(detail.fullImage), ownerKey: detail.key);
      expect(
        detail.region,
        character.regionType,
        reason: 'Character region mismatch between card and detail: ${detail.region} vs ${character.regionType} '
            '(key=${character.key})',
      );
      expect(
        detail.role,
        character.roleType,
        reason: 'Character role mismatch between card and detail: ${detail.role} vs ${character.roleType} '
            '(key=${character.key})',
      );
      expect(
        detail.isComingSoon,
        character.isComingSoon,
        reason: 'Character isComingSoon mismatch between card and detail: ${detail.isComingSoon} vs '
            '${character.isComingSoon} (key=${character.key})',
      );
      expect(
        detail.isNew,
        character.isNew,
        reason: 'Character isNew mismatch between card and detail: ${detail.isNew} vs ${character.isNew} '
            '(key=${character.key})',
      );
      if (!detail.isComingSoon) {
        expect(
          detail.tier,
          isIn(['d', 'c', 'b', 'a', 's', 'ss', 'sss']),
          reason: 'Character tier "${detail.tier}" is not a valid tier value (key=${character.key})',
        );
      }

      if (isTraveler) {
        checkAsset(service.resources.getCharacterFullImagePath(detail.secondFullImage!), ownerKey: detail.key);
      } else {
        expect(
          detail.birthday,
          allOf([isNotNull, isNotEmpty]),
          reason: 'Non-traveler character is missing a birthday (key=${character.key})',
        );

        //eg: 09/14
        expect(
          detail.birthday!.length,
          equals(5),
          reason: 'Character birthday must be formatted as MM/DD (5 chars), got "${detail.birthday}" '
              '(key=${character.key})',
        );

        expect(
          () => localeService.getCharBirthDate(detail.birthday),
          returnsNormally,
          reason: 'Character birthday "${detail.birthday}" could not be parsed into a date (key=${character.key})',
        );
      }

      if (!detail.isComingSoon && !isTraveler) {
        expect(
          detail.ascensionMaterials,
          isNotEmpty,
          reason: 'Released non-traveler character has no ascension materials (key=${character.key})',
        );
        expect(
          detail.talentAscensionMaterials,
          isNotEmpty,
          reason: 'Released non-traveler character has no talent ascension materials (key=${character.key})',
        );
      } else if (!detail.isComingSoon && isTraveler) {
        expect(
          detail.multiTalentAscensionMaterials,
          allOf([isNotEmpty, isNotNull]),
          reason: 'Released traveler has no multi-talent ascension materials (key=${character.key})',
        );
      }

      if (!detail.isComingSoon) {
        expect(
          detail.builds,
          isNotEmpty,
          reason: 'Released character has no recommended builds (key=${character.key})',
        );
        expect(
          detail.builds.any((el) => el.isRecommended),
          isTrue,
          reason: 'Released character has no build flagged as recommended (key=${character.key})',
        );
        for (final build in detail.builds) {
          expect(
            build.skillPriorities.length,
            inInclusiveRange(1, 3),
            reason: 'Build must prioritise 1–3 skills, got ${build.skillPriorities.length} (key=${character.key})',
          );
          expect(
            build.skillPriorities,
            isNotEmpty,
            reason: 'Build has no skill priorities (key=${character.key})',
          );
          for (final priority in build.skillPriorities) {
            expect(
              priority,
              isIn([CharacterSkillType.normalAttack, CharacterSkillType.elementalBurst, CharacterSkillType.elementalSkill]),
              reason: 'Build skill priority "${priority.name}" is not a prioritisable skill type '
                  '(key=${character.key})',
            );
          }
        }

        expect(detail.skills, isNotEmpty, reason: 'Released character has no skills (key=${character.key})');
        expect(
          detail.skills.length,
          inInclusiveRange(3, 4),
          reason: 'Character must have 3–4 skills, got ${detail.skills.length} (key=${character.key})',
        );
        expect(detail.passives, isNotEmpty, reason: 'Released character has no passives (key=${character.key})');
        expect(
          detail.passives.length,
          inInclusiveRange(2, 4),
          reason: 'Character must have 2–4 passives, got ${detail.passives.length} (key=${character.key})',
        );
        expect(
          detail.constellations,
          isNotEmpty,
          reason: 'Released character has no constellations (key=${character.key})',
        );
        expect(
          detail.constellations.length,
          6,
          reason: 'Character must have exactly 6 constellations, got ${detail.constellations.length} '
              '(key=${character.key})',
        );
        expect(detail.stats, isNotEmpty, reason: 'Released character has no stats (key=${character.key})');
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
            reason: 'Traveler multi-talent number must be 1–3, got ${ascMaterial.number} (key=${character.key})',
          );
          checkCharacterFileTalentAscensionMaterialModel(
            service.materials,
            ascMaterial.materials,
            checkMaterialTypeAndLength: !detail.isComingSoon,
          );
        }
      }

      for (final build in detail.builds) {
        expect(build.weaponKeys, isNotEmpty, reason: 'Build recommends no weapons (key=${character.key})');
        expect(
          build.subStatsToFocus.length,
          greaterThanOrEqualTo(2),
          reason: 'Build must focus at least 2 sub-stats, got ${build.subStatsToFocus.length} (key=${character.key})',
        );
        for (final key in build.weaponKeys) {
          final weapon = service.weapons.getWeapon(key);
          expect(
            weapon.type,
            detail.weaponType,
            reason: 'Build weapon "$key" type ${weapon.type} does not match character weapon type '
                '${detail.weaponType} (characterKey=${character.key})',
          );
        }

        for (final artifact in build.artifacts) {
          final valid = artifact.oneKey != null || artifact.multiples.isNotEmpty;
          expect(
            valid,
            isTrue,
            reason: 'Build artifact set must specify either a single set (oneKey) or multiples, but has neither '
                '(key=${character.key})',
          );
          expect(
            artifact.stats.length,
            equals(ArtifactType.values.length),
            reason: 'Build artifact must define a main stat per artifact slot (${ArtifactType.values.length}), '
                'got ${artifact.stats.length} (key=${character.key})',
          );
          for (int i = 0; i < artifact.stats.length; i++) {
            final StatType stat = artifact.stats[i];
            final List<StatType> possibleStats = getArtifactPossibleMainStats(ArtifactType.values[i]);
            expect(
              stat,
              isIn(possibleStats),
              reason: 'Main stat ${stat.name} is not valid for artifact slot ${ArtifactType.values[i].name} '
                  '(key=${character.key})',
            );
          }
          if (artifact.oneKey != null) {
            expect(
              () => service.artifacts.getArtifact(artifact.oneKey!),
              returnsNormally,
              reason: 'Build references artifact set "${artifact.oneKey}" that does not exist in the artifacts file '
                  '(characterKey=${character.key})',
            );
          } else {
            for (final partial in artifact.multiples) {
              expect(
                () => service.artifacts.getArtifact(partial.key),
                returnsNormally,
                reason: 'Build references artifact set "${partial.key}" that does not exist in the artifacts file '
                    '(characterKey=${character.key})',
              );
              expect(
                partial.quantity,
                inInclusiveRange(1, 2),
                reason: 'Partial artifact set piece quantity must be 1–2, got ${partial.quantity} '
                    '(characterKey=${character.key}, artifactKey=${partial.key})',
              );
            }
          }
        }
      }

      for (final skill in detail.skills) {
        checkKey(skill.key, ownerKey: character.key);
        if (!detail.isComingSoon) {
          checkAsset(service.resources.getSkillImagePath(skill.image), ownerKey: character.key);
          expect(skill.stats, isNotEmpty, reason: 'Skill "${skill.key}" has no stats (key=${character.key})');
          for (final stat in skill.stats) {
            switch (skill.type) {
              case CharacterSkillType.normalAttack:
              case CharacterSkillType.elementalSkill:
              case CharacterSkillType.elementalBurst:
                expect(
                  stat.values.length,
                  15,
                  reason: 'Combat skill stat must have 15 level values, got ${stat.values.length} '
                      '(skillKey=${skill.key}, key=${character.key})',
                );
              case CharacterSkillType.others:
                break;
            }
          }
          final statKeys = skill.stats.map((e) => e.key).toList();
          expect(
            statKeys.toSet().length,
            equals(statKeys.length),
            reason: 'Skill "${skill.key}" has duplicate stat keys (key=${character.key})',
          );
          //check that all the values in the stats have the same length
          final statCount = skill.stats.map((e) => e.values.length).toSet().length;
          expect(
            statCount,
            equals(1),
            reason: 'Skill "${skill.key}" stats have inconsistent value-list lengths (key=${character.key})',
          );
        }

        for (final stat in skill.stats) {
          expect(
            stat.values,
            isNotEmpty,
            reason: 'Skill "${skill.key}" stat "${stat.key}" has no values (key=${character.key})',
          );
        }
      }

      for (final passive in detail.passives) {
        checkKey(passive.key, ownerKey: character.key);
        if (!detail.isComingSoon) {
          checkAsset(service.resources.getSkillImagePath(passive.image), ownerKey: character.key);
        }

        expect(
          passive.unlockedAt,
          isIn([-2, -1, 1, 4]),
          reason: 'Passive "${passive.key}" unlockedAt must be one of [-2,-1,1,4], got ${passive.unlockedAt} '
              '(key=${character.key})',
        );
      }

      for (final constellation in detail.constellations) {
        checkKey(constellation.key, ownerKey: character.key);
        if (!detail.isComingSoon) {
          checkAsset(service.resources.getSkillImagePath(constellation.image), ownerKey: character.key);
        }
        expect(
          constellation.number,
          inInclusiveRange(1, 6),
          reason: 'Constellation number must be 1–6, got ${constellation.number} (key=${character.key})',
        );
      }

      final statAscCount = detail.stats.where((e) => e.isAnAscension).length;
      if (!detail.isComingSoon) {
        expect(
          statAscCount,
          7,
          reason: 'Released character must have exactly 7 ascension stat rows, got $statAscCount '
              '(key=${character.key})',
        );
      } else {
        expect(
          statAscCount,
          lessThanOrEqualTo(7),
          reason: 'Upcoming character must have at most 7 ascension stat rows, got $statAscCount '
              '(key=${character.key})',
        );
      }
      var repetitionCount = 0;
      for (var i = 0; i < detail.stats.length; i++) {
        final stat = detail.stats[i];
        expect(
          stat.level,
          inInclusiveRange(1, 100),
          reason: 'Character stat level must be 1–100, got ${stat.level} (key=${character.key})',
        );
        expect(
          stat.baseAtk,
          greaterThan(0),
          reason: 'Character stat baseAtk must be positive, got ${stat.baseAtk} (level=${stat.level}, '
              'key=${character.key})',
        );
        expect(
          stat.baseHp,
          greaterThan(0),
          reason: 'Character stat baseHp must be positive, got ${stat.baseHp} (level=${stat.level}, '
              'key=${character.key})',
        );
        expect(
          stat.baseDef,
          greaterThan(0),
          reason: 'Character stat baseDef must be positive, got ${stat.baseDef} (level=${stat.level}, '
              'key=${character.key})',
        );
        expect(
          stat.statValue,
          greaterThanOrEqualTo(0),
          reason: 'Character stat value must be non-negative, got ${stat.statValue} (level=${stat.level}, '
              'key=${character.key})',
        );
        if (i > 0 && i < detail.stats.length - 1) {
          final nextStat = detail.stats[i + 1];
          if (nextStat.statValue == stat.statValue) {
            repetitionCount++;
          } else {
            repetitionCount = 0;
          }
          expect(
            repetitionCount,
            lessThanOrEqualTo(4),
            reason: 'Character stat value ${stat.statValue} repeats more than 4 times consecutively '
                '(key=${character.key})',
          );
        }
      }
    }
  });

  group('Birthdays', () {
    void checkBirthday(CharacterBirthdayModel birthday) {
      checkItemKeyNameAndImage(birthday.key, birthday.name, birthday.image);

      final DateTime now = DateTime.now().getStartingDate();
      expect(
        birthday.birthday.isAfterInclusive(now),
        isTrue,
        reason: 'Birthday date ${birthday.birthday} must be today or later (key=${birthday.key})',
      );
      expect(
        birthday.birthdayString.isNotNullEmptyOrWhitespace,
        isTrue,
        reason: 'Birthday display string is empty or whitespace (key=${birthday.key})',
      );
      if (birthday.birthday != now) {
        expect(
          birthday.daysUntilBirthday,
          greaterThan(0),
          reason: 'A future birthday must have days-until > 0, got ${birthday.daysUntilBirthday} (key=${birthday.key})',
        );
      } else {
        expect(
          birthday.daysUntilBirthday,
          isZero,
          reason: 'A birthday that is today must have 0 days-until, got ${birthday.daysUntilBirthday} '
              '(key=${birthday.key})',
        );
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
          reason: 'Upcoming character "$key" must not appear in the birthday list for its birth date',
        );
      }
    });

    test('by month', () {
      final months = List.generate(DateTime.monthsPerYear, (index) => index + 1);
      for (final month in months) {
        final birthdays = service.getCharacterBirthdays(month: month);
        expect(birthdays.isNotEmpty, isTrue, reason: 'No character birthdays found for month=$month');
        for (final birthday in birthdays) {
          checkBirthday(birthday);
        }
      }
    });

    test('by day', () {
      final birthdays = service.getCharacterBirthdays(day: 20);
      expect(birthdays.isNotEmpty, isTrue, reason: 'No character birthdays found for day=20');
      for (final birthday in birthdays) {
        checkBirthday(birthday);
      }
    });

    test('by month and day', () {
      final birthdays = service.getCharacterBirthdays(month: DateTime.november, day: 20);
      expect(birthdays.length, 2, reason: 'Expected exactly 2 birthdays on Nov 20, got ${birthdays.length}');
      final charKeys = ['keqing', 'prune'];
      expect(
        birthdays.map((b) => b.key).toList(),
        containsAll(charKeys),
        reason: 'Nov 20 birthdays must include $charKeys, got ${birthdays.map((b) => b.key).toList()}',
      );
      for (final birthday in birthdays) {
        checkBirthday(birthday);
      }
    });

    test('invalid month and day', () {
      expect(
        () => service.getCharacterBirthdays(),
        throwsA(predicate<ArgumentError>((e) => e.toString().toLowerCase().contains('must provide'))),
        reason: 'Calling getCharacterBirthdays with neither month nor day must throw a "must provide" ArgumentError',
      );
      expect(
        () => service.getCharacterBirthdays(month: -1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'month')),
        reason: 'A negative month must throw an ArgumentError naming "month"',
      );
      expect(
        () => service.getCharacterBirthdays(day: -1),
        throwsA(predicate<ArgumentError>((e) => e.name == 'day')),
        reason: 'A negative day must throw an ArgumentError naming "day"',
      );
      expect(
        () => service.getCharacterBirthdays(month: DateTime.february, day: 31),
        throwsA(predicate<ArgumentError>((e) => e.name == 'day')),
        reason: 'Feb 31 (impossible date) must throw an ArgumentError naming "day"',
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
      expect(
        defaultTierList.length,
        equals(7),
        reason: 'Default tier list must have 7 rows (one per color), got ${defaultTierList.length}',
      );

      final charCountInTierList = defaultTierList.expand((el) => el.items).length;
      final charCount = service.getCharactersForCard().where((el) => !el.isComingSoon).length;
      expect(
        charCountInTierList,
        charCount,
        reason: 'Default tier list must contain every released character: got $charCountInTierList, '
            'expected $charCount',
      );

      for (var i = 0; i < defaultColors.length; i++) {
        final tierRow = defaultTierList[i];
        expect(tierRow.tierText, allOf([isNotNull, isNotEmpty]), reason: 'Tier row $i has empty tier text');
        expect(tierRow.items, isNotEmpty, reason: 'Tier row "${tierRow.tierText}" has no characters');
        expect(
          tierRow.tierColor,
          equals(defaultColors[i]),
          reason: 'Tier row $i color ${tierRow.tierColor} does not match expected ${defaultColors[i]}',
        );

        for (final item in tierRow.items) {
          checkKey(item.key, ownerKey: item.key);
          checkAsset(item.image, ownerKey: item.key);
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
      expect(materials, isNotEmpty, reason: 'No character ascension materials found for day=$day');
      for (final material in materials) {
        checkKey(material.key, ownerKey: material.key);
        checkAsset(material.image, ownerKey: material.key);
        expect(
          material.name,
          allOf([isNotNull, isNotEmpty]),
          reason: 'Ascension material name is empty or malformed (key=${material.key})',
        );
        final List<String> ignore = [
          'teachings-of-vagrancy',
          'teachings-of-elysium',
          'teachings-of-moonlight',
        ];
        if (ignore.contains(material.key)) {
          continue;
        }
        expect(
          material.characters,
          isNotEmpty,
          reason: 'Ascension material "${material.key}" has no characters using it',
        );
        expect(material.days, isNotEmpty, reason: 'Ascension material "${material.key}" has no availability days');
        for (final item in material.characters) {
          checkItemCommonWithName(item);
        }
        final travelerExists = material.characters.where((el) => isTheTraveler(el.key)).isNotEmpty;
        expect(
          travelerExists,
          isTrue,
          reason: 'Ascension material "${material.key}" is expected to include the Traveler among its characters',
        );
      }

      if (day == DateTime.sunday) {
        final allCharacters = service.getCharactersForCard();
        final notComingSoon = allCharacters.where((el) => !el.isComingSoon).length;
        final got = materials.expand((el) => el.characters).map((e) => e.key).toSet().length;
        expect(
          got,
          equals(notComingSoon),
          reason: 'Sunday ascension materials must cover every released character: got $got, expected $notComingSoon',
        );
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
        expect(
          items.length,
          expectedCount,
          reason: 'Region ${region.name} character count mismatch: got ${items.length}, expected $expectedCount',
        );

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });

    test('invalid region', () {
      expect(
        () => service.getCharactersForItemsByRegion(RegionType.anotherWorld),
        throwsA(isA<OperationNotSupportedError>()),
        reason: 'Querying characters for the anotherWorld region must throw OperationNotSupportedError',
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
        expect(
          items.length,
          expectedCount,
          reason: 'Region ${region.name} male+female character count mismatch: got ${items.length}, '
              'expected $expectedCount',
        );

        for (final item in items) {
          checkItemCommonWithName(item);
        }
      }
    });

    test('invalid region', () {
      expect(
        () => service.getCharactersForItemsByRegionAndGender(RegionType.anotherWorld, true),
        throwsA(isA<OperationNotSupportedError>()),
        reason: 'Querying female characters for the anotherWorld region must throw OperationNotSupportedError',
      );
      expect(
        () => service.getCharactersForItemsByRegionAndGender(RegionType.anotherWorld, false),
        throwsA(isA<OperationNotSupportedError>()),
        reason: 'Querying male characters for the anotherWorld region must throw OperationNotSupportedError',
      );
    });
  });

  test('Get character regions', () {
    final regions = service.getCharacterRegionsForCharts();
    expect(regions.isNotEmpty, isTrue, reason: 'Character region chart data is empty');
    expect(
      regions.map((e) => e.regionType).toSet().length,
      RegionType.values.length - 1,
      reason: 'Region chart must cover all regions except anotherWorld '
          '(${RegionType.values.length - 1}), got ${regions.map((e) => e.regionType).toSet().length}',
    );

    final characters = service
        .getCharactersForCard()
        .where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld)
        .toList();
    for (final region in regions) {
      expect(
        region.regionType,
        isNot(RegionType.anotherWorld),
        reason: 'Region chart must not include the anotherWorld region',
      );
      expect(
        region.quantity,
        characters.where((el) => el.regionType == region.regionType).length,
        reason: 'Region ${region.regionType.name} chart quantity ${region.quantity} does not match '
            'the actual character count',
      );
    }
  });

  test('Get character genders', () {
    final genders = service.getCharacterGendersForCharts();
    expect(genders.isNotEmpty, isTrue, reason: 'Character gender chart data is empty');
    expect(
      genders.map((e) => e.regionType).toSet().length,
      RegionType.values.length - 1,
      reason: 'Gender chart must cover all regions except anotherWorld '
          '(${RegionType.values.length - 1}), got ${genders.map((e) => e.regionType).toSet().length}',
    );

    final characters = service
        .getCharactersForCard()
        .where((el) => !el.isComingSoon && el.regionType != RegionType.anotherWorld)
        .toList();
    for (final gender in genders) {
      validateChartGenderModel(gender);

      final expectedCount = characters.where((el) => el.regionType == gender.regionType).length;
      expect(
        gender.maleCount + gender.femaleCount,
        expectedCount,
        reason: 'Region ${gender.regionType.name} male+female total does not match character count: '
            'got ${gender.maleCount + gender.femaleCount}, expected $expectedCount',
      );
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
          reason: 'Region ${region.name} male+female total does not match character count: '
              'got ${gender.maleCount + gender.femaleCount}, expected $expectedCount',
        );
      }
    });

    test('invalid region', () {
      expect(
        () => service.getCharacterGendersByRegionForCharts(RegionType.anotherWorld),
        throwsA(isA<OperationNotSupportedError>()),
        reason: 'Querying gender chart for the anotherWorld region must throw OperationNotSupportedError',
      );
    });
  });

  test('Get character birthdays for charts', () {
    final birthdays = service.getCharacterBirthdaysForCharts();
    expect(birthdays.isNotEmpty, isTrue, reason: 'Character birthday chart data is empty');
    expect(birthdays.length, 12, reason: 'Birthday chart must have 12 month buckets, got ${birthdays.length}');

    final keys = birthdays.expand((el) => el.items).map((e) => e.key).toList();
    expect(
      keys.toSet().length,
      keys.length,
      reason: 'Birthday chart contains duplicate character keys',
    );

    final charCount = service.getCharactersForCard().where((el) => !isTheTraveler(el.key) && !el.isComingSoon).length;
    expect(
      keys.length,
      charCount,
      reason: 'Birthday chart must include every released non-traveler character: got ${keys.length}, '
          'expected $charCount',
    );

    final allMonths = List.generate(DateTime.monthsPerYear, (index) => index + 1);
    for (final monthBirthdays in birthdays) {
      expect(
        monthBirthdays.month,
        isIn(allMonths),
        reason: 'Birthday chart bucket has invalid month ${monthBirthdays.month}',
      );
      for (final birthday in monthBirthdays.items) {
        checkItemCommonWithName(birthday);
      }
    }
  });
}
