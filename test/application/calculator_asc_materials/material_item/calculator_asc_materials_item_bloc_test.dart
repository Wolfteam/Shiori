import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../../common.dart';
import '../../../mocks.mocks.dart';

void main() {
  late final GenshinService genshinService;
  late final ResourceService resourceService;
  late final CalculatorAscMaterialsService calcAscMatService;

  const String validCharKey = 'keqing';
  const String validWeaponKey = 'the-catch';
  final List<String> validKeys = [validCharKey, validWeaponKey];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    return Future(() async {
      final settingsService = MockSettingsService();
      when(settingsService.language).thenReturn(AppLanguageType.english);

      resourceService = getResourceService(settingsService);
      final localeService = LocaleServiceImpl(settingsService);
      genshinService = GenshinServiceImpl(resourceService, localeService);

      await genshinService.init(settingsService.language);

      calcAscMatService = CalculatorAscMaterialsServiceImpl(genshinService, resourceService);
    });
  });

  CalculatorAscMaterialsItemBloc getBloc() => CalculatorAscMaterialsItemBloc(genshinService, calcAscMatService, resourceService);

  test(
    'Initial state',
    () => expect(getBloc().state, const CalculatorAscMaterialsItemState.loading()),
  );

  group('Load', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'item does not exist',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsItemEvent.load(key: 'non-existant', isCharacter: true)),
      errors: () => [isA<StateError>()],
    );

    for (int i = 0; i < validKeys.length; i++) {
      final key = validKeys[i];
      final isCharacter = i == 0;
      blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
        'item $key exists',
        build: () => getBloc(),
        act: (bloc) => bloc.add(CalculatorAscMaterialsItemEvent.load(key: key, isCharacter: isCharacter)),
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case CalculatorAscMaterialsItemStateLoading():
              throw InvalidStateError();
            case CalculatorAscMaterialsItemStateLoaded():
              checkTranslation(state.name);
              checkAsset(state.imageFullPath);
              expect(state.currentLevel, itemAscensionLevelMap.entries.first.value);
              expect(state.desiredLevel, maxItemLevel);
              expect(state.currentAscensionLevel, minAscensionLevel);
              expect(state.desiredAscensionLevel, maxAscensionLevel);
              expect(state.useMaterialsFromInventory, isFalse);
              if (!isCharacter) {
                expect(state.skills.isEmpty, isTrue);
                return;
              }

              expect(state.skills.length, greaterThanOrEqualTo(3));
              for (int i = 0; i < state.skills.length; i++) {
                final skill = state.skills[i];
                checkItemKeyAndName(skill.key, skill.name);
                expect(skill.position == i, isTrue);

                expect(skill.currentLevel, minSkillLevel);
                expect(skill.isCurrentDecEnabled, isFalse);
                expect(skill.isCurrentIncEnabled, isFalse);

                expect(skill.desiredLevel, maxSkillLevel);
                expect(skill.isDesiredDecEnabled, isTrue);
                expect(skill.isDesiredIncEnabled, isFalse);
              }
          }
        },
      );
    }
  });

  group('LoadWith', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'item does not exist',
      build: () => getBloc(),
      act: (bloc) => bloc.add(
        const CalculatorAscMaterialsItemEvent.loadWith(
          key: 'non-existant',
          isCharacter: false,
          currentLevel: 20,
          desiredLevel: 60,
          currentAscensionLevel: 1,
          desiredAscensionLevel: 4,
          useMaterialsFromInventory: true,
          skills: [],
        ),
      ),
      errors: () => [isA<StateError>()],
    );

    for (int i = 0; i < validKeys.length; i++) {
      final key = validKeys[i];
      final isCharacter = i == 0;
      const int currentLevel = 20;
      const int desiredLevel = 50;
      const int currentAscLevel = 3;
      const int desiredAscLevel = 6;
      final skills = Iterable.generate(
        3,
        (j) => CharacterSkill.skill(
          key: 's$i',
          name: 'Skill-$i',
          position: i,
          currentLevel: 3,
          desiredLevel: 8,
          isCurrentDecEnabled: true,
          isCurrentIncEnabled: true,
          isDesiredDecEnabled: true,
          isDesiredIncEnabled: true,
        ),
      ).toList();
      blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
        'item $key exists',
        build: () => getBloc(),
        act: (bloc) => bloc.add(
          CalculatorAscMaterialsItemEvent.loadWith(
            key: key,
            isCharacter: isCharacter,
            currentLevel: currentLevel,
            desiredLevel: desiredLevel,
            currentAscensionLevel: currentAscLevel,
            desiredAscensionLevel: desiredAscLevel,
            useMaterialsFromInventory: true,
            skills: skills,
          ),
        ),
        verify: (bloc) {
          final state = bloc.state;
          switch (state) {
            case CalculatorAscMaterialsItemStateLoading():
              throw InvalidStateError();
            case CalculatorAscMaterialsItemStateLoaded():
              checkTranslation(state.name);
              checkAsset(state.imageFullPath);
              expect(state.currentLevel, currentLevel);
              expect(state.desiredLevel, desiredLevel);
              expect(state.currentAscensionLevel, currentAscLevel);
              expect(state.desiredAscensionLevel, desiredAscLevel);
              expect(state.useMaterialsFromInventory, isTrue);
              if (!isCharacter) {
                expect(state.skills.isEmpty, isTrue);
                return;
              }

              expect(state.skills.length, skills.length);
              for (int i = 0; i < state.skills.length; i++) {
                final skill = state.skills[i];
                final expectedSkill = skills[i];

                expect(skill.key, expectedSkill.key);
                expect(skill.name, expectedSkill.name);
                expect(skill.position, expectedSkill.position);

                expect(skill.currentLevel, expectedSkill.currentLevel);
                expect(skill.isCurrentDecEnabled, expectedSkill.isCurrentDecEnabled);
                expect(skill.isCurrentIncEnabled, expectedSkill.isCurrentIncEnabled);

                expect(skill.desiredLevel, expectedSkill.desiredLevel);
                expect(skill.isDesiredDecEnabled, expectedSkill.isDesiredDecEnabled);
                expect(skill.isDesiredIncEnabled, expectedSkill.isDesiredIncEnabled);
              }
          }
        },
      );
    }
  });

  group('Current level changed', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsItemEvent.currentLevelChanged(newValue: 50)),
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid value',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.currentLevelChanged(newValue: maxItemLevel + 1)),
      errors: () => [predicate<RangeError>((e) => e.name == 'currentLevel')],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'valid change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.currentLevelChanged(newValue: 50)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, 50);
            expect(state.desiredLevel, maxItemLevel);
            expect(state.currentAscensionLevel, 2);
            expect(state.desiredAscensionLevel, itemAscensionLevelMap.entries.last.key);
            expect(state.skills.isNotEmpty, isTrue);
            for (final skill in state.skills) {
              expect(skill.currentLevel, minSkillLevel);
              expect(skill.isCurrentIncEnabled, isTrue);
              expect(skill.isCurrentDecEnabled, isFalse);
              expect(skill.desiredLevel, maxSkillLevel);
              expect(skill.isDesiredIncEnabled, isFalse);
              expect(skill.isDesiredDecEnabled, isTrue);
            }
        }
      },
    );
  });

  group('Desired level changed', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsItemEvent.desiredLevelChanged(newValue: 50)),
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid value',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.desiredLevelChanged(newValue: minItemLevel - 1)),
      errors: () => [predicate<RangeError>((e) => e.name == 'desiredLevel')],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'valid change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.desiredLevelChanged(newValue: 50)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, itemAscensionLevelMap.entries.first.value);
            expect(state.desiredLevel, 50);
            expect(state.currentAscensionLevel, 1);
            expect(state.desiredAscensionLevel, 2);
            expect(state.skills.isNotEmpty, isTrue);
            for (final skill in state.skills) {
              expect(skill.currentLevel, minSkillLevel);
              expect(skill.isCurrentIncEnabled, isFalse);
              expect(skill.isCurrentDecEnabled, isFalse);
              expect(skill.desiredLevel, 2);
              expect(skill.isDesiredIncEnabled, isFalse);
              expect(skill.isDesiredDecEnabled, isTrue);
            }
        }
      },
    );
  });

  group('Level values changed', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'produces valid change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.currentLevelChanged(newValue: 50))
        ..add(const CalculatorAscMaterialsItemEvent.desiredLevelChanged(newValue: 70)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, 50);
            expect(state.desiredLevel, 70);
            expect(state.currentAscensionLevel, 2);
            expect(state.desiredAscensionLevel, 4);
            expect(state.skills.isNotEmpty, isTrue);
            for (final skill in state.skills) {
              expect(skill.currentLevel, minSkillLevel);
              expect(skill.isCurrentIncEnabled, isTrue);
              expect(skill.isCurrentDecEnabled, isFalse);
              expect(skill.desiredLevel, 5);
              expect(skill.isDesiredIncEnabled, isTrue);
              expect(skill.isDesiredDecEnabled, isTrue);
            }
        }
      },
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'change makes them equal',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.currentLevelChanged(newValue: 50))
        ..add(const CalculatorAscMaterialsItemEvent.desiredLevelChanged(newValue: 40)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, 40);
            expect(state.desiredLevel, 40);
            expect(state.currentAscensionLevel, 2);
            expect(state.desiredAscensionLevel, 2);
            expect(state.skills.isNotEmpty, isTrue);
            for (final skill in state.skills) {
              expect(skill.currentLevel, minSkillLevel);
              expect(skill.isCurrentIncEnabled, isTrue);
              expect(skill.isCurrentDecEnabled, isFalse);
              expect(skill.desiredLevel, minSkillLevel + 1);
              expect(skill.isDesiredIncEnabled, isFalse);
              expect(skill.isDesiredDecEnabled, isTrue);
            }
        }
      },
    );
  });

  group('Current ascension level changed', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) =>
          bloc.add(CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged(newValue: itemAscensionLevelMap.keys.first)),
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid value',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged(newValue: -1)),
      errors: () => [predicate<RangeError>((e) => e.name == 'currentLevel')],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'valid change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged(newValue: 3)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, 50);
            expect(state.desiredLevel, maxItemLevel);
            expect(state.currentAscensionLevel, 3);
            expect(state.desiredAscensionLevel, itemAscensionLevelMap.entries.last.key);
            expect(state.skills.isNotEmpty, isTrue);
            for (final skill in state.skills) {
              expect(skill.currentLevel, minSkillLevel);
              expect(skill.isCurrentIncEnabled, isTrue);
              expect(skill.isCurrentDecEnabled, isFalse);
              expect(skill.desiredLevel, maxSkillLevel);
              expect(skill.isDesiredIncEnabled, isFalse);
              expect(skill.isDesiredDecEnabled, isTrue);
            }
        }
      },
    );
  });

  group('Desired ascension level changed', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) =>
          bloc.add(CalculatorAscMaterialsItemEvent.desiredAscensionLevelChanged(newValue: itemAscensionLevelMap.keys.first)),
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid value',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(CalculatorAscMaterialsItemEvent.desiredAscensionLevelChanged(newValue: itemAscensionLevelMap.keys.last + 1)),
      errors: () => [predicate<RangeError>((e) => e.name == 'desiredLevel')],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'valid change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.desiredAscensionLevelChanged(newValue: 3)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, 20);
            expect(state.desiredLevel, 50);
            expect(state.currentAscensionLevel, itemAscensionLevelMap.keys.first);
            expect(state.desiredAscensionLevel, 3);
            expect(state.skills.isNotEmpty, isTrue);
            for (final skill in state.skills) {
              expect(skill.currentLevel, minSkillLevel);
              expect(skill.isCurrentIncEnabled, isFalse);
              expect(skill.isCurrentDecEnabled, isFalse);
              expect(skill.desiredLevel, 3);
              expect(skill.isDesiredIncEnabled, isTrue);
              expect(skill.isDesiredDecEnabled, isTrue);
            }
        }
      },
    );
  });

  group('Ascension level values changed', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'produces valid change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged(newValue: 2))
        ..add(const CalculatorAscMaterialsItemEvent.desiredAscensionLevelChanged(newValue: 3)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, 40);
            expect(state.desiredLevel, 50);
            expect(state.currentAscensionLevel, 2);
            expect(state.desiredAscensionLevel, 3);
            expect(state.skills.isNotEmpty, isTrue);
            for (final skill in state.skills) {
              expect(skill.currentLevel, minSkillLevel);
              expect(skill.isCurrentIncEnabled, isTrue);
              expect(skill.isCurrentDecEnabled, isFalse);
              expect(skill.desiredLevel, 3);
              expect(skill.isDesiredIncEnabled, isTrue);
              expect(skill.isDesiredDecEnabled, isTrue);
            }
        }
      },
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'change makes them equal',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.desiredAscensionLevelChanged(newValue: 2))
        ..add(const CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged(newValue: 3)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, 50);
            expect(state.desiredLevel, 50);
            expect(state.currentAscensionLevel, 3);
            expect(state.desiredAscensionLevel, 3);
            expect(state.skills.isNotEmpty, isTrue);
            for (final skill in state.skills) {
              expect(skill.currentLevel, minItemLevel);
              expect(skill.isCurrentIncEnabled, isTrue);
              expect(skill.isCurrentDecEnabled, isFalse);
              expect(skill.desiredLevel, 2);
              expect(skill.isDesiredIncEnabled, isTrue);
              expect(skill.isDesiredDecEnabled, isTrue);
            }
        }
      },
    );
  });

  group('Skill current level changed', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsItemEvent.skillCurrentLevelChanged(index: 0, newValue: 2)),
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid index',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.skillCurrentLevelChanged(index: -1, newValue: 1)),
      errors: () => [predicate<RangeError>((e) => e.name == 'skillIndex')],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid value',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.skillCurrentLevelChanged(index: 0, newValue: minSkillLevel - 1)),
      errors: () => [predicate<RangeError>((e) => e.name == 'newValue')],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'valid change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged(newValue: 2))
        ..add(const CalculatorAscMaterialsItemEvent.skillCurrentLevelChanged(index: 0, newValue: 2)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, 40);
            expect(state.desiredLevel, maxItemLevel);
            expect(state.currentAscensionLevel, 2);
            expect(state.desiredAscensionLevel, itemAscensionLevelMap.keys.last);
            expect(state.skills.isNotEmpty, isTrue);
            for (int i = 0; i < state.skills.length; i++) {
              final skill = state.skills[i];
              if (i == 0) {
                expect(skill.currentLevel, 2);
                expect(skill.isCurrentIncEnabled, isFalse);
                expect(skill.isCurrentDecEnabled, isTrue);
              } else {
                expect(skill.currentLevel, minSkillLevel);
                expect(skill.isCurrentIncEnabled, isTrue);
                expect(skill.isCurrentDecEnabled, isFalse);
              }
              expect(skill.desiredLevel, maxSkillLevel);
              expect(skill.isDesiredIncEnabled, isFalse);
              expect(skill.isDesiredDecEnabled, isTrue);
            }
        }
      },
    );
  });

  group('Skill desired level changed', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid state',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CalculatorAscMaterialsItemEvent.skillDesiredLevelChanged(index: 1, newValue: 9)),
      errors: () => [isA<InvalidStateError>()],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid index',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.skillDesiredLevelChanged(index: 5, newValue: 9)),
      errors: () => [predicate<RangeError>((e) => e.name == 'skillIndex')],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'invalid value',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.skillDesiredLevelChanged(index: 1, newValue: maxSkillLevel + 1)),
      errors: () => [predicate<RangeError>((e) => e.name == 'newValue')],
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'valid change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.skillDesiredLevelChanged(index: 0, newValue: 9)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.skills.isNotEmpty, isTrue);
            for (int i = 0; i < state.skills.length; i++) {
              final skill = state.skills[i];
              if (i == 0) {
                expect(skill.desiredLevel, 9);
                expect(skill.isDesiredIncEnabled, isTrue);
                expect(skill.isDesiredDecEnabled, isTrue);
              } else {
                expect(skill.desiredLevel, maxSkillLevel);
                expect(skill.isDesiredIncEnabled, isFalse);
                expect(skill.isDesiredDecEnabled, isTrue);
              }
              expect(skill.currentLevel, minSkillLevel);
              expect(skill.isCurrentIncEnabled, isFalse);
              expect(skill.isCurrentDecEnabled, isFalse);
            }
        }
      },
    );
  });

  group('Skill level values changed', () {
    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'valid change',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged(newValue: 3))
        ..add(const CalculatorAscMaterialsItemEvent.skillCurrentLevelChanged(index: 0, newValue: 4))
        ..add(const CalculatorAscMaterialsItemEvent.skillDesiredLevelChanged(index: 0, newValue: 6)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, 50);
            expect(state.desiredLevel, 90);
            expect(state.currentAscensionLevel, 3);
            expect(state.desiredAscensionLevel, itemAscensionLevelMap.keys.last);
            expect(state.skills.isNotEmpty, isTrue);
            for (int i = 0; i < state.skills.length; i++) {
              final skill = state.skills[i];
              if (i == 0) {
                expect(skill.currentLevel, 4);
                expect(skill.isCurrentIncEnabled, isFalse);
                expect(skill.isCurrentDecEnabled, isTrue);
                expect(skill.desiredLevel, 6);
                expect(skill.isDesiredIncEnabled, isTrue);
                expect(skill.isDesiredDecEnabled, isTrue);
              } else {
                expect(skill.currentLevel, minSkillLevel);
                expect(skill.isCurrentIncEnabled, isTrue);
                expect(skill.isCurrentDecEnabled, isFalse);
                expect(skill.desiredLevel, maxSkillLevel);
                expect(skill.isDesiredIncEnabled, isFalse);
                expect(skill.isDesiredDecEnabled, isTrue);
              }
            }
        }
      },
    );

    blocTest<CalculatorAscMaterialsItemBloc, CalculatorAscMaterialsItemState>(
      'change makes them equal',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CalculatorAscMaterialsItemEvent.load(key: validCharKey, isCharacter: true))
        ..add(const CalculatorAscMaterialsItemEvent.currentAscensionLevelChanged(newValue: 3))
        ..add(const CalculatorAscMaterialsItemEvent.skillCurrentLevelChanged(index: 0, newValue: 4))
        ..add(const CalculatorAscMaterialsItemEvent.skillDesiredLevelChanged(index: 0, newValue: 3)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CalculatorAscMaterialsItemStateLoading():
            throw InvalidStateError();
          case CalculatorAscMaterialsItemStateLoaded():
            expect(state.currentLevel, 50);
            expect(state.desiredLevel, 90);
            expect(state.currentAscensionLevel, 3);
            expect(state.desiredAscensionLevel, itemAscensionLevelMap.keys.last);
            expect(state.skills.isNotEmpty, isTrue);
            for (int i = 0; i < state.skills.length; i++) {
              final skill = state.skills[i];
              if (i == 0) {
                expect(skill.currentLevel, 3);
                expect(skill.isCurrentIncEnabled, isTrue);
                expect(skill.isCurrentDecEnabled, isTrue);
                expect(skill.desiredLevel, 3);
                expect(skill.isDesiredIncEnabled, isTrue);
                expect(skill.isDesiredDecEnabled, isTrue);
              } else {
                expect(skill.currentLevel, minSkillLevel);
                expect(skill.isCurrentIncEnabled, isTrue);
                expect(skill.isCurrentDecEnabled, isFalse);
                expect(skill.desiredLevel, maxSkillLevel);
                expect(skill.isDesiredIncEnabled, isFalse);
                expect(skill.isDesiredDecEnabled, isTrue);
              }
            }
        }
      },
    );
  });
}
