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
            final oneAtLeast = ability.name.isNotNullEmptyOrWhitespace || ability.description.isNotNullEmptyOrWhitespace || ability.secondDescription.isNotNullEmptyOrWhitespace;

            if (!oneAtLeast) {
              expect(ability.descriptions, isNotEmpty);
              for (final desc in ability.descriptions) {
                checkTranslation(desc, canBeNull: false);
              }
            }
          }

          final stats = service.getCharacterSkillStats(detail.skills[i].stats, skill.stats);
          expect(stats, isNotEmpty);
          switch (detail.skills[i].type) {
            case CharacterSkillType.normalAttack:
            case CharacterSkillType.elementalSkill:
            case CharacterSkillType.elementalBurst:
              expect(stats.length, 15);
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

  test('Check for weapons', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getWeaponFileService(lang);
      final weapons = service.getWeaponsForCard();
      for (final weapon in weapons) {
        final detail = service.getWeapon(weapon.key);
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

  test('Check for artifacts', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getArtifactFileService(lang);
      final artifacts = service.getArtifactsForCard();
      for (final artifact in artifacts) {
        final detail = service.getArtifact(artifact.key);
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
