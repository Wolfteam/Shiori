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
    () => expect(getBloc().state, const CustomBuildState.loading(), reason: 'A freshly constructed CustomBuildBloc should start in CustomBuildState.loading'),
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
            expect(state.title, 'DPS PRO', reason: "load(initialTitle:'DPS PRO') should seed the title to 'DPS PRO'");
            expect(
              state.type,
              CharacterRoleType.dps,
              reason: 'A new build should default its role type to dps',
            );
            expect(
              state.subType,
              CharacterRoleSubType.none,
              reason: 'A new build should default its sub role to none',
            );
            expect(
              state.showOnCharacterDetail,
              true,
              reason: 'A new build should default showOnCharacterDetail to true',
            );
            expect(state.isRecommended, false, reason: 'A new build should default isRecommended to false');
            expect(state.character.key, character.key, reason: 'A new build should default to the first character card (expected key=${character.key})');
            expect(state.weapons.isEmpty, true, reason: 'A new build should start with no weapons');
            expect(state.artifacts.isEmpty, true, reason: 'A new build should start with no artifacts');
            expect(
              state.teamCharacters.isEmpty,
              true,
              reason: 'A new build should start with no team characters',
            );
            expect(state.notes.isEmpty, true, reason: 'A new build should start with no notes');
            expect(
              state.skillPriorities.isEmpty,
              true,
              reason: 'A new build should start with no skill priorities',
            );
            expect(
              state.subStatsSummary.isEmpty,
              true,
              reason: 'A new build with no artifacts should have an empty sub-stats summary',
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
              reason: 'Loading an existing build should restore its saved title (key=$keqingKey)',
            );
            expect(
              state.type,
              CharacterRoleType.dps,
              reason: 'Loading an existing build should restore role type dps (key=$keqingKey)',
            );
            expect(
              state.subType,
              CharacterRoleSubType.electro,
              reason: 'Loading an existing build should restore sub role electro (key=$keqingKey)',
            );
            expect(
              state.showOnCharacterDetail,
              true,
              reason: 'Loading an existing build should restore showOnCharacterDetail=true (key=$keqingKey)',
            );
            expect(state.isRecommended, true, reason: 'Loading an existing build should restore isRecommended=true (key=$keqingKey)');
            expect(state.character.key, keqingKey, reason: 'Loading an existing build should restore its character (expected key=$keqingKey)');
            expect(state.weapons.length == 1, true, reason: 'Loaded build should restore its single weapon, got ${state.weapons.length}');
            expect(
              state.artifacts.length == 5,
              true,
              reason: 'Loaded build should restore all 5 artifacts, got ${state.artifacts.length}',
            );
            expect(
              state.teamCharacters.length == 3,
              true,
              reason: 'Loaded build should restore all 3 team characters, got ${state.teamCharacters.length}',
            );
            expect(state.notes.length == 1, true, reason: 'Loaded build should restore its single note, got ${state.notes.length}');
            expect(
              state.skillPriorities.length == 3,
              true,
              reason: 'Loaded build should restore all 3 skill priorities, got ${state.skillPriorities.length}',
            );
            expect(
              state.subStatsSummary.isNotEmpty,
              true,
              reason: 'Loaded build with artifacts should compute a non-empty sub-stats summary',
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
            expect(state.character.key, ganyuKey, reason: 'characterChanged($ganyuKey) should switch the build character to $ganyuKey');
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
            expect(state.title, 'KEQING PRO', reason: "titleChanged('KEQING PRO') should update the build title");
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
              reason: 'roleChanged(offFieldDps) should set the build role type to offFieldDps',
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
              reason: 'subRoleChanged(cryo) should set the build sub role to cryo',
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
              reason: 'showOnCharacterDetailChanged(false) should set showOnCharacterDetail to false',
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
            expect(state.isRecommended, true, reason: 'isRecommendedChanged(true) should set isRecommended to true');
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
            expect(state.notes.length == 2, true, reason: 'Adding two notes should leave 2 notes, got ${state.notes.length}');
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
            expect(state.notes.isEmpty, true, reason: 'Deleting the only note (index 0) should leave no notes');
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
              reason: 'Adding two distinct skill priorities should leave 2, got ${state.skillPriorities.length}',
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
              reason: 'Re-adding an existing skill priority should not duplicate it (still 2)',
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
              reason: 'Deleting one of two skill priorities should leave 1, got ${state.skillPriorities.length}',
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
            expect(state.weapons.length == 1, true, reason: 'addWeapon should leave exactly 1 weapon, got ${state.weapons.length}');
            expect(
              state.weapons.first.key == aquilaFavoniaKey,
              true,
              reason: 'Added weapon should be $aquilaFavoniaKey, got ${state.weapons.first.key}',
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
              reason: 'weaponRefinementChanged(5) should set the weapon refinement to 5, got ${state.weapons.first.refinement}',
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
              reason: 'Re-applying refinement 5 should keep it at 5, got ${state.weapons.first.refinement}',
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
            expect(state.weapons.isEmpty, true, reason: 'deleteWeapon($aquilaFavoniaKey) should leave no weapons');
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
            expect(state.weapons.isEmpty, true, reason: 'deleteWeapons() should remove all weapons');
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
            expect(state.weapons.length == 2, true, reason: 'weaponsOrderChanged should keep both weapons, got ${state.weapons.length}');
            expect(
              state.weapons.first.key == 'the-flute',
              true,
              reason: 'weaponsOrderChanged should reorder the-flute to first, got ${state.weapons.first.key}',
            );
            expect(
              state.weapons.last.key == aquilaFavoniaKey,
              true,
              reason: 'weaponsOrderChanged should reorder $aquilaFavoniaKey to last, got ${state.weapons.last.key}',
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
            expect(state.weapons.length == 1, true, reason: 'weaponStatChanged should keep the single weapon, got ${state.weapons.length}');
            expect(
              state.weapons.first.key == aquilaFavoniaKey,
              true,
              reason: 'weaponStatChanged should target $aquilaFavoniaKey, got ${state.weapons.first.key}',
            );
            expect(
              state.weapons.first.stat == stat,
              true,
              reason: 'weaponStatChanged should set the weapon stat to the requested stats[3]',
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
              reason: 'addArtifact should leave exactly 1 artifact, got ${state.artifacts.length}',
            );
            final artifact = state.artifacts.first;
            expect(
              artifact.key == thunderingFuryKey,
              true,
              reason: 'Added artifact should belong to set $thunderingFuryKey, got ${artifact.key}',
            );
            expect(
              artifact.type == ArtifactType.flower,
              true,
              reason: 'Added artifact type should be flower, got ${artifact.type}',
            );
            expect(artifact.statType == StatType.hp, true, reason: 'Added flower main stat should be hp, got ${artifact.statType}');
            expect(artifact.subStats.isEmpty, true, reason: 'A freshly added artifact should have no sub-stats yet');
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
              reason: 'Re-adding the same crown type should not duplicate it (still 1), got ${state.artifacts.length}',
            );
            final artifact = state.artifacts.first;
            expect(
              artifact.key == thunderingFuryKey,
              true,
              reason: 'Added artifact should belong to set $thunderingFuryKey, got ${artifact.key}',
            );
            expect(
              artifact.type == ArtifactType.crown,
              true,
              reason: 'Artifact type should remain crown, got ${artifact.type}',
            );
            expect(
              artifact.statType == StatType.critDmgPercentage,
              true,
              reason: 'Re-adding crown should overwrite its main stat to critDmgPercentage, got ${artifact.statType}',
            );
            expect(artifact.subStats.isEmpty, true, reason: 'A freshly added artifact should have no sub-stats yet');
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
              reason: 'Build should contain all 5 artifacts, got ${state.artifacts.length}',
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
                reason: 'Artifact at index $i should belong to set $thunderingFuryKey, got ${artifact.key}',
              );
              expect(
                artifact.type == ArtifactType.values[i],
                true,
                reason: 'Artifact at index $i should have type ${ArtifactType.values[i]}, got ${artifact.type}',
              );
              expect(
                artifact.statType == expectedStatTypes[i],
                true,
                reason: 'Artifact at index $i should have main stat ${expectedStatTypes[i]}, got ${artifact.statType}',
              );
              expect(artifact.subStats.isEmpty, true, reason: 'A freshly added artifact should have no sub-stats yet');
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
              reason: 'Build should contain all 5 artifacts, got ${state.artifacts.length}',
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
                reason: 'Artifact at index $i should belong to set $thunderingFuryKey, got ${artifact.key}',
              );
              expect(
                artifact.type == ArtifactType.values[i],
                true,
                reason: 'Artifact at index $i should have type ${ArtifactType.values[i]}, got ${artifact.type}',
              );
              expect(
                artifact.statType == expectedStatTypes[i],
                true,
                reason: 'Artifact at index $i should have main stat ${expectedStatTypes[i]}, got ${artifact.statType}',
              );
              expect(artifact.subStats.isEmpty, true, reason: 'A freshly added artifact should have no sub-stats yet');
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
              reason: 'Two artifacts (flower, plume) should be present, got ${state.artifacts.length}',
            );
            final flower = state.artifacts.first;
            expect(
              flower.type,
              ArtifactType.flower,
              reason: 'First artifact should be the flower',
            );
            expect(
              listEquals(flower.subStats, [
                StatType.critDmgPercentage,
                StatType.critRatePercentage,
                StatType.atkPercentage,
                StatType.atk,
              ]),
              true,
              reason: 'addArtifactSubStats(flower) should store the 4 requested sub-stats in order',
            );

            final plume = state.artifacts.last;
            expect(
              plume.type,
              ArtifactType.plume,
              reason: 'Last artifact should be the plume',
            );
            expect(
              listEquals(plume.subStats, [StatType.critDmgPercentage, StatType.critRatePercentage, StatType.atkPercentage]),
              true,
              reason: 'addArtifactSubStats(plume) should store the 3 requested sub-stats in order',
            );

            expect(
              state.subStatsSummary.isNotEmpty,
              true,
              reason: 'Adding artifact sub-stats should produce a non-empty sub-stats summary',
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
            expect(state.artifacts.isEmpty, true, reason: 'deleteArtifact(flower) should leave no artifacts');
            expect(
              state.subStatsSummary.isEmpty,
              true,
              reason: 'With no artifacts left, the sub-stats summary should be empty',
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
            expect(state.artifacts.isEmpty, true, reason: 'deleteArtifacts() should remove all artifacts');
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
              reason: 'addTeamCharacter should leave exactly 1 team character, got ${state.teamCharacters.length}',
            );
            final char = state.teamCharacters.first;
            expect(
              char.roleType,
              CharacterRoleType.offFieldDps,
              reason: 'Added team character role should be offFieldDps, got ${char.roleType}',
            );
            expect(
              char.subType,
              CharacterRoleSubType.electro,
              reason: 'Added team character sub role should be electro, got ${char.subType}',
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
              reason: 'Adding the same team character twice should not duplicate it (still 1)',
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
              reason: 'teamCharactersOrderChanged should keep both characters, got ${state.teamCharacters.length}',
            );
            final keqing = state.teamCharacters.first;
            expect(
              keqing.roleType,
              CharacterRoleType.dps,
              reason: 'Reorder should move $keqingKey to first, preserving role dps',
            );
            expect(
              keqing.subType,
              CharacterRoleSubType.electro,
              reason: 'Reordered $keqingKey should preserve sub role electro',
            );

            final ganyu = state.teamCharacters.last;
            expect(
              ganyu.roleType,
              CharacterRoleType.offFieldDps,
              reason: 'Reorder should move $ganyuKey to last, preserving role offFieldDps',
            );
            expect(
              ganyu.subType,
              CharacterRoleSubType.cryo,
              reason: 'Reordered $ganyuKey should preserve sub role cryo',
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
              reason: 'deleteTeamCharacter($ganyuKey) should leave no team characters',
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
            expect(state.character.key, keqingKey, reason: 'After saveChanges, state should keep character $keqingKey');
            expect(state.isRecommended, true, reason: 'After saveChanges, isRecommended should stay true');
            expect(
              state.showOnCharacterDetail,
              false,
              reason: 'After saveChanges, showOnCharacterDetail should stay false',
            );
            expect(
              state.skillPriorities.length == 1,
              true,
              reason: 'After saveChanges, the single skill priority should be retained',
            );
            expect(state.notes.length == 1, true, reason: 'After saveChanges, the single note should be retained');
            expect(state.weapons.length == 1, true, reason: 'After saveChanges, the single weapon should be retained');
            expect(state.weapons.first.stat.level, stat.level, reason: 'Saved weapon stat should keep its level (weaponStatChanged to stats.first)');
            expect(
              state.weapons.first.stat.isAnAscension,
              stat.isAnAscension,
              reason: 'Saved weapon stat should keep its isAnAscension flag',
            );
            expect(
              state.artifacts.length == 5,
              true,
              reason: 'Build should contain all 5 artifacts, got ${state.artifacts.length}',
            );
            expect(
              state.subStatsSummary.isNotEmpty,
              true,
              reason: 'After saveChanges with artifact sub-stats, the summary should be non-empty',
            );
            expect(
              state.teamCharacters.length == 1,
              true,
              reason: 'After saveChanges, the single team character should be retained',
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
            expect(state.character.key, keqingKey, reason: 'Failed save should preserve the selected character $keqingKey');
            expect(state.isRecommended, false, reason: 'Untouched isRecommended should remain false after the rejected save');
            expect(
              state.showOnCharacterDetail,
              true,
              reason: 'Untouched showOnCharacterDetail should remain true after the rejected save',
            );
            expect(
              state.skillPriorities.isEmpty,
              true,
              reason: 'Saving with nothing set should leave skill priorities empty',
            );
            expect(state.notes.isEmpty, true, reason: 'Saving with nothing set should leave notes empty');
            expect(state.weapons.isEmpty, true, reason: 'Saving with nothing set should leave weapons empty');
            expect(state.artifacts.isEmpty, true, reason: 'Saving with nothing set should leave artifacts empty');
            expect(
              state.subStatsSummary.isEmpty,
              true,
              reason: 'Saving with no artifacts should leave the sub-stats summary empty',
            );
            expect(
              state.teamCharacters.isEmpty,
              true,
              reason: 'Saving with nothing set should leave team characters empty',
            );
        }
      },
    );
  });
}
