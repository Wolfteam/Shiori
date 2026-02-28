import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const _dbFolder = 'shiori_custom_build_bloc_tests';

void main() {
  late GenshinService genshinService;
  late DataService dataService;
  late TelemetryService telemetryService;
  late LoggingService loggingService;
  late CustomBuildsBloc customBuildsBloc;
  late ResourceService resourceService;
  late final String dbPath;

  const keqingKey = 'keqing';
  const ganyuKey = 'ganyu';
  const aquilaFavoniaKey = 'aquila-favonia';
  const thunderingFuryKey = 'thundering-fury';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = SettingsServiceImpl(MockLoggingService());
    final localeService = LocaleServiceImpl(settingsService);
    resourceService = getResourceService(settingsService);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    dataService = DataServiceImpl(
      genshinService,
      CalculatorAscMaterialsServiceImpl(genshinService, resourceService),
      resourceService,
    );
    telemetryService = MockTelemetryService();
    loggingService = MockLoggingService();
    customBuildsBloc = CustomBuildsBloc(dataService);

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
      dbPath = await getDbPath(_dbFolder);
      await dataService.initForTests(dbPath);
    });
  });

  tearDownAll(() {
    return Future(() async {
      await dataService.closeThemAll();
      await deleteDbFolder(dbPath);
    });
  });

  CustomBuildBloc getBloc() => CustomBuildBloc(
    genshinService,
    dataService,
    telemetryService,
    loggingService,
    resourceService,
    customBuildsBloc,
  );

  Future<CustomBuildModel> saveCustomBuild(String charKey) {
    final artifact = genshinService.artifacts.getArtifactForCard(thunderingFuryKey);
    final weapon = genshinService.weapons.getWeapon(aquilaFavoniaKey);
    return dataService.customBuilds.saveCustomBuild(
      charKey,
      '$charKey pro DPS',
      CharacterRoleType.dps,
      CharacterRoleSubType.electro,
      true,
      true,
      const [CustomBuildNoteModel(index: 0, note: 'You need 200ER')],
      [
        CustomBuildWeaponModel(
          key: weapon.key,
          index: 0,
          rarity: weapon.rarity,
          refinement: 5,
          subStatType: weapon.secondaryStat,
          name: 'Aquila Favonia',
          image: weapon.image,
          stat: weapon.stats.last,
          stats: weapon.stats,
        ),
      ],
      [
        CustomBuildArtifactModel(
          key: artifact.key,
          type: ArtifactType.flower,
          name: artifact.name,
          statType: StatType.hp,
          image: artifact.image,
          rarity: artifact.rarity,
          subStats: [
            StatType.critRatePercentage,
            StatType.critDmgPercentage,
            StatType.atkPercentage,
            StatType.atk,
          ],
        ),
        CustomBuildArtifactModel(
          key: artifact.key,
          type: ArtifactType.plume,
          name: artifact.name,
          statType: StatType.atk,
          image: artifact.image,
          rarity: artifact.rarity,
          subStats: [
            StatType.critRatePercentage,
            StatType.critDmgPercentage,
            StatType.atkPercentage,
          ],
        ),
        CustomBuildArtifactModel(
          key: artifact.key,
          type: ArtifactType.clock,
          name: artifact.name,
          statType: StatType.atkPercentage,
          image: artifact.image,
          rarity: artifact.rarity,
          subStats: [
            StatType.critRatePercentage,
            StatType.critDmgPercentage,
            StatType.atk,
          ],
        ),
        CustomBuildArtifactModel(
          key: artifact.key,
          type: ArtifactType.goblet,
          name: artifact.name,
          statType: StatType.electroDmgBonusPercentage,
          image: artifact.image,
          rarity: artifact.rarity,
          subStats: [
            StatType.critRatePercentage,
            StatType.critDmgPercentage,
            StatType.atkPercentage,
          ],
        ),
        CustomBuildArtifactModel(
          key: artifact.key,
          type: ArtifactType.crown,
          name: artifact.name,
          statType: StatType.critDmgPercentage,
          image: artifact.image,
          rarity: artifact.rarity,
          subStats: [
            StatType.critRatePercentage,
            StatType.atkPercentage,
            StatType.energyRechargePercentage,
          ],
        ),
      ],
      const [
        CustomBuildTeamCharacterModel(
          key: 'fischl',
          index: 0,
          name: 'Fischl',
          image: '',
          iconImage: '',
          roleType: CharacterRoleType.offFieldDps,
          subType: CharacterRoleSubType.electro,
        ),
        CustomBuildTeamCharacterModel(
          key: 'beidou',
          index: 1,
          name: 'Beidou',
          image: '',
          iconImage: '',
          roleType: CharacterRoleType.offFieldDps,
          subType: CharacterRoleSubType.electro,
        ),
        CustomBuildTeamCharacterModel(
          key: 'bennett',
          index: 2,
          name: 'Bennett',
          image: '',
          iconImage: '',
          roleType: CharacterRoleType.burstSupport,
          subType: CharacterRoleSubType.pyro,
        ),
      ],
      [CharacterSkillType.elementalBurst, CharacterSkillType.elementalSkill, CharacterSkillType.normalAttack],
    );
  }

  test(
    'Initial state',
    () => expect(getBloc().state, const CustomBuildState.loading(), reason: 'Should match expected value (property=state)'),
  );

  group('Load', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'create',
      build: () => getBloc(),
      act: (bloc) => bloc.add(const CustomBuildEvent.load(initialTitle: 'DPS PRO')),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            final character = genshinService.characters.getCharactersForCard().first;
            expect(state.title, 'DPS PRO', reason: 'Should match expected value (property=title, expected=\'DPS PRO\')');
            expect(
              state.type,
              CharacterRoleType.dps,
              reason: 'Should match expected value (property=type, expected=CharacterRoleType.dps)',
            );
            expect(
              state.subType,
              CharacterRoleSubType.none,
              reason: 'Should match expected value (property=subType, expected=CharacterRoleSubType.none)',
            );
            expect(
              state.showOnCharacterDetail,
              true,
              reason: 'Should match expected value (property=showOnCharacterDetail, expected=true)',
            );
            expect(state.isRecommended, false, reason: 'Should match expected value (property=isRecommended, expected=false)');
            expect(state.character.key, character.key, reason: 'Should match expected value (property=key)');
            expect(state.weapons.isEmpty, true, reason: 'Should match expected value (property=weapons, expected=true)');
            expect(state.artifacts.isEmpty, true, reason: 'Should match expected value (property=artifacts, expected=true)');
            expect(
              state.teamCharacters.isEmpty,
              true,
              reason: 'Should match expected value (property=teamCharacters, expected=true)',
            );
            expect(state.notes.isEmpty, true, reason: 'Should match expected value (property=notes, expected=true)');
            expect(
              state.skillPriorities.isEmpty,
              true,
              reason: 'Should match expected value (property=skillPriorities, expected=true)',
            );
            expect(
              state.subStatsSummary.isEmpty,
              true,
              reason: 'Should match expected value (property=subStatsSummary, expected=true)',
            );
        }
      },
    );

    int buildKey = 0;
    blocTest<CustomBuildBloc, CustomBuildState>(
      'existing $keqingKey build',
      setUp: () async {
        final build = await saveCustomBuild(keqingKey);
        buildKey = build.key;
      },
      build: () => getBloc(),
      act: (bloc) => bloc.add(CustomBuildEvent.load(initialTitle: 'XXX', key: buildKey)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.title,
              '$keqingKey pro DPS',
              reason: 'Should match expected value (property=title, expected=\'$keqingKey pro DPS\')',
            );
            expect(
              state.type,
              CharacterRoleType.dps,
              reason: 'Should match expected value (property=type, expected=CharacterRoleType.dps)',
            );
            expect(
              state.subType,
              CharacterRoleSubType.electro,
              reason: 'Should match expected value (property=subType, expected=CharacterRoleSubType.electro)',
            );
            expect(
              state.showOnCharacterDetail,
              true,
              reason: 'Should match expected value (property=showOnCharacterDetail, expected=true)',
            );
            expect(state.isRecommended, true, reason: 'Should match expected value (property=isRecommended, expected=true)');
            expect(state.character.key, keqingKey, reason: 'Should match expected value (property=key)');
            expect(state.weapons.length == 1, true, reason: 'Should match expected value (property=length == 1, expected=true)');
            expect(
              state.artifacts.length == 5,
              true,
              reason: 'Should match expected value (property=length == 5, expected=true)',
            );
            expect(
              state.teamCharacters.length == 3,
              true,
              reason: 'Should match expected value (property=length == 3, expected=true)',
            );
            expect(state.notes.length == 1, true, reason: 'Should match expected value (property=length == 1, expected=true)');
            expect(
              state.skillPriorities.length == 3,
              true,
              reason: 'Should match expected value (property=length == 3, expected=true)',
            );
            expect(
              state.subStatsSummary.isNotEmpty,
              true,
              reason: 'Should match expected value (property=subStatsSummary, expected=true)',
            );
        }
      },
    );
  });

  group('General', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'character changed',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: ganyuKey)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.character.key, ganyuKey, reason: 'Should match expected value (property=key)');
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'title changed',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.titleChanged(newValue: 'KEQING PRO')),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.title, 'KEQING PRO', reason: 'Should match expected value (property=title, expected=\'KEQING PRO\')');
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'role changed',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.roleChanged(newValue: CharacterRoleType.offFieldDps)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.type,
              CharacterRoleType.offFieldDps,
              reason: 'Should match expected value (property=type, expected=CharacterRoleType.offFieldDps)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'sub role changed',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.subRoleChanged(newValue: CharacterRoleSubType.cryo)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.subType,
              CharacterRoleSubType.cryo,
              reason: 'Should match expected value (property=subType, expected=CharacterRoleSubType.cryo)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'show on character detail changed',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.showOnCharacterDetailChanged(newValue: false)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.showOnCharacterDetail,
              false,
              reason: 'Should match expected value (property=showOnCharacterDetail, expected=false)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'is recommended changed',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.isRecommendedChanged(newValue: true)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.isRecommended, true, reason: 'Should match expected value (property=isRecommended, expected=true)');
        }
      },
    );
  });

  group('Notes', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'add',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addNote(note: 'This build needs 200 ER'))
        ..add(const CustomBuildEvent.addNote(note: 'You need C6')),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.notes.length == 2, true, reason: 'Should match expected value (property=length == 2, expected=true)');
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, note is not valid',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addNote(note: 'This build needs 200 ER'))
        ..add(const CustomBuildEvent.addNote(note: '')),
      errors: () => [predicate<ArgumentError>((e) => e.name == 'note')],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addNote(note: 'This build needs 200 ER'))
        ..add(const CustomBuildEvent.deleteNote(index: 0)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.notes.isEmpty, true, reason: 'Should match expected value (property=notes, expected=true)');
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete, index is not valid',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addNote(note: 'This build needs 200 ER'))
        ..add(const CustomBuildEvent.deleteNote(index: 10)),
      errors: () => [predicate<RangeError>((e) => e.name == 'index')],
    );
  });

  group('Skill priorities', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'add',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalSkill)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.skillPriorities.length == 2,
              true,
              reason: 'Should match expected value (property=length == 2, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, skill already exist',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalSkill))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalSkill)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.skillPriorities.length == 2,
              true,
              reason: 'Should match expected value (property=length == 2, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, skill is not valid',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.others)),
      errors: () => [predicate<ArgumentError>((e) => e.name == 'type')],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.normalAttack))
        ..add(const CustomBuildEvent.deleteSkillPriority(index: 1)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.skillPriorities.length == 1,
              true,
              reason: 'Should match expected value (property=length == 1, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete, index is not valid',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
        ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.normalAttack))
        ..add(const CustomBuildEvent.deleteSkillPriority(index: 2)),
      errors: () => [predicate<RangeError>((e) => e.name == 'index')],
    );
  });

  group('Weapons', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'add',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.weapons.length == 1, true, reason: 'Should match expected value (property=length == 1, expected=true)');
            expect(
              state.weapons.first.key == aquilaFavoniaKey,
              true,
              reason: 'Should match expected value (property=key == aquilaFavoniaKey, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, weapon already exists',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey)),
      errors: () => [predicate<UnsupportedError>((e) => e.message!.contains('repeated'))],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, weapon is not valid for current character',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: ganyuKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey)),
      errors: () => [predicate<UnsupportedError>((e) => e.message!.contains('not valid'))],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'refinement changed',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: aquilaFavoniaKey, newValue: 5)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.weapons.first.refinement == 5,
              true,
              reason: 'Should match expected value (property=refinement == 5, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'refinement changed, weapon does not exist',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: aquilaFavoniaKey, newValue: 5)),
      errors: () => [isA<NotFoundError>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'refinement changed, refinement has not changed',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: aquilaFavoniaKey, newValue: 5))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: aquilaFavoniaKey, newValue: 5)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.weapons.first.refinement == 5,
              true,
              reason: 'Should match expected value (property=refinement == 5, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'refinement changed, invalid value',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: aquilaFavoniaKey, newValue: 6)),
      errors: () => [predicate<RangeError>((e) => e.name == 'newValue')],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: aquilaFavoniaKey, newValue: 5))
        ..add(const CustomBuildEvent.deleteWeapon(key: aquilaFavoniaKey)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.weapons.isEmpty, true, reason: 'Should match expected value (property=weapons, expected=true)');
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete, weapon does not exist',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey))
        ..add(const CustomBuildEvent.weaponRefinementChanged(key: aquilaFavoniaKey, newValue: 5))
        ..add(const CustomBuildEvent.deleteWeapon(key: aquilaFavoniaKey))
        ..add(const CustomBuildEvent.deleteWeapon(key: aquilaFavoniaKey)),
      errors: () => [isA<NotFoundError>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete all weapons',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey))
        ..add(const CustomBuildEvent.deleteWeapons()),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.weapons.isEmpty, true, reason: 'Should match expected value (property=weapons, expected=true)');
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'order changed',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey))
        ..add(const CustomBuildEvent.addWeapon(key: 'the-flute'))
        ..add(
          CustomBuildEvent.weaponsOrderChanged(
            weapons: [
              SortableItem('the-flute', 'The Flute'),
              SortableItem(aquilaFavoniaKey, 'Aquila Favonia'),
            ],
          ),
        ),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.weapons.length == 2, true, reason: 'Should match expected value (property=length == 2, expected=true)');
            expect(
              state.weapons.first.key == 'the-flute',
              true,
              reason: 'Should match expected value (property=key == \'the-flute\', expected=true)',
            );
            expect(
              state.weapons.last.key == aquilaFavoniaKey,
              true,
              reason: 'Should match expected value (property=key == aquilaFavoniaKey, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'stat changed',
      build: () => getBloc(),
      act: (bloc) {
        final weapon = genshinService.weapons.getWeapon(aquilaFavoniaKey);
        return bloc
          ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
          ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
          ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey))
          ..add(CustomBuildEvent.weaponStatChanged(key: aquilaFavoniaKey, newValue: weapon.stats[3]));
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            final stat = genshinService.weapons.getWeapon(aquilaFavoniaKey).stats[3];
            expect(state.weapons.length == 1, true, reason: 'Should match expected value (property=length == 1, expected=true)');
            expect(
              state.weapons.first.key == aquilaFavoniaKey,
              true,
              reason: 'Should match expected value (property=key == aquilaFavoniaKey, expected=true)',
            );
            expect(
              state.weapons.first.stat == stat,
              true,
              reason: 'Should match expected value (property=stat == stat, expected=true)',
            );
        }
      },
    );
  });

  group('Artifacts', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'add',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.artifacts.length == 1,
              true,
              reason: 'Should match expected value (property=length == 1, expected=true)',
            );
            final artifact = state.artifacts.first;
            expect(
              artifact.key == thunderingFuryKey,
              true,
              reason: 'Should match expected value (property=key == thunderingFuryKey, expected=true)',
            );
            expect(
              artifact.type == ArtifactType.flower,
              true,
              reason: 'Should match expected value (property=flower, expected=true)',
            );
            expect(artifact.statType == StatType.hp, true, reason: 'Should match expected value (property=hp, expected=true)');
            expect(artifact.subStats.isEmpty, true, reason: 'Should match expected value (property=subStats, expected=true)');
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, type already exists',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.crown, statType: StatType.hp))
        ..add(
          const CustomBuildEvent.addArtifact(
            key: thunderingFuryKey,
            type: ArtifactType.crown,
            statType: StatType.critDmgPercentage,
          ),
        ),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.artifacts.length == 1,
              true,
              reason: 'Should match expected value (property=length == 1, expected=true)',
            );
            final artifact = state.artifacts.first;
            expect(
              artifact.key == thunderingFuryKey,
              true,
              reason: 'Should match expected value (property=key == thunderingFuryKey, expected=true)',
            );
            expect(
              artifact.type == ArtifactType.crown,
              true,
              reason: 'Should match expected value (property=crown, expected=true)',
            );
            expect(
              artifact.statType == StatType.critDmgPercentage,
              true,
              reason: 'Should match expected value (property=critDmgPercentage, expected=true)',
            );
            expect(artifact.subStats.isEmpty, true, reason: 'Should match expected value (property=subStats, expected=true)');
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add all types',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.plume, statType: StatType.atk))
        ..add(
          const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.clock, statType: StatType.atkPercentage),
        )
        ..add(
          const CustomBuildEvent.addArtifact(
            key: thunderingFuryKey,
            type: ArtifactType.goblet,
            statType: StatType.electroDmgBonusPercentage,
          ),
        )
        ..add(
          const CustomBuildEvent.addArtifact(
            key: thunderingFuryKey,
            type: ArtifactType.crown,
            statType: StatType.critRatePercentage,
          ),
        ),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.artifacts.length == 5,
              true,
              reason: 'Should match expected value (property=length == 5, expected=true)',
            );
            final expectedStatTypes = [
              StatType.hp,
              StatType.atk,
              StatType.atkPercentage,
              StatType.electroDmgBonusPercentage,
              StatType.critRatePercentage,
            ];
            for (var i = 0; i < state.artifacts.length; i++) {
              final artifact = state.artifacts[i];
              expect(
                artifact.key == thunderingFuryKey,
                true,
                reason: 'Should match expected value (property=key == thunderingFuryKey, expected=true)',
              );
              expect(
                artifact.type == ArtifactType.values[i],
                true,
                reason: 'Should match expected value (property=values[i], expected=true)',
              );
              expect(
                artifact.statType == expectedStatTypes[i],
                true,
                reason: 'Should match expected value (property=statType == expectedStatTypes[i], expected=true)',
              );
              expect(artifact.subStats.isEmpty, true, reason: 'Should match expected value (property=subStats, expected=true)');
            }
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add all types but updated the last one',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.plume, statType: StatType.atk))
        ..add(
          const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.clock, statType: StatType.atkPercentage),
        )
        ..add(
          const CustomBuildEvent.addArtifact(
            key: thunderingFuryKey,
            type: ArtifactType.goblet,
            statType: StatType.electroDmgBonusPercentage,
          ),
        )
        ..add(
          const CustomBuildEvent.addArtifact(
            key: thunderingFuryKey,
            type: ArtifactType.crown,
            statType: StatType.critRatePercentage,
          ),
        )
        ..add(
          const CustomBuildEvent.addArtifact(
            key: thunderingFuryKey,
            type: ArtifactType.crown,
            statType: StatType.critDmgPercentage,
          ),
        ),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.artifacts.length == 5,
              true,
              reason: 'Should match expected value (property=length == 5, expected=true)',
            );
            final expectedStatTypes = [
              StatType.hp,
              StatType.atk,
              StatType.atkPercentage,
              StatType.electroDmgBonusPercentage,
              StatType.critDmgPercentage,
            ];
            for (var i = 0; i < state.artifacts.length; i++) {
              final artifact = state.artifacts[i];
              expect(
                artifact.key == thunderingFuryKey,
                true,
                reason: 'Should match expected value (property=key == thunderingFuryKey, expected=true)',
              );
              expect(
                artifact.type == ArtifactType.values[i],
                true,
                reason: 'Should match expected value (property=values[i], expected=true)',
              );
              expect(
                artifact.statType == expectedStatTypes[i],
                true,
                reason: 'Should match expected value (property=statType == expectedStatTypes[i], expected=true)',
              );
              expect(artifact.subStats.isEmpty, true, reason: 'Should match expected value (property=subStats, expected=true)');
            }
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add sub stats',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
        ..add(
          const CustomBuildEvent.addArtifactSubStats(
            type: ArtifactType.flower,
            subStats: [StatType.critDmgPercentage, StatType.critRatePercentage, StatType.atkPercentage, StatType.atk],
          ),
        )
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.plume, statType: StatType.atk))
        ..add(
          const CustomBuildEvent.addArtifactSubStats(
            type: ArtifactType.plume,
            subStats: [StatType.critDmgPercentage, StatType.critRatePercentage, StatType.atkPercentage],
          ),
        ),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.artifacts.length == 2,
              true,
              reason: 'Should match expected value (property=length == 2, expected=true)',
            );
            final flower = state.artifacts.first;
            expect(
              flower.type,
              ArtifactType.flower,
              reason: 'Should match expected value (property=type, expected=ArtifactType.flower)',
            );
            expect(
              listEquals(flower.subStats, [
                StatType.critDmgPercentage,
                StatType.critRatePercentage,
                StatType.atkPercentage,
                StatType.atk,
              ]),
              true,
              reason: 'Should match expected value (property=atk]), expected=true)',
            );

            final plume = state.artifacts.last;
            expect(
              plume.type,
              ArtifactType.plume,
              reason: 'Should match expected value (property=type, expected=ArtifactType.plume)',
            );
            expect(
              listEquals(plume.subStats, [StatType.critDmgPercentage, StatType.critRatePercentage, StatType.atkPercentage]),
              true,
              reason: 'Should match expected value (property=atkPercentage]), expected=true)',
            );

            expect(
              state.subStatsSummary.isNotEmpty,
              true,
              reason: 'Should match expected value (property=subStatsSummary, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add sub stats, artifact does not exist',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addArtifactSubStats(
            type: ArtifactType.crown,
            subStats: [StatType.critRatePercentage, StatType.critDmgPercentage],
          ),
        ),
      errors: () => [isA<NotFoundError>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add sub-stats, sub-stat is not valid',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp),
        )
        ..add(
          const CustomBuildEvent.addArtifactSubStats(
            type: ArtifactType.flower,
            subStats: [StatType.critRatePercentage, StatType.hp],
          ),
        ),
      errors: () => [predicate<ArgumentError>((e) => e.name == 'substats')],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
        ..add(const CustomBuildEvent.deleteArtifact(type: ArtifactType.flower)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.artifacts.isEmpty, true, reason: 'Should match expected value (property=artifacts, expected=true)');
            expect(
              state.subStatsSummary.isEmpty,
              true,
              reason: 'Should match expected value (property=subStatsSummary, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete, type does not exist',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
        ..add(const CustomBuildEvent.deleteArtifact(type: ArtifactType.crown)),
      errors: () => [isA<NotFoundError>()],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete all artifacts',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
        ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.plume, statType: StatType.atk))
        ..add(const CustomBuildEvent.deleteArtifacts()),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.artifacts.isEmpty, true, reason: 'Should match expected value (property=artifacts, expected=true)');
        }
      },
    );
  });

  group('Team characters', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'add',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addTeamCharacter(
            key: ganyuKey,
            roleType: CharacterRoleType.offFieldDps,
            subType: CharacterRoleSubType.electro,
          ),
        ),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.teamCharacters.length == 1,
              true,
              reason: 'Should match expected value (property=length == 1, expected=true)',
            );
            final char = state.teamCharacters.first;
            expect(
              char.roleType,
              CharacterRoleType.offFieldDps,
              reason: 'Should match expected value (property=roleType, expected=CharacterRoleType.offFieldDps)',
            );
            expect(
              char.subType,
              CharacterRoleSubType.electro,
              reason: 'Should match expected value (property=subType, expected=CharacterRoleSubType.electro)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add, team character is the same as the main one',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: ganyuKey))
        ..add(
          const CustomBuildEvent.addTeamCharacter(
            key: ganyuKey,
            roleType: CharacterRoleType.offFieldDps,
            subType: CharacterRoleSubType.electro,
          ),
        ),
      errors: () => [predicate<ArgumentError>((e) => e.name == 'key')],
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'add the same character multiple times',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addTeamCharacter(
            key: ganyuKey,
            roleType: CharacterRoleType.offFieldDps,
            subType: CharacterRoleSubType.electro,
          ),
        )
        ..add(
          const CustomBuildEvent.addTeamCharacter(
            key: ganyuKey,
            roleType: CharacterRoleType.offFieldDps,
            subType: CharacterRoleSubType.electro,
          ),
        ),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.teamCharacters.length == 1,
              true,
              reason: 'Should match expected value (property=length == 1, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'order changed',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addTeamCharacter(
            key: ganyuKey,
            roleType: CharacterRoleType.offFieldDps,
            subType: CharacterRoleSubType.cryo,
          ),
        )
        ..add(
          const CustomBuildEvent.addTeamCharacter(
            key: keqingKey,
            roleType: CharacterRoleType.dps,
            subType: CharacterRoleSubType.electro,
          ),
        )
        ..add(
          CustomBuildEvent.teamCharactersOrderChanged(
            characters: [
              SortableItem(keqingKey, 'Keqing'),
              SortableItem(ganyuKey, 'Ganyu'),
            ],
          ),
        ),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.teamCharacters.length == 2,
              true,
              reason: 'Should match expected value (property=length == 2, expected=true)',
            );
            final keqing = state.teamCharacters.first;
            expect(
              keqing.roleType,
              CharacterRoleType.dps,
              reason: 'Should match expected value (property=roleType, expected=CharacterRoleType.dps)',
            );
            expect(
              keqing.subType,
              CharacterRoleSubType.electro,
              reason: 'Should match expected value (property=subType, expected=CharacterRoleSubType.electro)',
            );

            final ganyu = state.teamCharacters.last;
            expect(
              ganyu.roleType,
              CharacterRoleType.offFieldDps,
              reason: 'Should match expected value (property=roleType, expected=CharacterRoleType.offFieldDps)',
            );
            expect(
              ganyu.subType,
              CharacterRoleSubType.cryo,
              reason: 'Should match expected value (property=subType, expected=CharacterRoleSubType.cryo)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(
          const CustomBuildEvent.addTeamCharacter(
            key: ganyuKey,
            roleType: CharacterRoleType.offFieldDps,
            subType: CharacterRoleSubType.electro,
          ),
        )
        ..add(const CustomBuildEvent.deleteTeamCharacter(key: ganyuKey)),
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(
              state.teamCharacters.isEmpty,
              true,
              reason: 'Should match expected value (property=teamCharacters, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'delete, team character does not exist',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.deleteTeamCharacter(key: ganyuKey)),
      errors: () => [isA<NotFoundError>()],
    );
  });

  group('Save', () {
    blocTest<CustomBuildBloc, CustomBuildState>(
      'all stuff was set',
      build: () => getBloc(),
      act: (bloc) {
        final weapon = genshinService.weapons.getWeapon(aquilaFavoniaKey);
        return bloc
          ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
          ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
          ..add(const CustomBuildEvent.isRecommendedChanged(newValue: true))
          ..add(const CustomBuildEvent.showOnCharacterDetailChanged(newValue: false))
          ..add(const CustomBuildEvent.addNote(note: 'You need C6'))
          ..add(const CustomBuildEvent.addSkillPriority(type: CharacterSkillType.elementalBurst))
          ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.flower, statType: StatType.hp))
          ..add(const CustomBuildEvent.addArtifact(key: thunderingFuryKey, type: ArtifactType.plume, statType: StatType.atk))
          ..add(
            const CustomBuildEvent.addArtifact(
              key: thunderingFuryKey,
              type: ArtifactType.clock,
              statType: StatType.atkPercentage,
            ),
          )
          ..add(
            const CustomBuildEvent.addArtifact(
              key: thunderingFuryKey,
              type: ArtifactType.goblet,
              statType: StatType.electroDmgBonusPercentage,
            ),
          )
          ..add(
            const CustomBuildEvent.addArtifact(
              key: thunderingFuryKey,
              type: ArtifactType.crown,
              statType: StatType.critDmgPercentage,
            ),
          )
          ..add(
            const CustomBuildEvent.addArtifactSubStats(
              type: ArtifactType.crown,
              subStats: [
                StatType.critRatePercentage,
                StatType.atkPercentage,
                StatType.atk,
              ],
            ),
          )
          ..add(const CustomBuildEvent.addWeapon(key: aquilaFavoniaKey))
          ..add(CustomBuildEvent.weaponStatChanged(key: aquilaFavoniaKey, newValue: weapon.stats.first))
          ..add(
            const CustomBuildEvent.addTeamCharacter(
              key: ganyuKey,
              roleType: CharacterRoleType.offFieldDps,
              subType: CharacterRoleSubType.cryo,
            ),
          )
          ..add(const CustomBuildEvent.saveChanges());
      },
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            final stat = genshinService.weapons.getWeapon(aquilaFavoniaKey).stats.first;
            expect(state.character.key, keqingKey, reason: 'Should match expected value (property=key)');
            expect(state.isRecommended, true, reason: 'Should match expected value (property=isRecommended, expected=true)');
            expect(
              state.showOnCharacterDetail,
              false,
              reason: 'Should match expected value (property=showOnCharacterDetail, expected=false)',
            );
            expect(
              state.skillPriorities.length == 1,
              true,
              reason: 'Should match expected value (property=length == 1, expected=true)',
            );
            expect(state.notes.length == 1, true, reason: 'Should match expected value (property=length == 1, expected=true)');
            expect(state.weapons.length == 1, true, reason: 'Should match expected value (property=length == 1, expected=true)');
            expect(state.weapons.first.stat.level, stat.level, reason: 'Should match expected value (property=level)');
            expect(
              state.weapons.first.stat.isAnAscension,
              stat.isAnAscension,
              reason: 'Should match expected value (property=isAnAscension)',
            );
            expect(
              state.artifacts.length == 5,
              true,
              reason: 'Should match expected value (property=length == 5, expected=true)',
            );
            expect(
              state.subStatsSummary.isNotEmpty,
              true,
              reason: 'Should match expected value (property=subStatsSummary, expected=true)',
            );
            expect(
              state.teamCharacters.length == 1,
              true,
              reason: 'Should match expected value (property=length == 1, expected=true)',
            );
        }
      },
    );

    blocTest<CustomBuildBloc, CustomBuildState>(
      'nothing was set',
      build: () => getBloc(),
      act: (bloc) => bloc
        ..add(const CustomBuildEvent.load(initialTitle: 'DPS PRO'))
        ..add(const CustomBuildEvent.characterChanged(newKey: keqingKey))
        ..add(const CustomBuildEvent.saveChanges()),
      errors: () => [isA<ArgumentError>()],
      verify: (bloc) {
        final state = bloc.state;
        switch (state) {
          case CustomBuildStateLoading():
            throw Exception('Invalid custom build state');
          case CustomBuildStateLoaded():
            expect(state.character.key, keqingKey, reason: 'Should match expected value (property=key)');
            expect(state.isRecommended, false, reason: 'Should match expected value (property=isRecommended, expected=false)');
            expect(
              state.showOnCharacterDetail,
              true,
              reason: 'Should match expected value (property=showOnCharacterDetail, expected=true)',
            );
            expect(
              state.skillPriorities.isEmpty,
              true,
              reason: 'Should match expected value (property=skillPriorities, expected=true)',
            );
            expect(state.notes.isEmpty, true, reason: 'Should match expected value (property=notes, expected=true)');
            expect(state.weapons.isEmpty, true, reason: 'Should match expected value (property=weapons, expected=true)');
            expect(state.artifacts.isEmpty, true, reason: 'Should match expected value (property=artifacts, expected=true)');
            expect(
              state.subStatsSummary.isEmpty,
              true,
              reason: 'Should match expected value (property=subStatsSummary, expected=true)',
            );
            expect(
              state.teamCharacters.isEmpty,
              true,
              reason: 'Should match expected value (property=teamCharacters, expected=true)',
            );
        }
      },
    );
  });
}
