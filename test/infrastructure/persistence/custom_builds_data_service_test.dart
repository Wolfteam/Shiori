import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/domain/app_constants.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/errors.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/calculator_asc_materials_service.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

const String _baseDbFolder = 'custom_builds_data_service';

void main() {
  late final ResourceService resourceService;
  late final GenshinService genshinService;
  late final CalculatorAscMaterialsService calculatorService;

  const keqingNotes = [
    CustomBuildNoteModel(index: 0, note: 'Note A'),
    CustomBuildNoteModel(index: 1, note: 'Note B'),
  ];

  final keqingWeapons = [
    CustomBuildWeaponModel(
      index: 0,
      key: 'aquila-favonia',
      name: 'Aquila favonia',
      image: 'aquila.webp',
      rarity: 5,
      refinement: 1,
      subStatType: StatType.physDmgPercentage,
      stat: WeaponFileStatModel(
        level: 90,
        isAnAscension: false,
        baseAtk: 0,
        statValue: 0,
      ),
      stats: [],
    ),
  ];

  final keqingArtifacts = ArtifactType.values
      .map(
        (e) => CustomBuildArtifactModel(
          key: 'thundering-fury',
          type: e,
          rarity: 0,
          image: '',
          name: '',
          statType: getArtifactPossibleMainStats(e).first,
          subStats: [...getArtifactPossibleSubStats(getArtifactPossibleMainStats(e).first).take(4)],
        ),
      )
      .toList();

  const keqingTeamCharacters = [
    CustomBuildTeamCharacterModel(
      key: 'fischl',
      name: '',
      image: '',
      index: 0,
      iconImage: '',
      roleType: CharacterRoleType.subDps,
      subType: CharacterRoleSubType.electro,
    ),
    CustomBuildTeamCharacterModel(
      key: 'nahida',
      name: '',
      image: '',
      index: 0,
      iconImage: '',
      roleType: CharacterRoleType.subDps,
      subType: CharacterRoleSubType.dendro,
    ),
    CustomBuildTeamCharacterModel(
      key: 'zhongli',
      name: '',
      image: '',
      index: 0,
      iconImage: '',
      roleType: CharacterRoleType.support,
      subType: CharacterRoleSubType.none,
    ),
  ];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settings = MockSettingsService();
    when(settings.language).thenReturn(AppLanguageType.english);
    final localeService = LocaleServiceImpl(settings);

    resourceService = getResourceService(settings);
    genshinService = GenshinServiceImpl(resourceService, localeService);
    calculatorService = CalculatorAscMaterialsServiceImpl(genshinService, resourceService);
    DataServiceImpl(genshinService, calculatorService, resourceService).registerAdapters();

    return Future(() async {
      await genshinService.init(AppLanguageType.english);
    });
  });

  void checkWeapons(List<CustomBuildWeaponModel> gotWeapons, List<CustomBuildWeaponModel> expectedWeapons) {
    expect(
      gotWeapons.length,
      expectedWeapons.length,
      reason: 'Saved build should keep all ${expectedWeapons.length} weapon(s)',
    );
    for (int i = 0; i < gotWeapons.length; i++) {
      final gotWeapon = gotWeapons[i];
      final expectedWeapon = expectedWeapons[i];
      expect(gotWeapon.key, expectedWeapon.key, reason: 'Weapon at index $i should have key=${expectedWeapon.key}');
      expect(
        gotWeapon.index,
        expectedWeapon.index,
        reason: 'Weapon (key=${expectedWeapon.key}) index should be ${expectedWeapon.index}',
      );
      expect(
        gotWeapon.refinement,
        expectedWeapon.refinement,
        reason: 'Weapon (key=${expectedWeapon.key}) refinement should be ${expectedWeapon.refinement}',
      );
      expect(
        gotWeapon.stat.level,
        expectedWeapon.stat.level,
        reason: 'Weapon (key=${expectedWeapon.key}) stat level should be ${expectedWeapon.stat.level}',
      );
      expect(
        gotWeapon.stat.isAnAscension,
        expectedWeapon.stat.isAnAscension,
        reason: 'Weapon (key=${expectedWeapon.key}) isAnAscension should be ${expectedWeapon.stat.isAnAscension}',
      );
    }
  }

  void checkArtifacts(List<CustomBuildArtifactModel> gotArtifacts, List<CustomBuildArtifactModel> expectedArtifacts) {
    expect(
      gotArtifacts.length,
      expectedArtifacts.length,
      reason: 'Saved build should keep all ${expectedArtifacts.length} artifact(s)',
    );
    for (int i = 0; i < gotArtifacts.length; i++) {
      final gotArtifact = gotArtifacts[i];
      final expectedArtifact = expectedArtifacts[i];
      expect(
        gotArtifact.key,
        expectedArtifact.key,
        reason: 'Artifact at index $i should have key=${expectedArtifact.key}',
      );
      expect(
        gotArtifact.type,
        expectedArtifact.type,
        reason: 'Artifact (key=${expectedArtifact.key}) type should be ${expectedArtifact.type}',
      );
      expect(
        gotArtifact.statType,
        expectedArtifact.statType,
        reason: 'Artifact (key=${expectedArtifact.key}) statType should be ${expectedArtifact.statType}',
      );
      expect(
        gotArtifact.subStats,
        expectedArtifact.subStats,
        reason: 'Artifact (key=${expectedArtifact.key}) subStats should be preserved on save',
      );
    }
  }

  void checkTeamCharacters(List<CustomBuildTeamCharacterModel> gotTeams, List<CustomBuildTeamCharacterModel> expectedTeams) {
    expect(
      gotTeams.length,
      expectedTeams.length,
      reason: 'Saved build should keep all ${expectedTeams.length} team character(s)',
    );
    for (int i = 0; i < gotTeams.length; i++) {
      final gotTeamChar = gotTeams[i];
      final expectedTeamChar = expectedTeams[i];
      expect(
        gotTeamChar.key,
        expectedTeamChar.key,
        reason: 'Team character at index $i should have key=${expectedTeamChar.key}',
      );
      expect(
        gotTeamChar.index,
        expectedTeamChar.index,
        reason: 'Team character (key=${expectedTeamChar.key}) index should be ${expectedTeamChar.index}',
      );
      expect(
        gotTeamChar.roleType,
        expectedTeamChar.roleType,
        reason: 'Team character (key=${expectedTeamChar.key}) roleType should be ${expectedTeamChar.roleType}',
      );
      expect(
        gotTeamChar.subType,
        expectedTeamChar.subType,
        reason: 'Team character (key=${expectedTeamChar.key}) subType should be ${expectedTeamChar.subType}',
      );
    }
  }

  void checkNotes(List<CustomBuildNoteModel> gotNotes, List<CustomBuildNoteModel> expectedNotes) {
    expect(
      gotNotes.length,
      expectedNotes.length,
      reason: 'Saved build should keep all ${expectedNotes.length} note(s)',
    );
    for (int i = 0; i < gotNotes.length; i++) {
      final gotNote = gotNotes[i];
      final expectedNote = expectedNotes[i];
      expect(gotNote.index, expectedNote.index, reason: 'Note at position $i should have index=${expectedNote.index}');
      expect(
        gotNote.note,
        expectedNote.note,
        reason: 'Note at index ${expectedNote.index} text should be "${expectedNote.note}"',
      );
    }
  }

  void checkBuild(CustomBuildModel got, CustomBuildModel expected) {
    expect(got.key, expected.key, reason: 'Persisted build key should be ${expected.key}');
    expect(got.title, expected.title, reason: 'Persisted build title should be "${expected.title}"');
    expect(got.type, expected.type, reason: 'Persisted build role type should be ${expected.type}');
    expect(got.subType, expected.subType, reason: 'Persisted build role sub type should be ${expected.subType}');
    expect(
      got.showOnCharacterDetail,
      expected.showOnCharacterDetail,
      reason: 'Persisted build showOnCharacterDetail should be ${expected.showOnCharacterDetail}',
    );
    expect(
      got.isRecommended,
      expected.isRecommended,
      reason: 'Persisted build isRecommended should be ${expected.isRecommended}',
    );
    expect(
      got.skillPriorities,
      expected.skillPriorities,
      reason: 'Persisted build skillPriorities should be preserved',
    );
    expect(
      got.subStatsSummary,
      expected.subStatsSummary,
      reason: 'Persisted build subStatsSummary should be preserved',
    );

    checkWeapons(got.weapons, expected.weapons);
    checkArtifacts(got.artifacts, expected.artifacts);
    checkTeamCharacters(got.teamCharacters, expected.teamCharacters);
    checkNotes(got.notes, expected.notes);
  }

  group('Get all custom builds', () {
    const dbFolder = '${_baseDbFolder}_get_all_custom_builds_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('no data exists', () {
      final builds = dataService.customBuilds.getAllCustomBuilds();
      expect(builds.isEmpty, isTrue, reason: 'With no data, getAllCustomBuilds() should return an empty list');
    });

    test('data exists', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final builds = dataService.customBuilds.getAllCustomBuilds();
      expect(builds.length, 1, reason: 'After saving one build, getAllCustomBuilds() should return exactly 1 build');
      checkBuild(builds.first, build);
    });
  });

  group('Get custom build', () {
    const dbFolder = '${_baseDbFolder}_get_custom_build_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('key is not valid', () {
      expect(
        () => dataService.customBuilds.getCustomBuild(-1),
        throwsArgumentError,
        reason: 'Getting a build with a negative key (-1) must throw ArgumentError',
      );
    });

    test('build does not exist', () {
      expect(
        () => dataService.customBuilds.getCustomBuild(666),
        throwsA(isA<NotFoundError>()),
        reason: 'Getting a non-existent build (key=666) must throw NotFoundError',
      );
    });

    test('build exists', () async {
      final createdBuild = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final build = dataService.customBuilds.getCustomBuild(createdBuild.key);
      checkBuild(build, createdBuild);
    });
  });

  group('Save custom build', () {
    const dbFolder = '${_baseDbFolder}_save_custom_build_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('char key is not valid', () {
      expect(
        dataService.customBuilds.saveCustomBuild(
          '',
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
        reason: 'Saving a build with an empty character key must throw ArgumentError',
      );
    });

    test('title is not valid', () {
      expect(
        dataService.customBuilds.saveCustomBuild(
          'keqing',
          '',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
        reason: 'Saving a build with an empty title must throw ArgumentError',
      );
    });

    test('empty weapons', () {
      expect(
        dataService.customBuilds.saveCustomBuild(
          'keqing',
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          [],
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
        reason: 'Saving a build with no weapons must throw ArgumentError',
      );
    });

    test('empty artifacts', () {
      expect(
        dataService.customBuilds.saveCustomBuild(
          'keqing',
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          [],
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
        reason: 'Saving a build with no artifacts must throw ArgumentError',
      );
    });

    test('valid call', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      expect(
        build.key,
        greaterThanOrEqualTo(0),
        reason: 'A saved build should be assigned a non-negative key, got ${build.key}',
      );
    });
  });

  group('Update custom build', () {
    const dbFolder = '${_baseDbFolder}_update_custom_build_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('key is not valid', () {
      expect(
        dataService.customBuilds.updateCustomBuild(
          -1,
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
        reason: 'Updating a build with a negative key (-1) must throw ArgumentError',
      );
    });

    test('title is not valid', () {
      expect(
        dataService.customBuilds.updateCustomBuild(
          1,
          '',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
        reason: 'Updating a build with an empty title must throw ArgumentError',
      );
    });

    test('weapons are empty', () {
      expect(
        dataService.customBuilds.updateCustomBuild(
          1,
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          [],
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
        reason: 'Updating a build with no weapons must throw ArgumentError',
      );
    });

    test('artifacts are empty', () {
      expect(
        dataService.customBuilds.updateCustomBuild(
          1,
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          [],
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsArgumentError,
        reason: 'Updating a build with no artifacts must throw ArgumentError',
      );
    });

    test('build does not exist', () {
      expect(
        dataService.customBuilds.updateCustomBuild(
          666,
          'Test',
          CharacterRoleType.subDps,
          CharacterRoleSubType.electro,
          true,
          true,
          keqingNotes,
          keqingWeapons,
          keqingArtifacts,
          keqingTeamCharacters,
          CharacterSkillType.values,
        ),
        throwsA(isA<NotFoundError>()),
        reason: 'Updating a non-existent build (key=666) must throw NotFoundError',
      );
    });

    test('valid call', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final updatedNotes = keqingNotes.map((e) => e.copyWith(note: '${e.note}-Updated')).toList();
      final updatedWeapons = [
        ...keqingWeapons,
        CustomBuildWeaponModel(
          index: 0,
          key: 'primordial-jade-cutter',
          name: '',
          image: '',
          rarity: 5,
          refinement: 5,
          subStatType: StatType.critDmgPercentage,
          stat: WeaponFileStatModel(
            level: 80,
            isAnAscension: true,
            baseAtk: 0,
            statValue: 0,
          ),
          stats: [],
        ),
      ];
      final updatedArtifacts = keqingArtifacts.map((e) => e.copyWith(key: 'pale-flame')).toList();
      const updatedTeamChars = [
        CustomBuildTeamCharacterModel(
          key: 'yae-miko',
          name: '',
          image: '',
          index: 0,
          iconImage: '',
          roleType: CharacterRoleType.dps,
          subType: CharacterRoleSubType.electro,
        ),
        CustomBuildTeamCharacterModel(
          key: 'furina',
          name: '',
          image: '',
          index: 0,
          iconImage: '',
          roleType: CharacterRoleType.subDps,
          subType: CharacterRoleSubType.hydro,
        ),
        CustomBuildTeamCharacterModel(
          key: 'kaedehara-kazuha',
          name: '',
          image: '',
          index: 0,
          iconImage: '',
          roleType: CharacterRoleType.support,
          subType: CharacterRoleSubType.anemo,
        ),
      ];
      final skillPriorities = CharacterSkillType.values.reversed.toList();
      final updatedBuild = await dataService.customBuilds.updateCustomBuild(
        build.key,
        'Updated',
        CharacterRoleType.dps,
        CharacterRoleSubType.none,
        false,
        false,
        updatedNotes,
        updatedWeapons,
        updatedArtifacts,
        updatedTeamChars,
        skillPriorities,
      );

      expect(updatedBuild.title, 'Updated', reason: 'After update, build (key=${build.key}) title should be "Updated"');
      expect(
        updatedBuild.type,
        CharacterRoleType.dps,
        reason: 'After update, build (key=${build.key}) role type should be CharacterRoleType.dps',
      );
      expect(
        updatedBuild.subType,
        CharacterRoleSubType.none,
        reason: 'After update, build (key=${build.key}) role sub type should be CharacterRoleSubType.none',
      );
      expect(
        updatedBuild.showOnCharacterDetail,
        isFalse,
        reason: 'After update, build (key=${build.key}) showOnCharacterDetail should be false',
      );
      expect(
        updatedBuild.isRecommended,
        isFalse,
        reason: 'After update, build (key=${build.key}) isRecommended should be false',
      );
      expect(
        updatedBuild.skillPriorities,
        skillPriorities,
        reason: 'After update, build (key=${build.key}) skillPriorities should match the reversed list',
      );
      checkWeapons(updatedBuild.weapons, updatedWeapons);
      checkArtifacts(updatedBuild.artifacts, updatedArtifacts);
      checkTeamCharacters(updatedBuild.teamCharacters, updatedTeamChars);
      checkNotes(updatedBuild.notes, updatedNotes);
    });
  });

  group('Delete custom build', () {
    const dbFolder = '${_baseDbFolder}_delete_custom_build_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('key is not valid', () {
      expect(
        dataService.customBuilds.deleteCustomBuild(-1),
        throwsArgumentError,
        reason: 'Deleting a build with a negative key (-1) must throw ArgumentError',
      );
    });

    test('build does not exist', () {
      expect(
        dataService.customBuilds.deleteCustomBuild(666),
        completes,
        reason: 'Deleting a non-existent build (key=666) should complete without error',
      );
    });

    test('build exists and gets deleted', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      await dataService.customBuilds.deleteCustomBuild(build.key);
      expect(
        () => dataService.customBuilds.getCustomBuild(build.key),
        throwsA(isA<NotFoundError>()),
        reason: 'After deletion, getting build (key=${build.key}) must throw NotFoundError',
      );
    });
  });

  group('Get custom builds for character', () {
    const dbFolder = '${_baseDbFolder}_get_custom_builds_for_character_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('invalid key', () {
      expect(
        () => dataService.customBuilds.getCustomBuildsForCharacter(''),
        throwsArgumentError,
        reason: 'Getting builds with an empty character key must throw ArgumentError',
      );
    });

    test('which does not have any created build', () {
      final builds = dataService.customBuilds.getCustomBuildsForCharacter('ganyu');
      expect(builds.isEmpty, isTrue, reason: 'Character (key=ganyu) with no builds should return an empty list');
    });

    test('which has 1 created build', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final builds = dataService.customBuilds.getCustomBuildsForCharacter(build.character.key);
      expect(builds.length, 1, reason: 'Character (key=${build.character.key}) should have exactly 1 build');
      final got = builds.first;
      expect(
        got.isRecommended,
        build.isRecommended,
        reason: 'Returned build isRecommended should match saved (${build.isRecommended})',
      );
      expect(got.type, build.type, reason: 'Returned build role type should match saved (${build.type})');
      expect(got.subType, build.subType, reason: 'Returned build role sub type should match saved (${build.subType})');
      expect(
        got.skillPriorities,
        build.skillPriorities,
        reason: 'Returned build skillPriorities should match saved',
      );
      expect(
        got.subStatsToFocus,
        build.subStatsSummary,
        reason: 'Returned build subStatsToFocus should match saved subStatsSummary',
      );
      expect(
        got.isCustomBuild,
        isTrue,
        reason: 'Builds from getCustomBuildsForCharacter should be flagged isCustomBuild',
      );
      expect(
        got.weapons.length,
        keqingWeapons.length,
        reason: 'Returned build should keep all ${keqingWeapons.length} weapon(s)',
      );
      expect(got.artifacts.length, 1, reason: 'Returned build should expose exactly 1 artifact set entry');
    });
  });

  group('Get data for backup', () {
    const dbFolder = '${_baseDbFolder}_get_data_for_backup_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('no data exist', () {
      final bk = dataService.customBuilds.getDataForBackup();
      expect(bk.isEmpty, isTrue, reason: 'With no builds, getDataForBackup() should return an empty list');
    });

    test('data exist', () async {
      await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final bk = dataService.customBuilds.getDataForBackup();
      expect(bk.isNotEmpty, isTrue, reason: 'After saving a build, getDataForBackup() should not be empty');
      expect(bk.first.characterKey, 'keqing', reason: 'Backed-up build characterKey should be keqing');
    });
  });

  group('Restore from backup', () {
    const dbFolder = '${_baseDbFolder}_restore_from_backup_tests';
    late DataService dataService;
    late String dbPath;

    setUp(() {
      dataService = DataServiceImpl(genshinService, calculatorService, resourceService);
      return Future(() async {
        dbPath = await getDbPath(dbFolder);
        await dataService.initForTests(dbPath, registerAdapters: false);
      });
    });

    tearDown(() {
      return Future(() async {
        await dataService.closeThemAll();
        await deleteDbFolder(dbPath);
      });
    });

    test('empty backup and no data exist', () {
      expect(
        dataService.customBuilds.restoreFromBackup([]),
        completes,
        reason: 'Restoring an empty backup onto empty data should complete without error',
      );
    });

    test('empty backup and data exists thus it gets deleted', () async {
      await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      await dataService.customBuilds.restoreFromBackup([]);
      final builds = dataService.customBuilds.getAllCustomBuilds();
      expect(builds.isEmpty, isTrue, reason: 'Restoring an empty backup should wipe existing builds, leaving none');
    });

    test('data gets restored', () async {
      final build = await dataService.customBuilds.saveCustomBuild(
        'keqing',
        'Test',
        CharacterRoleType.subDps,
        CharacterRoleSubType.electro,
        true,
        true,
        keqingNotes,
        keqingWeapons,
        keqingArtifacts,
        keqingTeamCharacters,
        CharacterSkillType.values,
      );
      final bk = dataService.customBuilds.getDataForBackup();
      dataService.customBuilds.deleteCustomBuild(build.key);
      await dataService.customBuilds.restoreFromBackup(bk);
      final restoredBuild = dataService.customBuilds.getCustomBuild(0);
      checkBuild(restoredBuild, build);
    });
  });
}
