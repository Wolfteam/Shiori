import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  test('Check for characters', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getCharacterFileService(lang);

      final characters = service.getCharactersForCard();

      for (final character in characters) {
        final detail = service.getCharacter(character.key);
        final translation = service.translations.getCharacterTranslation(character.key);
        checkKey(translation.key);
        checkTranslation(translation.name, canBeNull: false);
        if (!detail.isComingSoon) {
          checkTranslation(translation.description, canBeNull: false);
        }

        expect(translation.skills, isNotEmpty, reason: 'Should not be empty (property=skills, key=${character.key}, lang=${lang.name})');
        expect(translation.skills.length, equals(detail.skills.length), reason: 'Should equal expected value (property=skills, key=${character.key}, lang=${lang.name})');
        expect(translation.passives, isNotEmpty, reason: 'Should not be empty (property=passives, key=${character.key}, lang=${lang.name})');
        expect(translation.passives.length, equals(detail.passives.length), reason: 'Should equal expected value (property=passives, key=${character.key}, lang=${lang.name})');
        expect(translation.constellations, isNotEmpty, reason: 'Should not be empty (property=constellations, key=${character.key}, lang=${lang.name})');
        expect(translation.constellations.length, equals(detail.constellations.length), reason: 'Should equal expected value (property=constellations, key=${character.key}, lang=${lang.name})');

        checkKeys(translation.skills.map((e) => e.key).toList());
        checkKeys(translation.passives.map((e) => e.key).toList());
        checkKeys(translation.constellations.map((e) => e.key).toList());

        for (var i = 0; i < translation.skills.length; i++) {
          final skill = translation.skills[i];
          checkKey(skill.key);
          expect(skill.key, isIn(detail.skills.map((e) => e.key).toList()), reason: 'Should match expected value (property=key, characterKey=${character.key}, lang=${lang.name})');
          checkTranslation(skill.title, canBeNull: false);
          if (detail.isComingSoon) {
            continue;
          }
          expect(skill.stats, isNotEmpty, reason: 'Should not be empty (property=stats, key=${character.key}, lang=${lang.name})');
          for (final ability in skill.abilities) {
            final oneAtLeast =
                ability.name.isNotNullEmptyOrWhitespace ||
                ability.description.isNotNullEmptyOrWhitespace ||
                ability.secondDescription.isNotNullEmptyOrWhitespace;

            if (!oneAtLeast) {
              expect(ability.descriptions, isNotEmpty, reason: 'Should not be empty (property=descriptions, key=${character.key}, lang=${lang.name})');
              for (final desc in ability.descriptions) {
                checkTranslation(desc, canBeNull: false);
              }
            }
          }

          final stats = service.getCharacterSkillStats(detail.skills[i].stats, skill.stats);
          expect(stats, isNotEmpty, reason: 'Should not be empty (key=${character.key}, lang=${lang.name})');
          switch (detail.skills[i].type) {
            case CharacterSkillType.normalAttack:
            case CharacterSkillType.elementalSkill:
            case CharacterSkillType.elementalBurst:
              expect(stats.length, 15, reason: 'Should match expected value (expected=15, key=${character.key}, lang=${lang.name})');
            case CharacterSkillType.others:
              break;
          }
          final hasPendingParam = stats.expand((el) => el.descriptions).any((el) => el.contains('param'));
          expect(hasPendingParam, equals(false), reason: 'Should equal expected value (key=${character.key}, lang=${lang.name})');

          for (final stat in stats) {
            for (final description in stat.descriptions) {
              checkTranslation(description);
            }
          }
        }

        for (final passive in translation.passives) {
          checkKey(passive.key);
          expect(passive.key, isIn(detail.passives.map((e) => e.key).toList()), reason: 'Should match expected value (property=key, characterKey=${character.key}, lang=${lang.name})');
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
          expect(constellation.key, isIn(detail.constellations.map((e) => e.key).toList()), reason: 'Should match expected value (property=key, characterKey=${character.key}, lang=${lang.name})');
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

  test('Check for weapons', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getWeaponFileService(lang);
      final weapons = service.getWeaponsForCard();
      for (final weapon in weapons) {
        final detail = service.getWeapon(weapon.key);
        final translation = service.translations.getWeaponTranslation(weapon.key);
        checkKey(translation.key);
        checkTranslation(translation.name, canBeNull: false, checkParamX: false);
        checkTranslation(translation.description, canBeNull: false, checkParamX: false);
        if (detail.rarity > 2) {
          //all weapons with a rarity > 2 have 5 refinements except the following
          //the ps4 sword, the aloy weapon
          final ignore = ['sword-of-descension', 'predator', 'kagotsurube-isshin'];
          if (!ignore.contains(detail.key)) {
            expect(translation.refinements.length, 5, reason: 'Should match expected value (property=refinements, expected=5, key=${weapon.key}, lang=${lang.name})');
          } else {
            expect(translation.refinements, isNotEmpty, reason: 'Should not be empty (property=refinements, key=${weapon.key}, lang=${lang.name})');
          }
        } else {
          expect(translation.refinements, isEmpty, reason: 'Should be empty (property=refinements, key=${weapon.key}, lang=${lang.name})');
        }

        for (final refinement in translation.refinements) {
          checkTranslation(refinement, canBeNull: false, checkForColor: false, checkParamX: false);
        }
      }
    }
  });

  test('Check for artifacts', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getArtifactFileService(lang);
      final artifacts = service.getArtifactsForCard();
      for (final artifact in artifacts) {
        final detail = service.getArtifact(artifact.key);
        final translation = service.translations.getArtifactTranslation(detail.key);
        checkKey(translation.key);
        checkTranslation(translation.name, canBeNull: false);
        expect(translation.bonus.length, inInclusiveRange(1, 2), reason: 'Should be within expected range (property=bonus, key=${artifact.key}, lang=${lang.name})');
        for (final bonus in translation.bonus) {
          checkTranslation(bonus, canBeNull: false);
        }
      }
    }
  });

  test('Check the materials', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getMaterialFileService(lang);
      final materials = service.getAllMaterialsForCard();
      for (final material in materials) {
        final detail = service.getMaterial(material.key);
        final translation = service.translations.getMaterialTranslation(detail.key);
        checkKey(translation.key);
        checkTranslation(translation.name, canBeNull: false);
        checkTranslation(translation.description, canBeNull: false);
      }
    }
  });

  test('Check the monsters', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getMonsterFileService(lang);
      final monsters = service.getAllMonstersForCard();
      for (final monster in monsters) {
        final translation = service.translations.getMonsterTranslation(monster.key);
        checkKey(translation.key);
        checkTranslation(translation.name, canBeNull: false);
      }
    }
  });
}
