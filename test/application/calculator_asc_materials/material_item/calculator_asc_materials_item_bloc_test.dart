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
    () => expect(
      getBloc().state,
      const CalculatorAscMaterialsItemState.loading(),
      reason: 'A freshly built item bloc must start in the loading state before any load event',
    ),
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
              expect(
                state.currentLevel,
                itemAscensionLevelMap.entries.first.value,
                reason: 'state.currentLevel should equal itemAscensionLevelMap.entries.first.value (Load)',
              );
              expect(state.desiredLevel, maxItemLevel, reason: 'state.desiredLevel should equal maxItemLevel (Load)');
              expect(
                state.currentAscensionLevel,
                minAscensionLevel,
                reason: 'state.currentAscensionLevel should equal minAscensionLevel (Load)',
              );
              expect(
                state.desiredAscensionLevel,
                maxAscensionLevel,
                reason: 'state.desiredAscensionLevel should equal maxAscensionLevel (Load)',
              );
              expect(
                state.useMaterialsFromInventory,
                isFalse,
                reason: 'state.useMaterialsFromInventory should be false (Load)',
              );
              if (!isCharacter) {
                expect(state.skills.isEmpty, isTrue, reason: 'state.skills.isEmpty should be true (Load)');
                return;
              }

              expect(state.skills.length, greaterThanOrEqualTo(3), reason: 'state.skills.length should be >= 3 (Load)');
              for (int i = 0; i < state.skills.length; i++) {
                final skill = state.skills[i];
                checkItemKeyAndName(skill.key, skill.name);
                expect(skill.position == i, isTrue, reason: 'skill.position == i should be true (Load)');

                expect(
                  skill.currentLevel,
                  minSkillLevel,
                  reason: 'skill.currentLevel should equal minSkillLevel (Load)',
                );
                expect(skill.isCurrentDecEnabled, isFalse, reason: 'skill.isCurrentDecEnabled should be false (Load)');
                expect(skill.isCurrentIncEnabled, isFalse, reason: 'skill.isCurrentIncEnabled should be false (Load)');

                expect(
                  skill.desiredLevel,
                  maxSkillLevel,
                  reason: 'skill.desiredLevel should equal maxSkillLevel (Load)',
                );
                expect(skill.isDesiredDecEnabled, isTrue, reason: 'skill.isDesiredDecEnabled should be true (Load)');
                expect(skill.isDesiredIncEnabled, isFalse, reason: 'skill.isDesiredIncEnabled should be false (Load)');
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
              expect(
                state.currentLevel,
                currentLevel,
                reason: 'state.currentLevel should equal currentLevel (LoadWith)',
              );
              expect(
                state.desiredLevel,
                desiredLevel,
                reason: 'state.desiredLevel should equal desiredLevel (LoadWith)',
              );
              expect(
                state.currentAscensionLevel,
                currentAscLevel,
                reason: 'state.currentAscensionLevel should equal currentAscLevel (LoadWith)',
              );
              expect(
                state.desiredAscensionLevel,
                desiredAscLevel,
                reason: 'state.desiredAscensionLevel should equal desiredAscLevel (LoadWith)',
              );
              expect(
                state.useMaterialsFromInventory,
                isTrue,
                reason: 'state.useMaterialsFromInventory should be true (LoadWith)',
              );
              if (!isCharacter) {
                expect(state.skills.isEmpty, isTrue, reason: 'state.skills.isEmpty should be true (LoadWith)');
                return;
              }

              expect(
                state.skills.length,
                skills.length,
                reason: 'state.skills.length should equal skills.length (LoadWith)',
              );
              for (int i = 0; i < state.skills.length; i++) {
                final skill = state.skills[i];
                final expectedSkill = skills[i];

                expect(skill.key, expectedSkill.key, reason: 'skill.key should equal expectedSkill.key (LoadWith)');
                expect(skill.name, expectedSkill.name, reason: 'skill.name should equal expectedSkill.name (LoadWith)');
                expect(
                  skill.position,
                  expectedSkill.position,
                  reason: 'skill.position should equal expectedSkill.position (LoadWith)',
                );

                expect(
                  skill.currentLevel,
                  expectedSkill.currentLevel,
                  reason: 'skill.currentLevel should equal expectedSkill.currentLevel (LoadWith)',
                );
                expect(
                  skill.isCurrentDecEnabled,
                  expectedSkill.isCurrentDecEnabled,
                  reason: 'skill.isCurrentDecEnabled should equal expectedSkill.isCurrentDecEnabled (LoadWith)',
                );
                expect(
                  skill.isCurrentIncEnabled,
                  expectedSkill.isCurrentIncEnabled,
                  reason: 'skill.isCurrentIncEnabled should equal expectedSkill.isCurrentIncEnabled (LoadWith)',
                );

                expect(
                  skill.desiredLevel,
                  expectedSkill.desiredLevel,
                  reason: 'skill.desiredLevel should equal expectedSkill.desiredLevel (LoadWith)',
                );
                expect(
                  skill.isDesiredDecEnabled,
                  expectedSkill.isDesiredDecEnabled,
                  reason: 'skill.isDesiredDecEnabled should equal expectedSkill.isDesiredDecEnabled (LoadWith)',
                );
                expect(
                  skill.isDesiredIncEnabled,
                  expectedSkill.isDesiredIncEnabled,
                  reason: 'skill.isDesiredIncEnabled should equal expectedSkill.isDesiredIncEnabled (LoadWith)',
                );
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
            expect(state.currentLevel, 50, reason: 'state.currentLevel should equal 50 (Current level changed)');
            expect(
              state.desiredLevel,
              maxItemLevel,
              reason: 'state.desiredLevel should equal maxItemLevel (Current level changed)',
            );
            expect(
              state.currentAscensionLevel,
              2,
              reason: 'state.currentAscensionLevel should equal 2 (Current level changed)',
            );
            expect(
              state.desiredAscensionLevel,
              itemAscensionLevelMap.entries.last.key,
              reason: 'state.desiredAscensionLevel should equal itemAscensionLevelMap.entries.last.key',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Current level changed)',
            );
            for (final skill in state.skills) {
              expect(
                skill.currentLevel,
                minSkillLevel,
                reason: 'skill.currentLevel should equal minSkillLevel (Current level changed)',
              );
              expect(
                skill.isCurrentIncEnabled,
                isTrue,
                reason: 'skill.isCurrentIncEnabled should be true (Current level changed)',
              );
              expect(
                skill.isCurrentDecEnabled,
                isFalse,
                reason: 'skill.isCurrentDecEnabled should be false (Current level changed)',
              );
              expect(
                skill.desiredLevel,
                maxSkillLevel,
                reason: 'skill.desiredLevel should equal maxSkillLevel (Current level changed)',
              );
              expect(
                skill.isDesiredIncEnabled,
                isFalse,
                reason: 'skill.isDesiredIncEnabled should be false (Current level changed)',
              );
              expect(
                skill.isDesiredDecEnabled,
                isTrue,
                reason: 'skill.isDesiredDecEnabled should be true (Current level changed)',
              );
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
            expect(
              state.currentLevel,
              itemAscensionLevelMap.entries.first.value,
              reason: 'state.currentLevel should equal itemAscensionLevelMap.entries.first.value',
            );
            expect(state.desiredLevel, 50, reason: 'state.desiredLevel should equal 50 (Desired level changed)');
            expect(
              state.currentAscensionLevel,
              1,
              reason: 'state.currentAscensionLevel should equal 1 (Desired level changed)',
            );
            expect(
              state.desiredAscensionLevel,
              2,
              reason: 'state.desiredAscensionLevel should equal 2 (Desired level changed)',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Desired level changed)',
            );
            for (final skill in state.skills) {
              expect(
                skill.currentLevel,
                minSkillLevel,
                reason: 'skill.currentLevel should equal minSkillLevel (Desired level changed)',
              );
              expect(
                skill.isCurrentIncEnabled,
                isFalse,
                reason: 'skill.isCurrentIncEnabled should be false (Desired level changed)',
              );
              expect(
                skill.isCurrentDecEnabled,
                isFalse,
                reason: 'skill.isCurrentDecEnabled should be false (Desired level changed)',
              );
              expect(skill.desiredLevel, 2, reason: 'skill.desiredLevel should equal 2 (Desired level changed)');
              expect(
                skill.isDesiredIncEnabled,
                isFalse,
                reason: 'skill.isDesiredIncEnabled should be false (Desired level changed)',
              );
              expect(
                skill.isDesiredDecEnabled,
                isTrue,
                reason: 'skill.isDesiredDecEnabled should be true (Desired level changed)',
              );
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
            expect(state.currentLevel, 50, reason: 'state.currentLevel should equal 50 (Level values changed)');
            expect(state.desiredLevel, 70, reason: 'state.desiredLevel should equal 70 (Level values changed)');
            expect(
              state.currentAscensionLevel,
              2,
              reason: 'state.currentAscensionLevel should equal 2 (Level values changed)',
            );
            expect(
              state.desiredAscensionLevel,
              4,
              reason: 'state.desiredAscensionLevel should equal 4 (Level values changed)',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Level values changed)',
            );
            for (final skill in state.skills) {
              expect(
                skill.currentLevel,
                minSkillLevel,
                reason: 'skill.currentLevel should equal minSkillLevel (Level values changed)',
              );
              expect(
                skill.isCurrentIncEnabled,
                isTrue,
                reason: 'skill.isCurrentIncEnabled should be true (Level values changed)',
              );
              expect(
                skill.isCurrentDecEnabled,
                isFalse,
                reason: 'skill.isCurrentDecEnabled should be false (Level values changed)',
              );
              expect(skill.desiredLevel, 5, reason: 'skill.desiredLevel should equal 5 (Level values changed)');
              expect(
                skill.isDesiredIncEnabled,
                isTrue,
                reason: 'skill.isDesiredIncEnabled should be true (Level values changed)',
              );
              expect(
                skill.isDesiredDecEnabled,
                isTrue,
                reason: 'skill.isDesiredDecEnabled should be true (Level values changed)',
              );
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
            expect(state.currentLevel, 40, reason: 'state.currentLevel should equal 40 (Level values changed)');
            expect(state.desiredLevel, 40, reason: 'state.desiredLevel should equal 40 (Level values changed)');
            expect(
              state.currentAscensionLevel,
              2,
              reason: 'state.currentAscensionLevel should equal 2 (Level values changed)',
            );
            expect(
              state.desiredAscensionLevel,
              2,
              reason: 'state.desiredAscensionLevel should equal 2 (Level values changed)',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Level values changed)',
            );
            for (final skill in state.skills) {
              expect(
                skill.currentLevel,
                minSkillLevel,
                reason: 'skill.currentLevel should equal minSkillLevel (Level values changed)',
              );
              expect(
                skill.isCurrentIncEnabled,
                isTrue,
                reason: 'skill.isCurrentIncEnabled should be true (Level values changed)',
              );
              expect(
                skill.isCurrentDecEnabled,
                isFalse,
                reason: 'skill.isCurrentDecEnabled should be false (Level values changed)',
              );
              expect(
                skill.desiredLevel,
                minSkillLevel + 1,
                reason: 'skill.desiredLevel should equal minSkillLevel + 1 (Level values changed)',
              );
              expect(
                skill.isDesiredIncEnabled,
                isFalse,
                reason: 'skill.isDesiredIncEnabled should be false (Level values changed)',
              );
              expect(
                skill.isDesiredDecEnabled,
                isTrue,
                reason: 'skill.isDesiredDecEnabled should be true (Level values changed)',
              );
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
            expect(
              state.currentLevel,
              50,
              reason: 'state.currentLevel should equal 50 (Current ascension level changed)',
            );
            expect(
              state.desiredLevel,
              maxItemLevel,
              reason: 'state.desiredLevel should equal maxItemLevel (Current ascension level changed)',
            );
            expect(
              state.currentAscensionLevel,
              3,
              reason: 'state.currentAscensionLevel should equal 3 (Current ascension level changed)',
            );
            expect(
              state.desiredAscensionLevel,
              itemAscensionLevelMap.entries.last.key,
              reason: 'state.desiredAscensionLevel should equal itemAscensionLevelMap.entries.last.key',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Current ascension level changed)',
            );
            for (final skill in state.skills) {
              expect(
                skill.currentLevel,
                minSkillLevel,
                reason: 'skill.currentLevel should equal minSkillLevel (Current ascension level changed)',
              );
              expect(
                skill.isCurrentIncEnabled,
                isTrue,
                reason: 'skill.isCurrentIncEnabled should be true (Current ascension level changed)',
              );
              expect(
                skill.isCurrentDecEnabled,
                isFalse,
                reason: 'skill.isCurrentDecEnabled should be false (Current ascension level changed)',
              );
              expect(
                skill.desiredLevel,
                maxSkillLevel,
                reason: 'skill.desiredLevel should equal maxSkillLevel (Current ascension level changed)',
              );
              expect(
                skill.isDesiredIncEnabled,
                isFalse,
                reason: 'skill.isDesiredIncEnabled should be false (Current ascension level changed)',
              );
              expect(
                skill.isDesiredDecEnabled,
                isTrue,
                reason: 'skill.isDesiredDecEnabled should be true (Current ascension level changed)',
              );
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
            expect(
              state.currentLevel,
              20,
              reason: 'state.currentLevel should equal 20 (Desired ascension level changed)',
            );
            expect(
              state.desiredLevel,
              50,
              reason: 'state.desiredLevel should equal 50 (Desired ascension level changed)',
            );
            expect(
              state.currentAscensionLevel,
              itemAscensionLevelMap.keys.first,
              reason: 'state.currentAscensionLevel should equal itemAscensionLevelMap.keys.first',
            );
            expect(
              state.desiredAscensionLevel,
              3,
              reason: 'state.desiredAscensionLevel should equal 3 (Desired ascension level changed)',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Desired ascension level changed)',
            );
            for (final skill in state.skills) {
              expect(
                skill.currentLevel,
                minSkillLevel,
                reason: 'skill.currentLevel should equal minSkillLevel (Desired ascension level changed)',
              );
              expect(
                skill.isCurrentIncEnabled,
                isFalse,
                reason: 'skill.isCurrentIncEnabled should be false (Desired ascension level changed)',
              );
              expect(
                skill.isCurrentDecEnabled,
                isFalse,
                reason: 'skill.isCurrentDecEnabled should be false (Desired ascension level changed)',
              );
              expect(
                skill.desiredLevel,
                3,
                reason: 'skill.desiredLevel should equal 3 (Desired ascension level changed)',
              );
              expect(
                skill.isDesiredIncEnabled,
                isTrue,
                reason: 'skill.isDesiredIncEnabled should be true (Desired ascension level changed)',
              );
              expect(
                skill.isDesiredDecEnabled,
                isTrue,
                reason: 'skill.isDesiredDecEnabled should be true (Desired ascension level changed)',
              );
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
            expect(
              state.currentLevel,
              40,
              reason: 'state.currentLevel should equal 40 (Ascension level values changed)',
            );
            expect(
              state.desiredLevel,
              50,
              reason: 'state.desiredLevel should equal 50 (Ascension level values changed)',
            );
            expect(
              state.currentAscensionLevel,
              2,
              reason: 'state.currentAscensionLevel should equal 2 (Ascension level values changed)',
            );
            expect(
              state.desiredAscensionLevel,
              3,
              reason: 'state.desiredAscensionLevel should equal 3 (Ascension level values changed)',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Ascension level values changed)',
            );
            for (final skill in state.skills) {
              expect(
                skill.currentLevel,
                minSkillLevel,
                reason: 'skill.currentLevel should equal minSkillLevel (Ascension level values changed)',
              );
              expect(
                skill.isCurrentIncEnabled,
                isTrue,
                reason: 'skill.isCurrentIncEnabled should be true (Ascension level values changed)',
              );
              expect(
                skill.isCurrentDecEnabled,
                isFalse,
                reason: 'skill.isCurrentDecEnabled should be false (Ascension level values changed)',
              );
              expect(
                skill.desiredLevel,
                3,
                reason: 'skill.desiredLevel should equal 3 (Ascension level values changed)',
              );
              expect(
                skill.isDesiredIncEnabled,
                isTrue,
                reason: 'skill.isDesiredIncEnabled should be true (Ascension level values changed)',
              );
              expect(
                skill.isDesiredDecEnabled,
                isTrue,
                reason: 'skill.isDesiredDecEnabled should be true (Ascension level values changed)',
              );
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
            expect(
              state.currentLevel,
              50,
              reason: 'state.currentLevel should equal 50 (Ascension level values changed)',
            );
            expect(
              state.desiredLevel,
              50,
              reason: 'state.desiredLevel should equal 50 (Ascension level values changed)',
            );
            expect(
              state.currentAscensionLevel,
              3,
              reason: 'state.currentAscensionLevel should equal 3 (Ascension level values changed)',
            );
            expect(
              state.desiredAscensionLevel,
              3,
              reason: 'state.desiredAscensionLevel should equal 3 (Ascension level values changed)',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Ascension level values changed)',
            );
            for (final skill in state.skills) {
              expect(
                skill.currentLevel,
                minItemLevel,
                reason: 'skill.currentLevel should equal minItemLevel (Ascension level values changed)',
              );
              expect(
                skill.isCurrentIncEnabled,
                isTrue,
                reason: 'skill.isCurrentIncEnabled should be true (Ascension level values changed)',
              );
              expect(
                skill.isCurrentDecEnabled,
                isFalse,
                reason: 'skill.isCurrentDecEnabled should be false (Ascension level values changed)',
              );
              expect(
                skill.desiredLevel,
                2,
                reason: 'skill.desiredLevel should equal 2 (Ascension level values changed)',
              );
              expect(
                skill.isDesiredIncEnabled,
                isTrue,
                reason: 'skill.isDesiredIncEnabled should be true (Ascension level values changed)',
              );
              expect(
                skill.isDesiredDecEnabled,
                isTrue,
                reason: 'skill.isDesiredDecEnabled should be true (Ascension level values changed)',
              );
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
            expect(state.currentLevel, 40, reason: 'state.currentLevel should equal 40 (Skill current level changed)');
            expect(
              state.desiredLevel,
              maxItemLevel,
              reason: 'state.desiredLevel should equal maxItemLevel (Skill current level changed)',
            );
            expect(
              state.currentAscensionLevel,
              2,
              reason: 'state.currentAscensionLevel should equal 2 (Skill current level changed)',
            );
            expect(
              state.desiredAscensionLevel,
              itemAscensionLevelMap.keys.last,
              reason: 'state.desiredAscensionLevel should equal itemAscensionLevelMap.keys.last',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Skill current level changed)',
            );
            for (int i = 0; i < state.skills.length; i++) {
              final skill = state.skills[i];
              if (i == 0) {
                expect(
                  skill.currentLevel,
                  2,
                  reason: 'skill.currentLevel should equal 2 (Skill current level changed)',
                );
                expect(
                  skill.isCurrentIncEnabled,
                  isFalse,
                  reason: 'skill.isCurrentIncEnabled should be false (Skill current level changed)',
                );
                expect(
                  skill.isCurrentDecEnabled,
                  isTrue,
                  reason: 'skill.isCurrentDecEnabled should be true (Skill current level changed)',
                );
              } else {
                expect(
                  skill.currentLevel,
                  minSkillLevel,
                  reason: 'skill.currentLevel should equal minSkillLevel (Skill current level changed)',
                );
                expect(
                  skill.isCurrentIncEnabled,
                  isTrue,
                  reason: 'skill.isCurrentIncEnabled should be true (Skill current level changed)',
                );
                expect(
                  skill.isCurrentDecEnabled,
                  isFalse,
                  reason: 'skill.isCurrentDecEnabled should be false (Skill current level changed)',
                );
              }
              expect(
                skill.desiredLevel,
                maxSkillLevel,
                reason: 'skill.desiredLevel should equal maxSkillLevel (Skill current level changed)',
              );
              expect(
                skill.isDesiredIncEnabled,
                isFalse,
                reason: 'skill.isDesiredIncEnabled should be false (Skill current level changed)',
              );
              expect(
                skill.isDesiredDecEnabled,
                isTrue,
                reason: 'skill.isDesiredDecEnabled should be true (Skill current level changed)',
              );
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
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Skill desired level changed)',
            );
            for (int i = 0; i < state.skills.length; i++) {
              final skill = state.skills[i];
              if (i == 0) {
                expect(
                  skill.desiredLevel,
                  9,
                  reason: 'skill.desiredLevel should equal 9 (Skill desired level changed)',
                );
                expect(
                  skill.isDesiredIncEnabled,
                  isTrue,
                  reason: 'skill.isDesiredIncEnabled should be true (Skill desired level changed)',
                );
                expect(
                  skill.isDesiredDecEnabled,
                  isTrue,
                  reason: 'skill.isDesiredDecEnabled should be true (Skill desired level changed)',
                );
              } else {
                expect(
                  skill.desiredLevel,
                  maxSkillLevel,
                  reason: 'skill.desiredLevel should equal maxSkillLevel (Skill desired level changed)',
                );
                expect(
                  skill.isDesiredIncEnabled,
                  isFalse,
                  reason: 'skill.isDesiredIncEnabled should be false (Skill desired level changed)',
                );
                expect(
                  skill.isDesiredDecEnabled,
                  isTrue,
                  reason: 'skill.isDesiredDecEnabled should be true (Skill desired level changed)',
                );
              }
              expect(
                skill.currentLevel,
                minSkillLevel,
                reason: 'skill.currentLevel should equal minSkillLevel (Skill desired level changed)',
              );
              expect(
                skill.isCurrentIncEnabled,
                isFalse,
                reason: 'skill.isCurrentIncEnabled should be false (Skill desired level changed)',
              );
              expect(
                skill.isCurrentDecEnabled,
                isFalse,
                reason: 'skill.isCurrentDecEnabled should be false (Skill desired level changed)',
              );
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
            expect(state.currentLevel, 50, reason: 'state.currentLevel should equal 50 (Skill level values changed)');
            expect(state.desiredLevel, 90, reason: 'state.desiredLevel should equal 90 (Skill level values changed)');
            expect(
              state.currentAscensionLevel,
              3,
              reason: 'state.currentAscensionLevel should equal 3 (Skill level values changed)',
            );
            expect(
              state.desiredAscensionLevel,
              itemAscensionLevelMap.keys.last,
              reason: 'state.desiredAscensionLevel should equal itemAscensionLevelMap.keys.last',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Skill level values changed)',
            );
            for (int i = 0; i < state.skills.length; i++) {
              final skill = state.skills[i];
              if (i == 0) {
                expect(skill.currentLevel, 4, reason: 'skill.currentLevel should equal 4 (Skill level values changed)');
                expect(
                  skill.isCurrentIncEnabled,
                  isFalse,
                  reason: 'skill.isCurrentIncEnabled should be false (Skill level values changed)',
                );
                expect(
                  skill.isCurrentDecEnabled,
                  isTrue,
                  reason: 'skill.isCurrentDecEnabled should be true (Skill level values changed)',
                );
                expect(skill.desiredLevel, 6, reason: 'skill.desiredLevel should equal 6 (Skill level values changed)');
                expect(
                  skill.isDesiredIncEnabled,
                  isTrue,
                  reason: 'skill.isDesiredIncEnabled should be true (Skill level values changed)',
                );
                expect(
                  skill.isDesiredDecEnabled,
                  isTrue,
                  reason: 'skill.isDesiredDecEnabled should be true (Skill level values changed)',
                );
              } else {
                expect(
                  skill.currentLevel,
                  minSkillLevel,
                  reason: 'skill.currentLevel should equal minSkillLevel (Skill level values changed)',
                );
                expect(
                  skill.isCurrentIncEnabled,
                  isTrue,
                  reason: 'skill.isCurrentIncEnabled should be true (Skill level values changed)',
                );
                expect(
                  skill.isCurrentDecEnabled,
                  isFalse,
                  reason: 'skill.isCurrentDecEnabled should be false (Skill level values changed)',
                );
                expect(
                  skill.desiredLevel,
                  maxSkillLevel,
                  reason: 'skill.desiredLevel should equal maxSkillLevel (Skill level values changed)',
                );
                expect(
                  skill.isDesiredIncEnabled,
                  isFalse,
                  reason: 'skill.isDesiredIncEnabled should be false (Skill level values changed)',
                );
                expect(
                  skill.isDesiredDecEnabled,
                  isTrue,
                  reason: 'skill.isDesiredDecEnabled should be true (Skill level values changed)',
                );
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
            expect(state.currentLevel, 50, reason: 'state.currentLevel should equal 50 (Skill level values changed)');
            expect(state.desiredLevel, 90, reason: 'state.desiredLevel should equal 90 (Skill level values changed)');
            expect(
              state.currentAscensionLevel,
              3,
              reason: 'state.currentAscensionLevel should equal 3 (Skill level values changed)',
            );
            expect(
              state.desiredAscensionLevel,
              itemAscensionLevelMap.keys.last,
              reason: 'state.desiredAscensionLevel should equal itemAscensionLevelMap.keys.last',
            );
            expect(
              state.skills.isNotEmpty,
              isTrue,
              reason: 'state.skills.isNotEmpty should be true (Skill level values changed)',
            );
            for (int i = 0; i < state.skills.length; i++) {
              final skill = state.skills[i];
              if (i == 0) {
                expect(skill.currentLevel, 3, reason: 'skill.currentLevel should equal 3 (Skill level values changed)');
                expect(
                  skill.isCurrentIncEnabled,
                  isTrue,
                  reason: 'skill.isCurrentIncEnabled should be true (Skill level values changed)',
                );
                expect(
                  skill.isCurrentDecEnabled,
                  isTrue,
                  reason: 'skill.isCurrentDecEnabled should be true (Skill level values changed)',
                );
                expect(skill.desiredLevel, 3, reason: 'skill.desiredLevel should equal 3 (Skill level values changed)');
                expect(
                  skill.isDesiredIncEnabled,
                  isTrue,
                  reason: 'skill.isDesiredIncEnabled should be true (Skill level values changed)',
                );
                expect(
                  skill.isDesiredDecEnabled,
                  isTrue,
                  reason: 'skill.isDesiredDecEnabled should be true (Skill level values changed)',
                );
              } else {
                expect(
                  skill.currentLevel,
                  minSkillLevel,
                  reason: 'skill.currentLevel should equal minSkillLevel (Skill level values changed)',
                );
                expect(
                  skill.isCurrentIncEnabled,
                  isTrue,
                  reason: 'skill.isCurrentIncEnabled should be true (Skill level values changed)',
                );
                expect(
                  skill.isCurrentDecEnabled,
                  isFalse,
                  reason: 'skill.isCurrentDecEnabled should be false (Skill level values changed)',
                );
                expect(
                  skill.desiredLevel,
                  maxSkillLevel,
                  reason: 'skill.desiredLevel should equal maxSkillLevel (Skill level values changed)',
                );
                expect(
                  skill.isDesiredIncEnabled,
                  isFalse,
                  reason: 'skill.isDesiredIncEnabled should be false (Skill level values changed)',
                );
                expect(
                  skill.isDesiredDecEnabled,
                  isTrue,
                  reason: 'skill.isDesiredDecEnabled should be true (Skill level values changed)',
                );
              }
            }
        }
      },
    );
  });
}
