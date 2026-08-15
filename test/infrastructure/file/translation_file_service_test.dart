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
        checkKey(translation.key, ownerKey: character.key);
        checkTranslation(translation.name, canBeNull: false, lang: lang, ownerKey: character.key);
        if (!detail.isComingSoon) {
          checkTranslation(translation.description, canBeNull: false, lang: lang, ownerKey: character.key);
        }

        expect(
          translation.skills,
          isNotEmpty,
          reason: 'Character translation has no skills (key=${character.key}, lang=${lang.name})',
        );
        expect(
          translation.skills.length,
          equals(detail.skills.length),
          reason: 'Skill count mismatch: translation ${translation.skills.length} vs detail ${detail.skills.length} (key=${character.key}, lang=${lang.name})',
        );
        expect(
          translation.passives,
          isNotEmpty,
          reason: 'Character translation has no passives (key=${character.key}, lang=${lang.name})',
        );
        expect(
          translation.passives.length,
          equals(detail.passives.length),
          reason: 'Passive count mismatch: translation ${translation.passives.length} vs detail ${detail.passives.length} (key=${character.key}, lang=${lang.name})',
        );
        expect(
          translation.constellations,
          isNotEmpty,
          reason: 'Character translation has no constellations (key=${character.key}, lang=${lang.name})',
        );
        expect(
          translation.constellations.length,
          equals(detail.constellations.length),
          reason: 'Constellation count mismatch: translation ${translation.constellations.length} vs detail ${detail.constellations.length} (key=${character.key}, lang=${lang.name})',
        );

        checkKeys(translation.skills.map((e) => e.key).toList(), entity: 'skill');
        checkKeys(translation.passives.map((e) => e.key).toList(), entity: 'passive');
        checkKeys(translation.constellations.map((e) => e.key).toList(), entity: 'constellation');

        for (var i = 0; i < translation.skills.length; i++) {
          final skill = translation.skills[i];
          checkKey(skill.key, ownerKey: character.key);
          expect(
            skill.key,
            isIn(detail.skills.map((e) => e.key).toList()),
            reason: 'Translated skill key "${skill.key}" not found among detail skills (characterKey=${character.key}, lang=${lang.name})',
          );
          checkTranslation(skill.title, canBeNull: false, lang: lang, ownerKey: character.key);
          if (detail.isComingSoon) {
            continue;
          }
          expect(
            skill.stats,
            isNotEmpty,
            reason: 'Skill "${skill.key}" has no stats (characterKey=${character.key}, lang=${lang.name})',
          );
          for (final ability in skill.abilities) {
            final oneAtLeast =
                ability.name.isNotNullEmptyOrWhitespace ||
                ability.description.isNotNullEmptyOrWhitespace ||
                ability.secondDescription.isNotNullEmptyOrWhitespace;

            if (!oneAtLeast) {
              expect(
                ability.descriptions,
                isNotEmpty,
                reason: 'Skill ability lacks name/description and has no descriptions list (skill=${skill.key}, key=${character.key}, lang=${lang.name})',
              );
              for (final desc in ability.descriptions) {
                checkTranslation(desc, canBeNull: false, lang: lang, ownerKey: character.key);
              }
            }
          }

          final stats = service.getCharacterSkillStats(detail.skills[i].stats, skill.stats);
          expect(
            stats,
            isNotEmpty,
            reason: 'Computed skill stats are empty (skill=${skill.key}, key=${character.key}, lang=${lang.name})',
          );
          switch (detail.skills[i].type) {
            case CharacterSkillType.normalAttack:
            case CharacterSkillType.elementalSkill:
            case CharacterSkillType.elementalBurst:
              expect(
                stats.length,
                15,
                reason: 'Attack/skill/burst must have 15 stat rows, got ${stats.length} (skill=${skill.key}, key=${character.key}, lang=${lang.name})',
              );
            case CharacterSkillType.others:
              break;
          }
          final hasPendingParam = stats.expand((el) => el.descriptions).any((el) => el.contains('param'));
          expect(
            hasPendingParam,
            equals(false),
            reason: 'Skill stats contain an unresolved "param" placeholder (skill=${skill.key}, key=${character.key}, lang=${lang.name})',
          );

          for (final stat in stats) {
            for (final description in stat.descriptions) {
              checkTranslation(description, lang: lang, ownerKey: character.key);
            }
          }
        }

        for (final passive in translation.passives) {
          checkKey(passive.key, ownerKey: character.key);
          expect(
            passive.key,
            isIn(detail.passives.map((e) => e.key).toList()),
            reason: 'Translated passive key "${passive.key}" not found among detail passives (characterKey=${character.key}, lang=${lang.name})',
          );
          if (detail.isComingSoon) {
            continue;
          }
          checkTranslation(passive.title, canBeNull: false, lang: lang, ownerKey: character.key);
          checkTranslation(passive.description, canBeNull: passive.descriptions.isNotEmpty, lang: lang, ownerKey: character.key);
          for (final desc in passive.descriptions) {
            checkTranslation(desc, canBeNull: false, lang: lang, ownerKey: character.key);
          }
        }

        for (final constellation in translation.constellations) {
          checkKey(constellation.key, ownerKey: character.key);
          expect(
            constellation.key,
            isIn(detail.constellations.map((e) => e.key).toList()),
            reason: 'Translated constellation key "${constellation.key}" not found among detail constellations (characterKey=${character.key}, lang=${lang.name})',
          );
          if (detail.isComingSoon) {
            continue;
          }
          checkTranslation(constellation.title, canBeNull: false, lang: lang, ownerKey: character.key);
          checkTranslation(constellation.description, canBeNull: false, lang: lang, ownerKey: character.key);
          checkTranslation(constellation.secondDescription, lang: lang, ownerKey: character.key);
          for (final desc in constellation.descriptions) {
            checkTranslation(desc, canBeNull: false, lang: lang, ownerKey: character.key);
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
        checkKey(translation.key, ownerKey: weapon.key);
        checkTranslation(translation.name, canBeNull: false, checkParamX: false, lang: lang, ownerKey: weapon.key);
        checkTranslation(translation.description, canBeNull: false, checkParamX: false, lang: lang, ownerKey: weapon.key);
        if (detail.rarity > 2) {
          //all weapons with a rarity > 2 have 5 refinements except the following
          //the ps4 sword, the aloy weapon
          final ignore = ['sword-of-descension', 'predator', 'kagotsurube-isshin'];
          if (!ignore.contains(detail.key)) {
            expect(
              translation.refinements.length,
              5,
              reason: 'Weapon must have 5 refinements, got ${translation.refinements.length} (key=${weapon.key}, lang=${lang.name})',
            );
          } else {
            expect(
              translation.refinements,
              isNotEmpty,
              reason: 'Special-case weapon must have at least one refinement (key=${weapon.key}, lang=${lang.name})',
            );
          }
        } else {
          expect(
            translation.refinements,
            isEmpty,
            reason: 'Rarity <= 2 weapon must have no refinements, got ${translation.refinements.length} (key=${weapon.key}, lang=${lang.name})',
          );
        }

        for (final refinement in translation.refinements) {
          checkTranslation(refinement, canBeNull: false, checkForColor: false, checkParamX: false, lang: lang, ownerKey: weapon.key);
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
        checkKey(translation.key, ownerKey: artifact.key);
        checkTranslation(translation.name, canBeNull: false, lang: lang, ownerKey: artifact.key);
        expect(
          translation.bonus.length,
          inInclusiveRange(1, 2),
          reason: 'Artifact set must have 1–2 set bonuses, got ${translation.bonus.length} (key=${artifact.key}, lang=${lang.name})',
        );
        for (final bonus in translation.bonus) {
          checkTranslation(bonus, canBeNull: false, lang: lang, ownerKey: artifact.key);
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
        checkKey(translation.key, ownerKey: material.key);
        checkTranslation(translation.name, canBeNull: false, lang: lang, ownerKey: material.key);
        checkTranslation(translation.description, canBeNull: false, lang: lang, ownerKey: material.key);
      }
    }
  });

  test('Check the monsters', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getMonsterFileService(lang);
      final monsters = service.getAllMonstersForCard();
      for (final monster in monsters) {
        final translation = service.translations.getMonsterTranslation(monster.key);
        checkKey(translation.key, ownerKey: monster.key);
        checkTranslation(translation.name, canBeNull: false, lang: lang, ownerKey: monster.key);
      }
    }
  });
}
